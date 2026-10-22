# Parameterized 5-Port Network-on-Chip Router

![Language](https://img.shields.io/badge/RTL-SystemVerilog-blue)
![Verification](https://img.shields.io/badge/Verification-cocotb%20%7C%20Icarus-orange)
![Synthesis](https://img.shields.io/badge/Synthesis-Yosys-purple)
![Lint](https://img.shields.io/badge/Lint-Verilator-green)

This project implements and verifies a compact, synthesizable five-port Network-on-Chip (NoC) router. The design accepts packets from five input ports, stores them in independent FIFO buffers, decodes the destination encoded in each packet, and forwards packets to one of five logical output ports.

The project demonstrates a complete open-source RTL workflow:

```text
SystemVerilog RTL
        |
        +--> Icarus Verilog + cocotb simulation
        |
        +--> Verilator lint
        |
        +--> Yosys synthesis
        |
        +--> JSON synthesized netlist
```

## Project objectives

The goals are to:

- Design a parameterized NoC router in synthesizable SystemVerilog.
- Implement independent buffering for five input channels.
- Route packets using destination metadata.
- Verify reset, packet transfer, routing, and randomized traffic.
- Build a reproducible command-line simulation flow.
- Run lint and synthesis using freely available tools.
- Produce a synthesized netlist for further FPGA or ASIC work.

## Router architecture

The router has five logical ports:

| Port index | Logical port |
|---:|---|
| 0 | North |
| 1 | South |
| 2 | East |
| 3 | West |
| 4 | Local |

Each input port has an independent FIFO. When a packet is accepted, it is written into the FIFO associated with that input. The head packet of each FIFO is examined continuously, and its destination field selects the output port.

The current version is intentionally a baseline router. It supports independent input buffering and destination forwarding. Advanced output arbitration, virtual channels, wormhole flow control, and packet-level routing tables are reserved for future versions.

## Packet format

The packet width is 32 bits by default. The three most-significant bits encode the destination:

| Bits | Meaning |
|---|---|
| `[31:29]` | Destination port |
| `[28:0]` | Payload and user-defined metadata |

Destination encoding:

```text
000  North
001  South
010  East
011  West
100  Local
101-111  Invalid; mapped to Local
```

For a destination `d` and payload `p`, a packet can be formed as:

```text
packet = (d << 29) | p
```

## Interface

The top-level module is `noc_router`.

The packed input and output buses contain five 32-bit lanes:

```text
in_data  [159:0]
out_data [159:0]
```

Lane `i` occupies:

```text
bus[i*DATA_W +: DATA_W]
```

The valid and ready signals are five-bit vectors. Bit `i` corresponds to port `i`.

```text
in_valid[i]   Input packet is available
in_ready[i]   Input FIFO can accept a packet
out_valid[i]  Output packet is available
out_ready[i]  Downstream receiver can accept a packet
```

A transfer occurs on a rising clock edge when both sides of the corresponding valid/ready pair are asserted.

## Repository structure

```text
.
├── rtl/
│   └── noc_router.sv          # Synthesizable router RTL
├── tb/
│   └── tb_top.sv              # Simulation wrapper
├── tests/
│   └── test_noc_router.py     # cocotb verification tests
├── scripts/
│   └── synth.ys               # Yosys synthesis script
├── build/
│   └── noc_router.json        # Generated synthesized netlist
├── Makefile                   # Simulation, lint, and synthesis targets
├── .gitignore                 # Generated-file exclusions
└── README.md                  # Project documentation
```

## Verification strategy

The cocotb testbench performs the following checks:

1. Starts a clock and applies a reset pulse.
2. Enables all output receivers.
3. Sends packets from the local input lane.
4. Encodes each destination in the packet header.
5. Waits for the selected output to become valid.
6. Checks that the received payload matches the transmitted packet.
7. Repeats the procedure for all five destinations.

The testbench uses Python so that it can later be extended with:

- Constrained-random packet generation
- Reference-model scoreboarding
- Backpressure scenarios
- FIFO overflow tests
- Packet corruption tests
- Coverage collection
- Latency and throughput measurements

## Required tools

The project was developed for Ubuntu and uses:

```text
Yosys
Icarus Verilog
Verilator
GTKWave
Python 3
cocotb
pytest
Git
GitHub CLI
```

Install the Python dependencies with:

```bash
python3 -m pip install --user cocotb pytest cocotb-bus
```

## Running the project

Clone the repository:

```bash
git clone https://github.com/vamsikrishnatheegela/NoC-Router-Verification.git
cd NoC-Router-Verification
```

Run the cocotb simulation:

```bash
make
```

Run Verilator lint:

```bash
make lint
```

Run Yosys synthesis:

```bash
mkdir -p build
make synth
```

The synthesized netlist is written to:

```text
build/noc_router.json
```

Remove generated simulation files:

```bash
make purge
```

## Synthesis result

Yosys successfully elaborates and synthesizes the router. The generated statistics depend on the selected FIFO depth and data width. The default configuration produces a fully elaborated JSON netlist that can be used for downstream inspection or adapted to an FPGA/ASIC flow.

The synthesis flow is intentionally kept simple so that the design can later be connected to:

- FPGA technology mapping
- OpenROAD physical design
- Gate-level simulation
- Timing analysis
- Power estimation

## Design limitations

This is the first functional baseline and has deliberate limitations:

- Multiple input FIFOs targeting one output are not yet arbitrated.
- The design does not yet implement virtual channels.
- There is no deadlock-avoidance protocol.
- There is no packet CRC or end-to-end error detection.
- The current testbench does not yet close functional coverage.
- Performance metrics are not yet collected automatically.

These limitations define clear future extensions rather than preventing the baseline from being used as a working educational RTL and verification project.

## Future work

Planned upgrades include:

1. Round-robin output arbitration.
2. Contention and fairness verification.
3. Explicit backpressure and FIFO-full testing.
4. SystemVerilog assertions for valid/ready protocol rules.
5. Functional coverage for all ports and traffic patterns.
6. Fault injection for dropped and corrupted packets.
7. Latency, throughput, and FIFO-utilization reports.
8. UVM-based verification using ModelSim or Questa.
9. FPGA implementation and hardware-in-the-loop testing.

## Skills demonstrated

This project demonstrates practical experience with:

- SystemVerilog RTL design
- FIFO-based microarchitecture
- Packet routing
- Digital communication interfaces
- Python-based verification
- Cocotb testbench development
- Randomized simulation
- Verilator linting
- Yosys synthesis
- Netlist generation
- Makefile automation
- Git and GitHub project management

## Resume description

> Designed a parameterized five-port Network-on-Chip router in synthesizable SystemVerilog with independent FIFO buffering and destination-based packet forwarding. Developed cocotb directed and randomized verification tests, integrated Verilator linting and Yosys synthesis, and generated a synthesized JSON netlist using an Ubuntu command-line RTL workflow.

## Author

Vamsi Krishna Theegela  
MIT Manipal
