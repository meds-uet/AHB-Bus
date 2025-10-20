---
title: API Reference
---

# API Reference

This page lists the main RTL modules, their purpose, and where to find them. For full port lists, consult each RTL file in `rtl/` (source-of-truth).


## ahb_arbiter (rtl/ahb_arbiter.sv)

Purpose: Round-robin arbiter that grants bus ownership to one master at a time and tracks bursts.

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Hclk | input | logic | AHB clock |
| Hresetn | input | logic | Active-low reset |
| Hreq | input | logic [`NUM_MASTERS-1:0] | Master request vector |
| Hready | input | logic | Global ready from slaves |
| Htrans | input | logic [1:0] | Transfer type |
| Hburst | input | logic [2:0] | Burst type |
| Hgrant | output | logic [`NUM_MASTERS-1:0] | Grant vector to masters |
| Hmaster | output | logic [`MASTER_WIDTH-1:0] | Index of currently active master |

Notes: uses `parameters.svh` macros for `NUM_MASTERS` and `MASTER_WIDTH`. Burst decoding lives in this module.

## ahb_master_wrapper (rtl/ahb_master_wrapper.sv)

Purpose: Adapts a simple functional master interface (Paddr/Pload/Pstore) to an AHB master interface and asserts `Hreq` for arbitration.

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Hclk | input | logic | AHB clock |
| Hresetn | input | logic | Active-low reset |
| Paddr | input | logic [`ADDR_WIDTH-1:0] | Functional address input |
| PWdata | input | logic [`DATA_WIDTH-1:0] | Functional write data |
| Pload | input | logic | Read request (functional) |
| Pstore | input | logic | Write request (functional) |
| Psize | input | logic [2:0] | Size of transfer |
| Pburst | input | logic [2:0] | Burst type |
| Ptrans | input | logic [1:0] | Transfer type |
| Pready | output | logic | Functional ready signal |
| PRdata | output | logic [`DATA_WIDTH-1:0] | Functional read data |
| Presp | output | logic [1:0] | Functional response |
| Haddr | output | logic [`ADDR_WIDTH-1:0] | AHB address |
| Htrans | output | logic [1:0] | AHB transfer type |
| Hwrite | output | logic | AHB write flag |
| Hsize | output | logic [2:0] | AHB size |
| Hburst | output | logic [2:0] | AHB burst |
| HWdata | output | logic [`DATA_WIDTH-1:0] | AHB write data |
| HRdata | input | logic [`DATA_WIDTH-1:0] | AHB read data |
| Hready | input | logic | AHB ready from slave |
| Hresp | input | logic [1:0] | AHB response |
| Hreq | output | logic | Arbiter request signal |
| Hgrant | input | logic | Arbiter grant signal |

Notes: Uses `parameters.svh` for `ADDR_WIDTH` and `DATA_WIDTH`. Latches write data on `Hready` low cycles.

## decoder (rtl/decoder.sv)

Purpose: Map `Haddr` to a one-hot `Hsel` vector selecting the targeted slave. Uses `BASE_ADDR[]`/`HIGH_ADDR[]` arrays (expected from parameters/includes).

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Haddr | input | logic [`ADDR_WIDTH-1:0] | Address input |
| Hsel | output | logic [`NUM_SLAVES-1:0] | One-hot slave select outputs |

Notes: Ensure `BASE_ADDR`/`HIGH_ADDR` arrays are defined when adding new slaves.

## master_to_slave_mux (rtl/master_to_slave_mux.sv)

Purpose: Route signals from the currently selected master to the common bus signals seen by slaves.

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Hmaster | input | logic [`MASTER_WIDTH-1:0] | Selected master index |
| Haddr_M | input | logic [`DATA_WIDTH-1:0] [`NUM_MASTERS] | Per-master address vectors |
| Htrans_M | input | logic [1:0] [`NUM_MASTERS] | Per-master transfer types |
| Hwrite_M | input | logic [`NUM_MASTERS] | Per-master write flags |
| Hsize_M | input | logic [2:0] [`NUM_MASTERS] | Per-master sizes |
| Hburst_M | input | logic [2:0] [`NUM_MASTERS] | Per-master bursts |
| Hstrob_M | input | logic [`DATA_WIDTH/8-1:0] [`NUM_MASTERS] | Per-master strobe vectors |
| Hwdata_M | input | logic [`DATA_WIDTH-1:0] [`NUM_MASTERS] | Per-master write data |
| Haddr | output | logic [`DATA_WIDTH-1:0] | Selected master address |
| Htrans | output | logic [1:0] | Selected master transfer type |
| Hwrite | output | logic | Selected master write flag |
| Hsize | output | logic [2:0] | Selected master size |
| Hburst | output | logic [2:0] | Selected master burst |
| Hstrob | output | logic [`DATA_WIDTH/8-1:0] | Selected master strobe |
| Hwdata | output | logic [`DATA_WIDTH-1:0] | Selected master write data |

Notes: This module relies on arrayed per-master signals; adding masters requires updating `parameters.svh` and connections.

## slave_to_master_mux (rtl/slave_to_master_mux.sv)

Purpose: Route responses from the selected slave back to the requesting master and provide a global `Hready`.

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Hclk | input | logic | System clock |
| Hresetn | input | logic | Active-low reset |
| Hsel | input | logic [`NUM_SLAVES-1:0] | One-hot selected slave vector |
| Hmaster | input | logic [`MASTER_WIDTH-1:0] | Selected master index |
| Hrdata_S | input | logic [`DATA_WIDTH-1:0] [`NUM_SLAVES] | Per-slave read data |
| Hresp_S | input | logic [1:0] [`NUM_SLAVES] | Per-slave responses |
| Hreadyout_S | input | logic [`NUM_SLAVES] | Per-slave readyouts |
| Hrdata | output | logic [`DATA_WIDTH-1:0] [`NUM_MASTERS] | Per-master read data outputs |
| Hresp | output | logic [1:0] [`NUM_MASTERS] | Per-master response outputs |
| Hready | output | logic | Global ready to master |

Notes: This module registers selected slave on transfer completion and uses it to index response arrays.

## ahb_slave_wrapper (rtl/slave_wrapper.sv)

Purpose: Wrap an internal slave peripheral with an AHB interface (decode, latching, read/write enables).

Ports:

| Name | Dir | Width / Type | Description |
|------|-----|--------------|-------------|
| Hclk | input | logic | System clock |
| Hresetn | input | logic | Active-low reset |
| Haddr | input | logic [`ADDR_WIDTH-1:0] | AHB address |
| Htrans | input | logic [1:0] | AHB transfer type |
| Hwrite | input | logic | AHB write flag |
| Hsize | input | logic [2:0] | AHB transfer size |
| Hburst | input | logic [2:0] | AHB burst type |
| HWdata | input | logic [`DATA_WIDTH-1:0] | AHB write data |
| Hstrob | input | logic [`DATA_WIDTH/8-1:0] | AHB write strobes |
| Hsel | input | logic | Selected for this slave |
| Hready | input | logic | Global Hready signal |
| HRdata | output | logic [`DATA_WIDTH-1:0] | Read data to bus |
| Hreadyout | output | logic | Slave-ready output |
| Hresp | output | logic [1:0] | Slave response |

Notes: Instantiates a `my_slave` module internally in this repo; adapt instantiation when replacing with a real peripheral.

---

Guidance

- When adding modules, extract port lists into this file so readers can see a quick port summary without opening RTL.

