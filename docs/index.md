# AMBA AHB BUS PROTOCOL

> **Hardware AHB BUS (SystemVerilog Implementation)**
> The AMBA Advanced High-performance Bus (AHB) is a bus protocol introduced by ARM ltd. for on-chip communication between components such as microprocessors, memory interfaces, and peripherals.
>
> 🗕️ *Last updated: July 29, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---

The AMBA Advanced High-performance Bus (AHB) is a bus protocol introduced by ARM ltd. for on-chip communication between components such as microprocessors, memory interfaces, and peripherals. AHB is a high-performance bus protocol and is the de facto standard for on-chip communication in the majority of modern digital design systems. The AHB protocol is a synchronous, multi-master, multi-slave bus protocol which can operate at a maximum frequency of 1 GHz.

## Components of AHB
- **Arbiter**: Manages access to the bus, ensuring that only one master can use the bus at a time.
- **Master**: Initiates read and write operations by providing address and control signals.
- **Slave**: Responds to master requests, providing data for read operations or receiving data for write operations.
- **Decoder**: Determines which slave the master intends to communicate with, based on the address provided.
- **Bus**: The physical interconnect that carries data, address, and control signals between components.
- **Master to Slave Multiplexer (MSMUX)**: A multiplexer that selects the master that is currently accessing the bus.
- **Slave to Master Multiplexer (SMMUX)**: A multiplexer that selects the slave that is currently being accessed by the master.

The main component of this protocol is **Arbiter** that controls the flow of **Data, Address** and **Control Signals**

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

