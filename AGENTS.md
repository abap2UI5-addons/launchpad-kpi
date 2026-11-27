# AGENTS.md

launchpad-kpi sends KPIs of abap2UI5 apps to the SAP Fiori Launchpad: an app
implements `z2ui5_if_lp_kpi~count( )`, and the generic OData service
`Z2UI5_PROXY_KPI_SRV` creates the class named in the `$filter` and answers
its count to a launchpad tile. README.md is the user documentation; keep it
and this file in step.

## Layout

| Path | Purpose |
| --- | --- |
| `src/z2ui5_if_lp_kpi.intf.abap` | The one interface an app implements - its contract, never change the signature of `count( )` |
| `src/z2ui5_cl_lp_kpi_hello_world.clas.abap` | The sample app with a KPI |
| `src/01/` | The Gateway project `Z2UI5_PROXY_KPI` (IWPR), its model and service (IWMO, IWOM, IWSV, IWSG) and the generated classes `Z2UI5_CL_LP_KPI_MPC(_EXT)` / `_DPC(_EXT)` |
| `site/` | The documentation site (VitePress) - https://abap2ui5-addons.github.io/launchpad-kpi/ |

The default branch is **`standard`**, not `main`; `702` is downported from it
on every push (`ci-702.yaml`).

## Rules

- **The SEGW objects are generated.** Change the model in SEGW on a system
  and pull it back with abapGit; never edit the IWPR/IWMO XML or the
  `_MPC` / `_DPC` classes by hand. Code of our own goes into `_DPC_EXT`.
- **No ICF node in the repository.** The service name has 19 characters and
  an ICF node at most 15 - the system creates the node under
  `/sap/opu/odata/sap/` with a name of its own when the service is activated
  in `/IWFND/MAINT_SERVICE`.
- **Standard ABAP only.** Gateway (`/IWBEP/`) does not exist on ABAP Cloud;
  there is no cloud lint here (abaplint for Cloud reports 12 issues, every
  one of them the missing `/IWBEP/` super classes and interfaces), and the
  transpiler cannot build the SEGW
  classes (their super classes are void) - abap2UI5's backlog
  `transpiler-void-superclass`.
- **No namespace rename.** abaplint cannot rename the Gateway objects
  (abap2UI5's backlog `abap2ui5-addon-rename-gaps`).

## Commands

```sh
npm ci
npm run check   # abaplint and the abap2UI5-linter, what CI runs
npm run site    # the documentation site into build/site
```

## CI

CI comes from the shared CI template of abap2UI5-addons (reusable workflows in
[rap-ext](https://github.com/abap2UI5-addons/rap-ext/blob/main/.github/ci/README.md),
pinned by commit in the `uses:` lines and moved by `bump-deps`), triggered
from `standard`:

* `ci` - on every push to `standard`, every pull request, weekly and by
  hand: `check / abaplint (./abaplint.jsonc)` and `check / abap2ui5lint`
  (`abap2ui5lint.jsonc`: every class, no render gate - there is no view; it
  checks what is used from abap2UI5). These are the required status checks
  of the branch protection. The call passes `branch: standard`, the branch
  the template publishes badges from. The linter's baseline holds one finding in the
  generated `z2ui5_cl_lp_kpi_mpc` (`default-key-table`), which is never
  edited by hand.
* `ci-702` - on every push to `standard` `npm run auto_downport`, a
  force-push to the branch `702`, then abaplint on that branch
  (`.github/abaplint/abap_702.jsonc`). Never commit to `702` by hand.
* `bump-deps` (monthly; the template pin moves only with the `DEPS_TOKEN`
  secret).
* `deploy-pages` - the template's `addon-pages.yaml` (since ci-v1.1.0) with
  `branch: standard`: a pull request builds the site, a push to `standard`
  deploys it.

No ABAP Cloud lint (Gateway, above), no unit tests, no rename, no
`.github/deps.json`.

English for code, comments, commit messages and pull requests. The wider
rules live in abap2UI5's
[CONVENTIONS.md](https://github.com/abap2UI5/abap2UI5/blob/main/.github/shared/CONVENTIONS.md).
