---
title: Contributing
---

# Contributing

Guidelines
1. Make small, focused PRs. One logical change per PR.
2. Update `defines/parameters.svh` only if you also update all affected RTL and testbenches.
3. Add or update testbenches in `testbench/` for any functional change.
4. Update documentation in `docs/` when interfaces or behaviors change.
5. Use descriptive commit messages and link issues/PRs where relevant.

Reporting bugs
- Include steps to reproduce, the testbench used (or stimulus), simulator logs, and expected vs actual behavior.

Environment setup (quick)

1. Install a supported simulator (ModelSim / Questa). Add the simulator bin to your PATH.
2. (Optional) Install MkDocs for local docs preview:

```bash
pip install mkdocs mkdocs-material
```

Running simulations (quick)

Linux (ModelSim/Questa):

```bash
cd makefiles/linux
make
```

Windows (Questa/ModelSim):

```powershell
# open Questa/ModelSim and run the provided run.do or double-click run.bat
.
```

Waveform and compliance checks (required before PR)

- Run the relevant testbench and open the generated waveforms in ModelSim/Questa.
- Verify that existing waveforms are unaffected by your change for unchanged interfaces.
- Check the new feature's waveforms to ensure it follows AHB semantics: correct use of HADDR, HWDATA, HWRITE, HTRANS, HBURST, HREADY, and HRESP, and that bursts complete as expected.
- If your change alters bus widths or the macro-driven configuration in `defines/parameters.svh`, grep for dependent uses and update all affected modules and testbenches:

```bash
grep -R "NUM_MASTERS\|NUM_SLAVES\|ADDR_WIDTH\|DATA_WIDTH" -n .
```

Documentation contributions

- The detailed docs live under `docs/`. If you modify behavior or add features, update the relevant `docs/*.md` file(s). Prefer adding concise examples and link diagrams under `docs/image_design`.
- For API changes, update `docs/api_reference.md` or add per-module pages.

Code readability

- Keep code simple and well-commented. Prefer clear signal names. Follow the existing naming conventions (lower_snake for files, `_tb.sv` for testbenches).
- Avoid large, multi-purpose commits. If a refactor is required, separate refactor and functional changes into different PRs.

Reporting bugs

- Include steps to reproduce, the testbench used (or stimulus), simulator logs, and expected vs actual behavior.
