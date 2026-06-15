---
title: "Nick Bobolea"
headline: "Replacing legacy simulation codes with *modern, reproducible Python* — from nuclear safety analysis to ocean turbulence modeling."

bio: "I build production Python tools for nuclear and environmental engineering — replacing legacy simulation codes with reproducible, accelerated runtime, and API-first engineering simulation pipelines."

contactLinks:
  - label: "GitHub"
    url: "https://github.com/alinbobolea"
    icon: "⌥"
  - label: "LinkedIn"
    url: "https://www.linkedin.com/in/nicolaebobolea/"
    icon: "◈"

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
  - name: "Aquirae"
    status: "dev"
    description: "Aquirae (Aquatic Integrated Reproducible Analysis Environment) — a local-first, reproducible workbench for aquatic-system modeling. It is the application layer above an open-source simulation engine: the first engine is the pyGOTM 1D water-column model, and the architecture is built to host additional aquatic engines later. Aquirae turns a raw engine into a usable product: reproducibility-by-construction via hash-pinned manifests that record inputs, code versions, environment, and outputs; a SQLite provenance DAG linking every artifact from raw data to published figure; a portable project-bundle format (YAML + Parquet + NetCDF + Markdown) suitable for Zenodo archival; an auto-collected citation graph; and a NiceGUI browser UI with three vantage points (Operator / Modeler / Explorer) — Time-Depth Cinematic, Scenario Comparison, Intake-Depth Advisory, Provenance Inspector, Observation Browser, YAML Editor, and Report Builder. Runs entirely on-machine, no cloud account required. The engine is consumed across a strict process boundary (subprocess CLI and stdin/stdout JSON-RPC, never a linked import), keeping the AGPL-3.0 application cleanly separated from the GPL-2.0 engine while both share one conda environment. Currently pre-alpha (v0.1.0): package layout, agent contracts, and process-boundary stubs."
    tags: ["Python", "NiceGUI", "FastAPI", "SQLite", "reproducibility", "provenance", "aquatic modeling"]
    url: ""
---

My work focuses on nuclear and environmental engineering software: accelerated physics simulation, deterministic decision engines for engineering calculations, and engineering simulation pipelines. Everything is built for auditability, numerical fidelity, and reproducibility.
