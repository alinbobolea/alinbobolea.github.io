---
title: "Turbulence Meets a Real Lake: What 22 Years of Lake Erken Taught pyGOTM"
date: 2026-06-15
draft: false
description: "The sequel to the pyGOTM story. I pointed my Python ocean model at one real lake for twenty-two years and it failed in a way that was almost insulting. This is how I discovered the model was only half lake-aware, fixed the physics, and learned to live with an honest FAIL that is arguably more faithful than a PASS."
tags: ["python", "oceanography", "limnology", "numerical-modeling", "fabm", "validation", "gotm"]
categories: ["software-engineering", "scientific-computing"]
slug: "pygotm-lake-erken-parity"
---

In the [first part of this story](/blog/pygotm-fortran-to-python/), I described ten weeks rewriting a forty-year-old Fortran ocean model in Python — one wrong architectural bet, one painful pivot, and one validation methodology I had to invent because the obvious one was lying to me. It ended at a pre-release: fifteen of the official reference cases passing, the physics validated, and a closing line about what came next. What came next, I wrote, was lakes. Reservoir water quality. The application layer.

I was confident about lakes. The groundwork was there: five ice thermodynamics models, the `lago_maggiore` case — a real alpine lake in northern Italy — passing Fréchet parity, and a model now hypsography-aware, taught that a lake is not a flat-bottomed box but a bowl whose cross-section shrinks with depth. As far as I was concerned, the lake story was basically finished. All that remained was to point pyGOTM at a serious lake dataset and watch it work.

So I pointed it at Lake Erken. Twenty-two years of it. And it failed in a way that was almost insulting.

This is the story of that failure. It is a story about how a model that passes fifteen carefully curated test cases can still be quietly, structurally wrong — and how only a long, ugly, real dataset will ever tell you so. It is also a story about what it means to fix the physics and *still* fail the test, on purpose, because the honest answer was a FAIL.

---

## The Case That Wouldn't Behave

Lake Erken is a shallow, turbid lake north of Stockholm, and it is one of the best-instrumented lakes in limnology. The validation case built around it is not a toy. It runs from February 1999 to December 2020 — nearly twenty-two years — at an hourly timestep. That is roughly 192,000 steps through coupled, nonlinear turbulence physics. The water column is 21 metres deep, resolved on 42 layers, and it is *hypsographic*: the lakebed slopes, so the cross-sectional area of the column changes with depth.

The light field is the detail that matters most, and I did not appreciate that at first. Lake Erken is extremely turbid. Its custom light-extinction parameters (`g2 = 1.74 m`) mean almost all of the incoming shortwave radiation is absorbed in the top two metres of water. Sunlight does not penetrate; it is consumed near the surface. The physical consequence is a summer thermocline that is unusually *sharp* and *shallow* — a thin, hard boundary between warm surface water and cold deep water. Hold that fact. It becomes the villain of the third act.

On top of the physics, the case carries a full biogeochemistry model — FABM's `selmaprotbas`, thirteen interior tracers and five benthic ones — and it reports daily means rather than instantaneous snapshots.

And then there is the twist that made this case genuinely different from anything in Part 1. The reference output did not come from the same Fortran that pyGOTM translates. pyGOTM derives from **gotm-model**, the mainline GOTM 6.0.7. The Lake Erken reference was produced by **gotm-lake** — an older, separately maintained fork with its own bundled copy of FABM, carrying lake-specific code that never made it back upstream.

In Part 1, "validate against the Fortran" meant one unambiguous thing: run the compiled binary, compare the NetCDF. Here, "the Fortran" was no longer even a single program. Now there were two *lineages* in play — and any mismatch could live in the translation, in the differences between the two Fortran codebases, in the FABM library build, or in the reporting. Not every disagreement would be a pyGOTM bug. Sorting which was which would consume most of three weeks.

---

## The Lake That Wouldn't Stratify

A healthy summer in Lake Erken builds a thermocline of about seven degrees: warm water on top, cold water below, a sharp step between them. This is the single most basic thing a lake does. If your model cannot reproduce summer stratification in a temperate lake, your model does not understand lakes.

pyGOTM produced a temperature difference, surface to bottom, of about **one tenth of one degree.**

A mixed bucket. The lake had no summer. The hypolimnion — the deep, cold layer that should sit undisturbed under the thermocline all season — came out more than four degrees too warm in August, because the heat that belonged at the surface had been stirred all the way to the bottom.

In the output, the numbers were lurid. The deep currents were five to eighty times too strong. The deep shear was, in places, several *thousand* times too large at the spring onset. That spurious deep motion generated spurious deep turbulence — turbulent kinetic energy tens of times above the physical floor — which drove a turbulent diffusivity up to three hundred times too high. With mixing that aggressive, no thermocline can survive. The model was blending the entire water column every timestep and calling it a lake.

In Part 1, my enemy was *chaos* — two correct trajectories diverging because floating-point arithmetic is not associative. This was not that. Chaos is small differences amplifying. This was large, systematic, and reproducible from the very first stratified day. This was not the model computing the right physics slightly differently. This was the model computing the wrong physics confidently.

Something was missing. Not noisy — *absent*.

---

## Half a Lake

Here is the part that still stings to write. Just days earlier, the work to make pyGOTM hypsography-aware had been done carefully and tested, and it worked. Temperature respected the lake's changing cross-section. Salinity did. The water balance — inflow, outflow, evaporation, the rising and falling surface — sat at exact parity with the reference, to the last digit. All that green looked conclusive: pyGOTM was lake-aware.

It wasn't. It was *half* lake-aware.

The **scalar** subsystem had been taught the lake — everything that moves through the water column as a concentration. But a water column is governed by two coupled worlds: the scalars, and the **momentum** — the currents, the velocities, the friction at the bed. The momentum subsystem still thought it was in the open ocean.

In an ocean column, the bottom is a flat floor far away, and bottom drag is a boundary condition applied at the deepest layer. pyGOTM's `friction.py` did exactly that: it set the drag at layer one and nowhere else. Its `u`- and `v`-equations used plain, constant-area advection and diffusion, with drag felt only at the very bottom.

But a real lake is a bowl. As you go down, the sloping bed cuts into the water column at *every* depth. The gotm-lake friction routine knows this: it distributes bottom drag across every layer the lakebed intersects, scaling each contribution by how much bed area that layer sees. The momentum equations then feel that drag as a sink at *all* depths, area-weighted by the lake's geometry.

pyGOTM's version dragged the bottom layer and left the entire interior frictionless. So the interior currents, once spun up by the wind, had nothing to damp them. They grew. The spurious shear they created fed the turbulence closure, which manufactured deep diffusivity out of nothing, which erased the thermocline. The whole catastrophe in the output traced back to a single missing idea: *a lakebed touches the water at every depth, not just the bottom.*

And the most uncomfortable detail was how *self-inflicted* the bug was. The lake's geometry had been taught to the scalars and, in the very same stretch of work, simply never carried into the momentum equations — a feature built exactly halfway. Worse, the tests had blessed it: the water balance came out at exact parity, so the finished half looked like the whole, and nothing in the suite exercised the half that was missing. The `lago_maggiore` case that passed in Part 1 isn't even hypsographic — it never touches the lake-momentum path, so it could never have caught this. A test suite can stay green because it is only testing the half you got right. It takes a long, hard, real lake — twenty-two years of wind on turbid water — to exercise the half you got wrong.

---

## The Fix, and the Discipline Around It

The repair was conceptually simple and operationally delicate: make the momentum trio lake-aware the same way the scalars already were. Distribute the bottom drag across every layer the bed intersects. Plumb the lake geometry — the per-layer areas and volumes — through the friction routine and into the `u`- and `v`-equations. Replace the constant-area advection and diffusion with their area-weighted forms, and apply the distributed drag as a sink at all levels, not just the floor.

The delicate part was *not breaking the ocean.* Fifteen passing cases and twenty-one non-lake cases had to remain bit-for-bit identical. The same instinct from Part 1 applied here — the Taichi migration's rule had been *only the acceleration layer changes.* This time the rule was: every new lake code path is gated strictly on the lake flag being set, so an ocean case takes exactly the same arithmetic path it took before, down to the last rounding. The non-lake cases stayed byte-identical, the full test suite passed, and the linters and type checker came back clean.

Then I ran Lake Erken.

The drag was now spread across all 42 layers, exactly as the reference had it. The spurious deep turbulence collapsed back to its physical floor. And the lake — for the first time — **stratified.** A summer thermocline appeared where there had been a uniform mixed bucket. Every core turbulence and density variable improved at once.

That was the moment the project felt like it had crossed from "ocean model that can sort of do lakes" to "model that actually understands a lake." It was the relief of watching a system finally behave like the physics says it should.

It was also not parity. The lake had stratified — and then it had stratified slightly *too much.*

---

## Close, But the Lake Knows

A week of teaching the model to build a thermocline had produced a model that built one a little too well. In midsummer, pyGOTM's stratification ran about two degrees too strong. On the annual mean, the surface came out roughly half a degree too warm and the bottom about a fifth of a degree too cold — a clean, telling dipole. Heat that should have mixed gently down across the thermocline was staying near the surface instead.

This is exactly the kind of small, plausible discrepancy that is most dangerous, because it is so easy to "fix" by fudging a coefficient until the number turns green. Part 1 had already taught what that costs. So the slow path it was — ruling out causes one at a time.

Was it the heating? No — the radiation and surface heat input were byte-identical between the runs; the integrated heat budgets matched. Was it the new drag formula? No — given the same velocities, the new drag matched the reference's; the small early differences were diverged currents, not a wrong equation. Was it the turbulence closure itself — was gotm-lake using different physics? This was the one I most expected to be the culprit, and the most important to settle. A file-by-file diff of the closure source between the two lineages settled it. The stability functions were **byte-identical.** The Cheng et al. 2002 coefficients at the heart of the second-order closure were **byte-identical.** Every closure knob — the quasi-equilibrium method, the stability formulation, the length-scale limiter, the Richardson-number settings — was confirmed to be read from the configuration and applied correctly at runtime. Internal-wave mixing, a common source of extra interior diffusion, was switched off in *both* runs.

Identical closure. Identical, correctly applied configuration. And still a residual.

The conclusion was not the satisfying kind. The remaining difference is most consistent with a small *numerical* difference in how the two codes resolve a very sharp, very shallow thermocline — how advection and diffusion are discretised right across that thin boundary, accumulated over twenty-two years. pyGOTM holds the slightly *sharper* gradient. And here is the uncomfortable truth: a sharper thermocline in a lake this turbid is arguably the *more* physically faithful answer, not the less. Lake Erken is the single case most exposed to this, precisely because its turbidity crams all the sunlight into the top two metres and makes the thermocline a razor's edge where any tiny mixing difference is maximally amplified. The same closure is only mildly different in the deeper, softer ocean cases.

There was no safe code fix. The closure that would have to be distorted is the *same closure* shared by the fourteen passing ocean cases. Forcing Lake Erken to match its reference would mean injecting cross-thermocline mixing that does not belong there — buying one green checkmark by breaking fourteen. The whole analysis went into the docs as a bounded lineage difference, and the physics was left alone.

---

## Owning the FAIL

So let me be plain about where the case stands, because the honest version comes first.

Lake Erken still says **FAIL.**

The verdict line is red. Of the native variables, sixty pass, five are marginal, twenty-three are discrepant, and twenty-six are broken — every broken variable in the entire suite lives in this one case. That is the literal scoreboard, and I am not going to dress it up.

But the scoreboard repays a closer look. Temperature itself — the thing a lake model exists to predict — is not broken; it is merely discrepant, with a normalized Fréchet distance of 0.123 against a fail threshold of 0.20. Density and dissipation are similar. The twenty-six broken variables are turbulence quantities sitting *just* over the 0.20 line, plus a handful of derived diagnostics that amplify small differences violently — things like the gradient Richardson number, which is a ratio that explodes wherever its denominator approaches zero. The underlying physical difference is the single mild summer-thermocline residual from the last section, refracted through two dozen sensitive variables.

There is an irony here that I have made my peace with. The Fréchet validation methodology I invented in Part 1 — the one I was so proud of for being more honest than pointwise tolerances — is now sensitive enough to flag physics I can *defend as correct* as a failure. My own honesty metric is calling my better answer a FAIL. And I am letting it, because the alternative is to widen tolerances until the truth disappears, and that is the exact failure mode the whole methodology existed to prevent. A validation suite you quietly loosen to make a case pass is not a validation suite. It is decoration.

A FAIL I understand completely, can localise to a single physical mechanism, and can argue is the more faithful result is worth infinitely more than a PASS I bought by lying. So the case fails, the documentation explains precisely why, and I sleep fine.

---

## The Biology Had Its Own Walls

The physics was only half of Lake Erken. The other half was biogeochemistry — the `selmaprotbas` model running through FABM — and it came with its own sequence of failures: two of them fixable, one deliberately left alone.

The first was satisfying. Lake Erken is the only case in the suite that reports *daily means* rather than instantaneous values. pyGOTM's FABM coupling loop had been recording a single midnight snapshot per day and labelling it the daily mean — which badly biases anything with a daily cycle. The fix was to accumulate FABM state and diagnostics across each output window and write the true window mean. Correct, and cleanly isolated to this one case.

The second was the kind of bug that is almost fun to kill once you understand it. The reference FABM clips its state variables back into their physical bounds every step — a "repair state" pass that, for instance, prevents a phosphate concentration from going negative. pyGOTM's offline coupling never did. Without it, `selmaprotbas` phosphate drifted negative, and from there the whole biogeochemistry went to NaN — by about day 96, ninety-nine percent of the values were not-a-number. Adding the repair pass, gated so it only affects the one case that asks for it, eliminated the NaN entirely and improved two dozen variables at once.

And then there was the wall that no amount of code could get through. The reference distributes its benthic fluxes — the chemistry happening at the sediment surface — over the *entire sloping lakebed*, the same way the momentum fix distributes drag. Doing that correctly requires evaluating the bottom boundary at every layer the bed intersects. And that, it turns out, requires a FABM *library* compiled with a specific build flag for variable bottom indices. The stock conda-forge `pyfabm` that pyGOTM depends on is not built with that flag; the moment the feature is used, the library raises an error saying so. On top of that, the reference's `selmaprotbas` configuration sets two lake-specific phytoplankton parameters that stock pyfabm does not even declare, so they have to be stripped out to load the configuration at all.

Rebuilding FABM from source with the right flags was an option. Declining it was itself part of the engineering: a locally rebuilt library would diverge from conda-forge, carry a maintenance burden on every FABM update, cost real performance per timestep, and — given the native thermocline residual above — would not buy a passing case anyway. The correct fix lives *upstream*, in a conda-forge pyfabm variant that enables the feature and exposes the parameters. So the two walls that were genuinely pyGOTM's got fixed, the third got a precise map, and the boundary between them got documented. Knowing which walls are yours is most of the job.

---

## Which Fortran, Exactly?

There is a quieter problem hiding in all of this, and it is the one that separates a demo from a tool you can trust.

Because the reference came from a different lineage, and because those two unsupported parameters had to be stripped to even load its configuration, the FABM configuration actually validated against is not a byte-for-byte copy of the reference's. It is a *materialized* copy — the reference settings, minus the parameters the library cannot accept. Quietly running against a modified configuration would make "reproducible validation" a lie, unless that modification is made explicit and permanent.

So the validation runner stages exactly that materialized configuration into the case bundle and records its SHA-256 hash alongside the results. Anyone who re-runs Lake Erken runs against the identical, hashed configuration, and the provenance of every difference is auditable. This is the unglamorous tax of validating against a forked lineage: you stop being able to wave at "the Fortran" as a single source of truth, and you start pinning and hashing everything, because the only honest validation is one a stranger can reproduce exactly.

---

## The Unglamorous Half

Not all of the last three weeks was dramatic physics. A good chunk of it was the connective tissue that keeps a scientific codebase from rotting — the kind of work that is tempting to skip and costly to have skipped.

Two of the largest modules — the runtime builder and the schema — were split into focused pieces under a *parity gate*: an automated test that proves the refactored code produces bit-identical output to the code before it. In a physics model, a "harmless cleanup" that silently shifts a result by one part in a billion is not harmless; the parity gate makes that class of mistake impossible to commit by accident. The mixed-layer-depth diagnostic became configurable too, after one of its variables turned out to read as completely wrong purely because the two lineages *default* to different diagnostic methods — not a physics error at all, just an unstated convention, now an explicit, defaulted setting.

None of that is the kind of thing you write a blog post about. All of it is the kind of thing that determines whether the model is still trustworthy a year from now.

---

## Coda: What a Real Lake Teaches You

Part 1 taught me that "correct" needed a new definition — that for a chaotic physical system, pointwise agreement is the wrong question and trajectory shape is the right one.

Part 2 taught me four things, and they are harder.

- The first is that "lake-aware" had to be true of the *whole* model, not half of it. I had taught the scalars about the lake and assumed the lesson had spread. It hadn't. A system is only as physical as its least physical subsystem, and the momentum equations had been quietly living in the ocean the entire time.

- The second is that curated test cases lie by omission. Fifteen green cases told me the lakes worked. One real lake, run for two decades, found the bug all fifteen had been too gentle to expose. There is no substitute for a long, ugly, real dataset. It does not care what your test suite says.

- The third is that the honest verdict is sometimes FAIL even when the physics got *better*. The model improved, the validation got harder to pass, and the right move was to let it fail loudly and explain why, rather than soften the metric until the failure vanished. A measurement you adjust to flatter yourself has stopped being a measurement.

- The fourth is that part of the work is knowing which walls are yours. Some failures are bugs in your code, and you fix them. Some are limitations of the libraries beneath you, and the honest, disciplined move is to document them precisely and push the fix upstream rather than fork the world to chase one green checkmark.

The lake does not care about any of this. It stratifies the way the physics says it stratifies, every summer, in twenty-one metres of turbid water north of Stockholm. My job was never to make a number turn green. It was to compute that lake as faithfully as forty years of accumulated turbulence physics allows — and then to be ruthlessly honest about the last half-degree I cannot yet match, and exactly why.

The bridge from Fortran to Python is still the point. A model the next generation of limnologists can read, run, and trust — without a compiler, and without taking my word for any of it — is worth more for failing honestly than it would be for passing quietly. The lake will still be there when the upstream fixes land. So will the parity report, telling the truth in red.

---

*[pyGOTM](https://github.com/alinbobolea/pygotm) is my open-source project. The full Lake Erken parity analysis — every variable, every ruled-out cause, and the exact reproduction commands — lives in the project's [validation documentation](/docs/pygotm/). The Fortran lineages it is measured against are maintained by the GOTM community at [gotm.net](https://gotm.net). If you missed it, [Part 1](/blog/pygotm-fortran-to-python/) is the ten-week origin story.*
