---
title: Theory of Operation
---


# Theory of Operation

This project implements an AMBA AHB interconnect with the following major components:

- Arbiter (`rtl/ahb_arbiter.sv`) — manages master request/grant arbitration and implements the arbitration FSM (see `docs/image_design/ahb_protocol-Arbiter FSM.jpg`).
- Address decoder (`rtl/decoder.sv`) — maps address ranges to slave select signals.
- Master wrapper (`rtl/ahb_master_wrapper.sv`) — adapts master signals to the internal bus protocol.
- Slave wrapper (`rtl/slave_wrapper.sv`) — adapts slave endpoints to the interconnect.
- Muxes (`rtl/master_to_slave_mux.sv`, `rtl/slave_to_master_mux.sv`) — route requests and responses across the bus.

Signal semantics

Preserve standard AHB handshake signals (HADDR, HWDATA, HWRITE, HREADY, HRESP). When changing widths or semantics, update `defines/parameters.svh` and all dependent modules.
