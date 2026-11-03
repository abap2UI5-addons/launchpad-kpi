---
layout: home

hero:
  name: "Launchpad KPI"
  text: "Show KPIs of your apps on Fiori Launchpad tiles."
  image:
    src: /favicon.png
    alt: abap2UI5
  actions:
    - theme: brand
      text: Get started
      link: /guide
    - theme: alt
      text: GitHub
      link: https://github.com/abap2UI5-addons/launchpad-kpi
    - theme: alt
      text: All addons
      link: https://abap2ui5-addons.github.io/

features:
  - title: "Generic OData service Z2UI5_PROXY_KPI_SRV answers $count for the class in the filter"
  - title: "Implement one interface and one method (z2ui5_if_lp_kpi~count) in your app"
  - title: "Optional FILTER parameter as a JSON string for different calculations"
  - title: "Sample class Z2UI5_CL_LP_KPI_HELLO_WORLD included"
---

## What it does

A connector that lets an abap2UI5 app show a live number on a SAP Fiori Launchpad tile. A tile reads its number from an OData $count call, which an abap2UI5 app does not have; this repository brings the generic OData service Z2UI5_PROXY_KPI_SRV, which creates the class named in the filter and asks it for the count. Every app only has to implement the interface Z2UI5_IF_LP_KPI with its method count. A second FILTER condition in the OData call can pass a JSON string for different calculations.

## Requirements

- S/4 Private Cloud or On-Premise, or R/3 NetWeaver AS ABAP 7.50 or higher (Standard ABAP)
- NetWeaver 7.02 - 7.40: the downported branch 702
- abap2UI5
- ABAP for Cloud: not yet, a CDS/SADL based OData service is on the todo list

## Installation

With [abapGit](https://abapgit.org), from [the repository](https://github.com/abap2UI5-addons/launchpad-kpi):

- Install with abapGit in this order: abap2UI5, then this repository from branch standard
- Brings the interface Z2UI5_IF_LP_KPI, the sample Z2UI5_CL_LP_KPI_HELLO_WORLD and the OData service Z2UI5_PROXY_KPI_SRV
- Test with .../sap/opu/odata/sap/Z2UI5_PROXY_KPI_SRV/ENTITYCollection/$count?$filter=CLASS eq 'z2ui5_cl_lp_kpi_hello_world'
- Maintain the tile at the launchpad with the same $count endpoint and your class name in the CLASS filter

The [Guide](/guide) has every step.

## A first app

```abap
INTERFACE z2ui5_if_lp_kpi
  PUBLIC.

  METHODS count
    IMPORTING
      filter        TYPE string
    RETURNING
      VALUE(result) TYPE i.

ENDINTERFACE.
```

## Links

- [abap2UI5](https://github.com/abap2UI5/abap2UI5)
- [The repository](https://github.com/abap2UI5-addons/launchpad-kpi) - issues and pull requests welcome
