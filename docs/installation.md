---
title: Installation
---

# Installation

Required tools
- ModelSim or QuestaSim for SystemVerilog simulation.
- MkDocs (optional) to build the documentation locally.

Linux (ModelSim/Questa)
1. Install ModelSim/Questa and add the binary to your PATH.
2. From the repository root:

```bash
cd makefiles/linux
make
```

Windows (Questa/ModelSim)
1. Install Questa/ModelSim and add it to your PATH.
2. Use `makefiles/windows/run.bat` or open `makefiles/windows/run.do` inside the simulator.

Local docs (MkDocs)
```bash
pip install mkdocs mkdocs-material
mkdocs serve
```
