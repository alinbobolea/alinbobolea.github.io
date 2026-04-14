---
title: "Projects"

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

  - name: "NuForge"
    status: "dev"
    description: "Unified workflow orchestration for nuclear engineering simulations. YAML-driven pipelines for RETRAN, VIPRE-D, and RELAP5 — single-command execution with full SHA1 audit trails, HPC/SLURM batch support, and parametric study integration via Dakota."
    tags: ["Python", "YAML", "HPC", "SLURM", "RETRAN", "RELAP5", "nuclear"]
    url: ""

  - name: "DPRA"
    status: "dev"
    description: "Dynamic Probabilistic Risk Assessment for North Anna Units 1 & 2. Implements the full NUREG-800 Chapter 15 accident spectrum using Dynamic Event Trees (RAVEN + RELAP5-3D), time-dependent system reliability via SR2ML, and Core Damage Frequency with Birnbaum and Fussell-Vesely importance measures."
    tags: ["Python", "RAVEN", "RELAP5-3D", "probabilistic risk", "nuclear safety"]
    url: ""

  - name: "GOTHICUI"
    status: "dev"
    description: "Browser-first GUI for GOTHIC containment simulation. NiceGUI-based web interface providing interactive case setup and results visualization — eliminating the command-line workflow for nuclear containment analysis."
    tags: ["Python", "NiceGUI", "GOTHIC", "nuclear", "containment"]
    url: ""

---
