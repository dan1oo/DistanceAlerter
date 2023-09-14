#![allow(unsafe_code)]
#![allow(warnings)]
#![no_main]
#![no_std]
#![feature(type_alias_impl_trait)]

// use panic_rtt_target as _;
use rtic::app;
use rtic_monotonics::systick::*;
use test_app as _;
// use rtt_target::{rprintln, rtt_init_print};
use stm32f3xx_hal::{
    delay::Delay,
    gpio::{Gpiob, Input, Output, Pin, PushPull, PE8, U},
    pac,
    prelude::*,
    pwm::{tim3, PwmChannel, Tim3Ch1, WithPins},
    timer::MonoTimer,
};

#[app(device = stm32f3xx_hal::pac, peripherals = true, dispatchers = [SPI1])]
mod app {
    use super::*;

    #[shared]
    struct Shared {
        frequency_index: u32,
        delay: Delay,
    }

    #[local]
    struct Local {
        led: PE8<Output<PushPull>>,
        state: bool,

        signal: PwmChannel<Tim3Ch1, WithPins>,

        trig: Pin<Gpiob, U<9>, Output<PushPull>>,

        echo: Pin<Gpiob, U<8>, Input>,

        timer: MonoTimer,
    }

    #[init]
    fn init(cx: init::Context) -> (Shared, Local) {
        // Setup clocks
        let mut flash = cx.device.FLASH.constrain();
        let mut rcc = cx.device.RCC.constrain();

        // Initialize the systick interrupt & obtain the token to prove that we did
        //let systick_mono_token = rtic_monotonics::create_systick_token!();
        //Systick::start(cx.core.SYST, 36_000_000, systick_mono_token); // default STM32F303 clock-rate is 36MHz

        // rtt_init_print!();
        defmt::info!("init");

        let _clocks = rcc
            .cfgr
            .use_hse(8.MHz())
            .sysclk(36.MHz())
            .pclk1(36.MHz())
            .freeze(&mut flash.acr);

        //delay

        let delay = Delay::new(cx.core.SYST, _clocks);

        //timer

        let mut DCB = cx.core.DCB;

        let mut timer = MonoTimer::new(cx.core.DWT, _clocks, &mut DCB);

        // Setup LED
        let mut gpioe = cx.device.GPIOE.split(&mut rcc.ahb);
        let mut led = gpioe
            .pe8
            .into_push_pull_output(&mut gpioe.moder, &mut gpioe.otyper);
        led.set_high().unwrap();

        //Setup PWM
        let mut gpiob = cx.device.GPIOB.split(&mut rcc.ahb);
        let pb4 = gpiob
            .pb4
            .into_af_push_pull(&mut gpiob.moder, &mut gpiob.otyper, &mut gpiob.afrl);
        let tim3_channels = tim3(cx.device.TIM3, 9000, 100.Hz(), &_clocks);
        let mut signal: PwmChannel<Tim3Ch1, WithPins> = tim3_channels.0.output_to_pb4(pb4);
        signal.enable();

        signal.set_duty(signal.get_max_duty() / 2);

        //Setup ultrasonic

        let mut echo = gpiob
            .pb8
            .into_pull_up_input(&mut gpiob.moder, &mut gpiob.pupdr);

        let mut trig = gpiob
            .pb9
            .into_push_pull_output(&mut gpiob.moder, &mut gpiob.otyper);

        // Schedule tasks

        ultrasonic::spawn().ok();
        //set_speaker::spawn().ok();

        (
            Shared {
                frequency_index: 0,
                delay,
            },
            Local {
                led,
                state: false,
                signal,
                trig,
                echo,
                timer,
            },
        )
    }
    #[idle]
    fn idle(_: idle::Context) -> ! {
        defmt::info!("idle");

        loop {
            ultrasonic::spawn();
        }
    }

    #[task(priority = 1, local = [echo, trig, timer], shared =  [delay,frequency_index])]
    async fn ultrasonic(mut cx: ultrasonic::Context) {
        let mut delay = cx.shared.delay;

        defmt::info!("ultrasonic reading");
        cx.local.trig.set_low().unwrap();
        delay.lock(|delay| {
            delay.delay_us(10_u32);
        });
        cx.local.trig.set_high().unwrap();
        delay.lock(|delay| {
            delay.delay_us(5_u32);
        });
        cx.local.trig.set_low().unwrap();
        defmt::info!("waiting for echo");
        while !cx.local.echo.is_high().unwrap() {}
        defmt::info!("echo received, starting timer");

        //Set timer to measure duration of echo
        let start = cx.local.timer.now();

        //Stop timer when echo pin goes low
        while !cx.local.echo.is_low().unwrap() {}
        defmt::info!("echo finished");

        let duration = start.elapsed();

        //Convert distance to cm
        let distance = duration / 2 / 29 / 10;
        defmt::info!("Distance {}", distance);
        let distance_index = match distance {
            0..=50 => 1,

            51..=100 => 2,

            101..=150 => 3,

            _ => 4,
        };
        cx.shared.frequency_index.lock(|frequency_index| {
            *frequency_index = distance_index;
        });
        // let delay = cx.shared.delay.lock(|delay| *delay);

        // if delay != key {
        //     let delay = cx.shared.delay.lock(|delay| {
        //         *delay = key;

        //         *delay
        //     });

        set_speaker::spawn().ok();
    }

    #[task(priority = 1, local = [signal], shared = [delay,frequency_index])]
    async fn set_speaker(mut cx: set_speaker::Context) {
        let mut delay = cx.shared.delay;
        let key = cx
            .shared
            .frequency_index
            .lock(|frequency_index| *frequency_index);
        defmt::info!("Setting speaker | Key: {}", key);

        let (freq, period) = match key {
            1 => (250, 125_u32),
            2 => (100, 250_u32),
            3 => (100, 500_u32),
            4 => (100, 1000_u32),
            _ => (100, 600_u32),
        };

        cx.local.signal.disable();

        unsafe {
            (*pac::TIM3::ptr()).psc.write(|w| w.bits(80_000 / freq));
            (*pac::TIM3::ptr()).arr.write(|w| w.bits(100));
        }

        delay.lock(|delay| {
            delay.delay_ms(10_u32);
        });

        cx.local.signal.enable();

        cx.local.signal.set_duty(cx.local.signal.get_max_duty() / 2);
        defmt::info!("Period: {}", period);
        delay.lock(|delay| {
            delay.delay_ms(period);
        });
        defmt::info!("Checkpoint");
        cx.local.signal.disable();
    }
}
