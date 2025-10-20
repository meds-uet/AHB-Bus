---
title: User Guide
---

# User Guide

Configuration
- Edit `defines/parameters.svh` to change `NUM_MASTERS`, `NUM_SLAVES`, and bus widths.

Example use-cases
- Use the supplied testbenches in `testbench/` as templates for integration tests.

Register map
- This IP does not provide a runtime register map; add registers in your wrapper or slave RTL as required.
