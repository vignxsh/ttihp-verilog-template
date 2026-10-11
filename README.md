# 7-Segment Display Counter

A single-tile Tiny Tapeout Verilog design that counts from 0 to 9 on a 7-segment display.

## How it Works

The design takes the standard 50 MHz project clock and divides it down to a 1 Hz (one second) pulse. Every second, a 4-bit counter increments from 0 to 9 and then wraps around. A logic decoder converts this 4-bit value into the 7-segment display signals.

The output is mapped directly to the Tiny Tapeout demoboard's built-in display:
* `uo_out[0]` to `uo_out[6]` drive Segments A through G.
* `uo_out[7]` drives the Decimal Point (held low/off).

## How to Test

To run the local simulation tests:

```bash
cd test
make -B
