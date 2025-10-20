# AMBA AHB BUS PROTOCOL

> **Hardware AHB BUS (SystemVerilog Implementation)**
> The AMBA Advanced High-performance Bus (AHB) is a bus protocol introduced by ARM ltd. for on-chip communication between components such as microprocessors, memory interfaces, and peripherals.
>
> 🗕️ *Last updated: August 06, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---

# BLOCK DIAGRAM  
![Design Diagram](docs/image_design/ahb_protocol-Design.jpg)

# Clone the Repository 

Clone the repository using this
    
    git clone https://github.com/meds-uet/AHB-Bus

## AHB Project Structure
After cloning the repository you will have a folder structure like this
```
main
|   .gitignore
|   .readthedocs.yaml
|   LICENSE
|   mkdocs.yml
|   README.md
|
+---defines
|       parameters.svh
|
+---docs
|   |   index.md
|   |
|   +---images
|   |       rtdlogo.png
|   |
|   \---image_design
|           ahb_protocol-Arbiter DataPath.jpg
|           ahb_protocol-Arbiter FSM.jpg
|           ahb_protocol-Design.jpg
|           ahb_protocol-new arbiter.jpg
|           Overview.jpg
|
+---makefiles
|   +---linux
|   |       makefile
|   |
|   \---windows
|           clean.bat
|           run.bat
|           run.do
|
+---rtl
|       ahb_arbiter.sv
|       ahb_master_wrapper.sv
|       decoder.sv
|       master_to_slave_mux.sv
|       slave_to_master_mux.sv
|       slave_wrapper.sv
|
\---testbench
        ahb_arbiter_tb.sv
        ahb_master_wrapper_tb.sv
        decoder_tb.sv
        master_to_slave_mux_tb.sv
        slave_to_master_mux_tb.sv
```


### 📌 Folder Details
- **rtl/** → Contains RTL code for the entire AHB project.  
- **testbench/** → Contains SystemVerilog testbenches for verifying RTL modules.  
- **defines/** → Includes configuration parameters (e.g., number of masters/slaves).  
- **makefiles/** → Platform-specific scripts for running simulations.  
- **docs/** → Documentation and design diagrams.  

---

## ⚙️ Required Software

To simulate the design, you need one of the following tools:

- **Linux:** [ModelSim](https://gist.github.com/Razer6/cafc172b5cffae189b4ecda06cf6c64f)  
- **Windows:** [QuestaSim / ModelSim](https://getintopc.com/softwares/simulators/mentor-graphics-questasim-2024-free-download/)  

> ✅ Make sure to **add QuestaSim/ModelSim to your system PATH** during installation.

---

## ▶️ Running Simulations

### On Windows
1. Navigate to:

        main/makefiles/windows
2. Available scripts:
- `run.bat` → Runs the simulation.  
- `run.do` → Lets you choose which module to simulate.  
- `clean.bat` → Cleans generated files.  
3. Double-click `run.bat` to launch simulations in QuestaSim.

---

### On Linux
1. Clone the repository and navigate to the Linux makefile directory:
    ```bash
      git clone https://github.com/meds-uet/AHB-Bus
      cd AHB-Bus/makefiles/linux
      make
    ```

ModelSim or QuestaSim will automatically open and run the simulation.

## ⚡ Configuring Masters and Slaves

You can easily configure the **number of masters and slaves** for the AHB Bus by editing the parameters file.

1. Open the configuration file:

    ```
    defines/parameters.svh
    ```
    
2. Locate the following parameters(macros) (example):

    ```systemverilog
    `define NUM_MASTERS 2
    `define NUM_SLAVES 4
    ```

# AHB Bus (AMBA AHB) — SystemVerilog IP

![AHB Diagram](docs/image_design/ahb_protocol-Design.jpg)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Documentation](https://readthedocs.org/projects/ahb-bus-protocol/badge/)](https://ahb-bus-protocol.readthedocs.io/)

A compact, parameterized SystemVerilog implementation of an AMBA AHB interconnect (arbiter, decoders, master/slave wrappers and muxes) intended for academic and verification use.

Key features
- Macro-driven configuration (`defines/parameters.svh`) to choose numbers of masters/slaves and widths
- Clear RTL ↔ testbench pairing (`rtl/*.sv` and `testbench/*_tb.sv`)
- Example designs and diagrams under `docs/image_design/`

Quick start (minimal)
```bash
git clone https://github.com/meds-uet/AHB-Bus.git
cd AHB-Bus/makefiles/linux
make        # launches ModelSim/Questa and runs the default testbench (Linux)
```

Windows users: use `makefiles/windows/run.bat` or open `makefiles/windows/run.do` in Questa/ModelSim.

Full documentation
All detailed documentation (installation, theory, user & developer guides, API pages) is maintained in ReadTheDocs:

https://ahb-bus-protocol.readthedocs.io/

For developer notes, simulation flows, and diagrams see the `docs/` folder in this repo.

License: Apache-2.0
