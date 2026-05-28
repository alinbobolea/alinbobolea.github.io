---
title: "Projects"

projects:
  - name: "htcie"
    status: "complete"
    description: "Heat Transfer Correlation Intelligence Engine. Deterministic, API-first correlation selection for single-phase convection — evaluates 13 correlations, ranks them with a reproducible scoring model, and reports confidence based on inter-method spread. Full traceability. Validated against Incropera 7th ed."
    tags: ["Python", "Pydantic", "heat transfer", "engineering", "traceability"]
    url: "/docs/htcie/"

  - name: "pyGOTM"
    status: "complete"
    description: "Python + Numba reimplementation of the General Ocean Turbulence Model (GOTM). Compiled single-column 1D ocean and lake physics — mean flow, turbulence closures (k-ε, k-ω, GLS, Mellor-Yamada), air-sea exchange, five ice thermodynamics models (including Winton three-layer sea ice and Holland-Jenkins ice-shelf basal melt), and FABM/pyfabm biogeochemistry coupling. Reads GOTM 6.x YAML configurations natively. Validates NetCDF output against Fortran GOTM 6.0.7 reference using a Fréchet-distance pipeline — all 22 official cases execute, default validation set (couette, channel, entrainment) passes. CLI, Python API, and warm JSON-RPC stdin/stdout daemon. No Fortran compiler required."
    tags: ["Python", "Numba", "ocean turbulence", "NetCDF", "FABM", "validation", "scientific computing"]
    url: "/docs/pygotm/"

  - name: "pyGOTM Studio"
    status: "dev"
    description: "Local-first scientific workbench built around the pyGOTM kernel. Turns the simulation engine into a usable product: hash-pinned reproducibility manifests, a SQLite provenance DAG linking every artifact from raw data to published figure, a project bundle format (YAML + Parquet + NetCDF + Markdown) designed for Zenodo archival, and a NiceGUI browser UI with three vantage points (Operator / Modeler / Explorer). Includes a time-depth cinematic, scenario comparison, observation QC browser, YAML editor, report builder, and auto-collected citation graph. Runs entirely on-machine — no cloud account required. GPL/MIT process boundary: Studio calls the kernel via subprocess CLI and JSON-RPC, never as a linked import."
    tags: ["Python", "NiceGUI", "FastAPI", "SQLite", "scientific computing", "provenance", "ocean modeling"]
    url: ""
---
