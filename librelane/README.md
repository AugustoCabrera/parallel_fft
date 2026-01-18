# Consider!

| File | Relative path (from `/parallel_fft`) |
| -------------------------- | -------------------------------------------------- |
| `top_chip.v`               | `design/rtl/top_chip.v`                            |
| `fft32.v`                  | `design/rtl/fft32.v`                               |
| `fft8.v`                   | `design/rtl/fft8.v`                                |
| `fft4.v`                   | `design/rtl/fft4.v`                                |
| `buffer_parallel2serial.v` | `design/rtl/buffer_parallel2serial.v`              |
| `shift_r2.v`               | `design/rtl/shift_r2.v`                            |
| `shift_r4.v`               | `design/rtl/shift_r4.v`                            |
| `clip_round.v`             | `design/rtl/clip_round.v`                          |
| `btfly_2.v`                | `design/rtl/common_modules/btfly_2.v`              |
| `ds_switch.v`              | `design/rtl/common_modules/ds_switch.v`            |
| `xfft_cell.v`              | `design/rtl/common_modules/xfft_cell.v`            |
| `complex_multiplier.v`     | `design/rtl/common_modules/complex_multiplier.v`   |
| `tx_serializer.v`          | `design/rtl/common_modules/tx_serializer.v`        |
| `rx_serializer.v`          | `design/rtl/common_modules/rx_serializer.v`        |
| `mdc8p_stage1.v`           | `design/rtl/fft_mdc_8p/stages/mdc8p_stage1.v`      |
| `mdc8p_stage2.v`           | `design/rtl/fft_mdc_8p/stages/mdc8p_stage2.v`      |
| `mdc8p_stage3.v`           | `design/rtl/fft_mdc_8p/stages/mdc8p_stage3.v`      |
| `twiddle_interface.v`      | `design/rtl/twiddle_interface/twiddle_interface.v` |
| `debug_system.v`           | `design/rtl/debug_unit/debug_system.v`             |
| `debug_unit.v`             | `design/rtl/debug_unit/debug_unit.v`               |
| `spi_slave_mode0.v`        | `design/rtl/debug_unit/spi_slave_mode0.v`          |


### file conflict!!!

They’re identical files!

- `design/rtl/common_modules/cdc_snapshot/cdc_snapshot.v`
- `design/rtl/debug_unit/cdc_snapshot.v`

