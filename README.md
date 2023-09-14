# STM32F3 RTIC Distance Alerter Project

Working example of Distance measuring application for STM32 F303 Nucleo-64 board based on the STM32F303RE chip. Project uses schedule API and peripherials access.

## How-to

### Build

Run `cargo +nightly build` to compile the code. If you run it for the first time, it will take some time to download and compile dependencies.

After that, you can use for example the cargo-embed tool to flash and run it

```bash
$ cargo +nightly embed
```


