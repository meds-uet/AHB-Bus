---
title: Developer Guide
---

# Developer Guide

This page explains the recommended workflows for developing, simulating, and testing the RTL in this repository.

Running simulations
- Linux (ModelSim/Questa):

```bash
cd makefiles/linux
make
```

- Windows (Questa/ModelSim):
  - Double-click `makefiles/windows/run.bat` or open `makefiles/windows/run.do` in the simulator GUI.

Quick developer checklist
1. Update `defines/parameters.svh` only when you understand all dependent modules.
2. Update RTL in `rtl/` and keep port names consistent with their `_tb.sv` files in `testbench/`.
3. Add or update a testbench in `testbench/` that verifies the changed behavior.
4. Run simulations locally and inspect waveforms in ModelSim/Questa.
5. Update docs in `docs/` (or this developer guide) when interfaces or flows change.

Adding new tests
- Create a new `_tb.sv` file under `testbench/` that instantiates the DUT and provides stimulus.
- Prefer copying existing testbenches as templates (they mirror RTL module names).

Debugging tips
- Grep for macro usages if changing `parameters.svh`:

```bash
grep -R "`define NUM_MASTERS\|`define NUM_SLAVES" -n .
```

- Trace signals from master to arbiter to muxes to find mismatches in handshakes (HREADY/HRESP).
