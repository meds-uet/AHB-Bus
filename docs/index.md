# AMBA AHB BUS PROTOCOL

> **Hardware AHB BUS (SystemVerilog Implementation)**
> The **AMBA AHB (Advanced High-performance Bus)** is a high-speed bus protocol introduced by ARM ltd. for efficient on-chip communication between components such as microprocessors, memory interfaces, and peripherals.
>
> 🗕️ *Last updated: July 29, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---

The AMBA Advanced High-performance Bus (AHB) is a bus protocol introduced by ARM ltd. for on-chip communication between components such as microprocessors, memory interfaces, and peripherals. AHB is a high-performance bus protocol and is the de facto standard for on-chip communication in the majority of modern digital design systems. The AHB protocol is a synchronous, multi-master, multi-slave bus protocol.

## Components of AHB
- **Arbiter**: Manages access to the bus, ensuring that only one master can use the bus at a time.

- **Master**: Initiates read and write operations by providing address and control signals.

- **Slave**: Responds to master requests, providing data for read operations or receiving data for write operations.

- **Bus**: The physical interconnect that carries data, address, and control signals between components.

- **Decoder**: Determines which slave the master intends to communicate with, based on the address provided.

- **Master to Slave Multiplexer (MSMUX)**: A multiplexer that selects the master that is currently accessing the bus.

- **Slave to Master Multiplexer (SMMUX)**: A multiplexer that selects the slave that is currently being accessed by the master.



## Main Features of AHB Bus Protocol

The AHB Protocol Features that are supported are given as follow :


### ✅ 1. Single Clock Edge Operation
- All operations are synchronized to the **rising edge** of a single system clock.

- Simplifies timing analysis and enhances performance.

---

### 🚀 2. Burst Transfers
- Supports **burst types**: `SINGLE`, `INCR`, `WRAP4`, `INCR4`, `INCR8`, `INCR16`, etc.

- Improves efficiency by reducing address/control overhead during sequential data transfers.

---

### 🔁 3. Pipelined Operation
- AHB supports pipelining with separate **address phase** and **data phase**.

- Enables a new transfer to begin before the previous one completes.

- Improves throughput significantly.

---

### 📥 4. Multi-Master Support
- Supports multiple bus masters like CPU, DMA, etc.

- Masters use an **arbitration mechanism** (external to AHB) to gain control of the bus.

- Only one master can drive the bus at any time.

---

### 🔀 5. Address and Data Bus Multiplexing
- AHB uses shared lines for address and data (i.e., bus multiplexing).

- Reduces the number of physical signals/pins.

---

### 📦 6. 32-bit or 64-bit Data Bus
- Data bus is typically **32-bit wide**, but can also be extended to **64 bits** or more for higher performance.

---

### ❗ 7. Error Reporting via HRESP
The `HRESP` signal returns response status:

  - `OKAY` – Normal transfer
  - `ERROR` – Error occurred

---

### 🧠 8. External Arbitration Logic
- Arbitration between masters is handled **outside** the AHB bus.

- Common schemes: fixed-priority, round-robin, or custom.

---

### 📶 9. Transfer Types

- **IDLE** – No transfer
- **BUSY** – Pipeline stall (no address phase)
- **NONSEQ** – Start of a new transfer or burst
- **SEQ** – Sequential transfer within a burst

---

### 🎯 10. Handshaking Between Master and Slave
- `HREADY` and `HRESP` signals coordinate data transfers.

- Master waits if slave is not ready.

---

### 📋 11. Memory-Mapped Support
- AHB is designed for **memory-mapped peripheral access**.

- Each device is assigned a specific address region.

---

## 📊 Summary Table

| Feature              | Description                                      |
|----------------------|--------------------------------------------------|
| Pipelined            | Yes (address/data phases separated)              |
| Burst transfers      | Supported (SINGLE, INCR, WRAP, etc.)             |
| Arbitration          | External (master-side)                           |
| Bus width            | 32 or 64 bits                                    |
| Multi-master support | Yes                                              |
| Response types       | OKAY, ERROR,                        |
| Transfer types       | IDLE, BUSY, NONSEQ, SEQ                          |
| Handshaking          | HREADY and HRESP                                 |
| Clocking             | Single rising-edge clock                         |
| Address mapping      | Fully memory-mapped device space                 |

---
### 🧠 Tip
\
AHB sits between **APB (simple)** and **AXI (advanced)** in terms of complexity and performance.

---

# Component Description
This section goes over the description of each of the components used in the AHB bus protocol.

Since the main component of this protocol is **Arbiter** that controls the flow of **Data, Address** and **Control Signals** so lets start with this

---

## Arbiter

The Arbiter is a critical component of the AHB protocol. It is responsible for managing access to the bus, ensuring that only one master can use the bus at a time. The Arbiter is responsible for resolving conflicts between multiple masters who wish to access the bus simultaneously. It does this by implementing a bus allocation algorithm, which determines which master will be granted access to the bus for a given transaction.

The Arbiter accepts bus requests from multiple masters and grants access to the bus based on its bus allocation algorithm. It can grant access to the bus to a single master at a time, or it can grant access to multiple masters simultaneously if the bus is not busy.

The Arbiter is also responsible for handling priority of the bus requests. It can prioritize bus requests based on the requirements of the system. For example, in a system with a high priority interrupt handler, the Arbiter can grant access to the bus to the interrupt handler before any other master.


### Allocation Algorithm
The allocation algorithm used in the Arbiter is a Round Robin priority algorithm. It works as follows:

- The Arbiter keeps track of the priority of each master.

- When only a single master requests the bus, it is granted the access.

- When multiple masters request the bus at the same time, the Arbiter grants the bus to the highest priority master.

- If the highest priority master does not have a valid request, the Arbiter moves to the next highest priority master.

- If all masters have a valid request, the Arbiter grants the bus to each master in round robin order.

- If a master does not have a valid request when it is its turn, the Arbiter moves to the next highest priority master.

- It allows only one burst from one master in a single request.

## Slave Module

This module implements a wrapper for a slave device, providing a standardized interface to the AHB bus. The module maps the input and output signals to the selected slave, allowing for easy integration with the rest of the system.

### Features

* Provides a standardized interface to the AHB bus
* Maps input and output signals to the selected slave
* Supports a single slave device

## Bus

The bus sits between the masters and slaves, responsible for connecting the correct master to the correct slave. This is the shared resource whose access is granted by the arbiter. This contains the interconnect, decoder and the arbiter.

The decoder gives the appropriate signals to select which slave is active, the arbiter decides which master is active, the interconnect routes the signals from the active master to the selected slave according to the signals provided by the arbiter and decoder.


## Decoder

This module is a decoder for the AHB bus. Its main purpose is to use the address to select which slave device should be active at a given time. This is a fundamental part of bus systems, ensuring that data and commands go to the correct destination on the bus.

## Master-To-Slave Multiplexer Module

The master_to_slave_mux module is a multiplexer for AHB bus systems. 
It selects and forwards address, data, and control signals from the currently active bus master to the shared bus lines, based on an arbitration signal. 

This ensures only one master controls the bus at any time, enabling safe and efficient multi-master communication.

This module implements a master-to-slave multiplexer, allowing a single master interface to be connected to multiple slaves. The module is designed to distribute the master's requests to the selected slave.

### Features

* Supports a single master interface connected to multiple slaves
* Parameterized to support a variable number of slaves
* Implements a multiplexer to select the target master for the transfer.

## Slave-To-Master Multiplexer Module

The slave_to_master_mux module implements a multiplexer that connects multiple slave devices to a single master interface on an AHB bus. 
It selects one slave's data, response, and ready signals based on a selection input, ensuring that only the chosen slave communicates with the master at any time. 

The module is parameterized to support a variable number of slaves, making it easily configurable for different system architectures.

This is essential in bus systems to manage access when multiple devices share a communication channel.

### Features

* Supports multiple slaves connected to a single master interface
* Parameterized to support a variable number of slaves
* Implements a multiplexer to select the active slave