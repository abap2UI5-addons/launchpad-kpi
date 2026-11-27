# Contributing

Send KPIs of your abap2UI5 apps to the SAP Fiori Launchpad.

## Before you open a pull request

Run what CI runs:

```sh
npm ci
npm run check
```

`npm run check` is the set of steps the workflows run on a pull request, so a
green run locally is a green run there.

## What the gates are

| Gate | What it proves |
| --- | --- |
| `npm run lint` | abaplint over `src/`, resolved against the abap2UI5 core |
| `npm run check:702` | the 7.02 downport: a scratch copy of `src/` in `build/702`, downported and linted with `.github/abaplint/abap_702.jsonc` (`.github/scripts/check-702.sh`) - `src/` is never rewritten |

The OData service and its generated classes cannot be checked without a system. Say in the pull request whether the change was tried on a launchpad tile.

## Conventions

English for code, comments, commit messages and pull requests. Commit subjects
are written in the imperative and describe the outcome, not the mechanics. One
topic per pull request. The wider rules the whole ecosystem follows live in
[abap2UI5's CONVENTIONS.md](https://github.com/abap2UI5/abap2UI5/blob/main/.github/shared/CONVENTIONS.md).
