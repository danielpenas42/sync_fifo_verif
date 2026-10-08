# Sync FIFO Verification

Hey, welcome! This is some practice sync FIFO verification in SystemVerilog. It's a template that I aim to bring into C2S2 whenever we can. It's still a work in progress.

The project is a class-based, self-checking testbench for a synchronous FIFO, written without UVM to learn what UVM automates.

It covers three ideas in particular:

- **Mailboxes** for passing transactions between testbench components.
- **Clocking blocks** for race-free driving and sampling of DUT pins.
- **Concurrent threads**: driver, monitor and scoreboard each run their own loop in parallel, and the FIFO is exercised with reads and writes in the same cycle.

## The design under test

`rtl/sync_fifo.v` is a single-clock FIFO with a valid/ready handshake on each side.

| Port | Direction | Meaning |
|---|---|---|
| `w_data`, `w_val` | in | Write data and write request |
| `w_rdy` | out | High when the FIFO is not full |
| `r_data`, `r_val` | out | Read data, valid when the FIFO is not empty |
| `r_rdy` | in | Read request |

A transfer happens on a rising clock edge where valid and ready are both high. Full and empty are detected with read and write pointers that are one bit wider than the address. `DEPTH` must be a power of two. Defaults are 32-bit data and 16 entries.

## Testbench architecture

```
              mailbox                 clocking block
  Test  ───────────────►  Driver  ───────────────────►  ┌───────┐
  (random packets)                                      │  DUT  │
                                                        │ FIFO  │
  Scoreboard  ◄─────────  Monitor  ◄──────────────────  └───────┘
  (queue model)  2 mailboxes        clocking block
```

| Component | File | Role |
|---|---|---|
| `Packet` | `dv/package.sv` | One clock cycle of stimulus: random data, a write bit and a read bit. `write_pct` and `read_pct` set how often each is requested. |
| `fifo_if` | `dv/test_top.sv` | Interface bundling the DUT signals, with the clocking block `cb`. |
| `Driver` | `dv/driver.sv` | Takes packets from its mailbox and drives the pins through `cb`. Also applies reset. |
| `Monitor` | `dv/monitor.sv` | Samples the pins through `cb` every clock edge and reports each accepted write and each read. |
| `Scoreboard` | `dv/scoreboard.sv` | Reference model and checker. Accepted writes are pushed onto a queue; each read is compared against the front of it. |
| `BaseTest` | `dv/tests/base_test.sv` | Abstract base class with the `run_traffic` helper and a pure virtual `run` task. |
| `RandomTest` | `dv/tests/random_test.sv` | Sends 100 packets of mixed random traffic. |
| `tb_top` | `dv/test_top.sv` | Clock, interface, DUT, and the `initial` block that builds, connects and starts everything. |

### How it runs

`tb_top` creates the components, applies reset, then starts three background threads with `fork ... join_none`: `drv.run()`, `mon.run()` and `scb.run()`. The test runs in the main thread and feeds packets to the driver. After the test, the scoreboard prints its error count.

The driver does not wait for a handshake. Each packet is one cycle of requests, so writes while full and reads while empty are attempted on purpose. The monitor counts a transfer only when valid and ready were both high, and the scoreboard checks only those.

## Running

Requires Synopsys VCS.

```bash
mkdir -p sim && cd sim
module load synopsys/synopsys-vcs

vcs -sverilog -full64 +incdir+../dv \
    ../rtl/sync_fifo.v ../dv/package.sv \
    ../dv/driver.sv ../dv/scoreboard.sv ../dv/monitor.sv \
    ../dv/tests/base_test.sv ../dv/tests/random_test.sv \
    ../dv/test_top.sv -o simv

./simv
```

Expected output ends with:

```
there were 0 errors
```

Use `./simv +ntb_random_seed=<n>` for a different random run. The same seed reproduces the same run.

## Concepts practised

- Constrained-random stimulus: `rand` fields, `dist` weights, `pre_randomize`.
- Interfaces and virtual interfaces, connecting classes to DUT pins.
- Clocking blocks: sampling before the clock edge, driving after it.
- Mailboxes, bounded and unbounded.
- `fork ... join` and `fork ... join_none`.
- Queues as a reference model.
- Inheritance, virtual classes and pure virtual tasks.
- Packages.
