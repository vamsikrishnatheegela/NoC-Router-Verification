# 5-Port NoC Router Verification

Parameterized SystemVerilog router with FIFO buffering, destination routing, cocotb tests, Verilator lint, and Yosys synthesis.

## Ubuntu commands

```bash
make
make lint
make synth
```

The packet destination is encoded in bits `[31:29]`: `0=NORTH`, `1=SOUTH`, `2=EAST`, `3=WEST`, `4=LOCAL`.

## Project milestones

1. Functional routing and randomized cocotb regression.
2. Add arbitration and multiple-input contention.
3. Add assertions, coverage, backpressure, and fault injection.
4. Measure latency, throughput, FIFO utilization, and fairness.
