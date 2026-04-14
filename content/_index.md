---
title: "Nick Bobolea"
headline: "Replacing legacy simulation codes with *modern, reproducible Python* — from nuclear safety analysis to ocean turbulence modeling."

bio: "I build production Python tools for nuclear and environmental engineering — replacing legacy simulation codes with reproducible, GPU-accelerated, and API-first engineering simulation pipelines."

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
    status: "dev"
    description: "Python reimplementation of the General Ocean Turbulence Model (GOTM) using Taichi for GPU-accelerated physics. Runs on CPU or GPU (CUDA/Vulkan/Metal), reads native GOTM 6.x YAML configs, includes all 22 official validation cases. Accessible via browser UI and REST API — no Fortran compiler required."
    tags: ["Python", "Taichi", "GPU", "ocean turbulence", "FastAPI", "NetCDF"]
    url: ""
---

My work focuses on nuclear and environmental engineering software: GPU-accelerated physics simulation, deterministic decision engines for engineering calculations, and engineering simulation pipelines. Everything is built for auditability, numerical fidelity, and reproducibility.
