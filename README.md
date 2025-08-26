# AMBA AHB BUS PROTOCOL

> **Hardware AHB BUS (SystemVerilog Implementation)**
> The AMBA Advanced High-performance Bus (AHB) is a bus protocol introduced by ARM ltd. for on-chip communication between components such as microprocessors, memory interfaces, and peripherals.
>
> 🗕️ *Last updated: August 06, 2025*
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet). Licensed under the Apache 2.0 License.

---

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
3. Modify these values as per your design requirements.
For example, to configure 3 masters and 5 slaves:
    ```systemverilog
    `define NUM_MASTERS 3
    `define NUM_SLAVES 5
    ```
4. Save the file and rerun the simulation using the provided makefiles.

# Documentation

- [Documentation](https://ahb-bus-protocol.readthedocs.io/en/latest/)

# Licensing

Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-uet)**

---