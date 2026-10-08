# launchpad-kpi

[![abap2UI5-addons](https://img.shields.io/badge/abap2UI5--addons-connector-1873b4)](https://github.com/abap2UI5-addons)
[![ABAP](https://img.shields.io/badge/ABAP-Standard%20%E2%89%A5%207.50-blue)](#installation)
[![abap2UI5](https://img.shields.io/badge/requires-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![License](https://img.shields.io/github/license/abap2UI5-addons/launchpad-kpi)](LICENSE)

**Send KPIs of your abap2UI5 apps to the SAP Fiori Launchpad.** Implement a
single interface with a single method that returns the KPI value, and the
OData service `Z2UI5_PROXY_KPI_SRV` of this repository hands it to a launchpad
tile. For developers who want their abap2UI5 apps to show a live number on
the launchpad.

> Part of [abap2UI5-addons](https://github.com/abap2UI5-addons) - addons and apps for [abap2UI5](https://github.com/abap2UI5/abap2UI5), installed with [abapGit](https://abapgit.org).

## Why

A launchpad tile reads its number from an OData `$count` call - but an
abap2UI5 app has no OData service of its own. launchpad-kpi brings one generic
OData service that creates the class named in the filter and asks it for the
count, so every app only has to implement one method.

## Installation

**Requirements**

- S/4 Private Cloud or On-Premise, or R/3 NetWeaver AS ABAP 7.50 or higher
  (Standard ABAP)
- [abap2UI5](https://github.com/abap2UI5/abap2UI5)

**Steps** - with [abapGit](https://abapgit.org), in this order:

1. [abap2UI5](https://github.com/abap2UI5/abap2UI5)
2. this repository (branch `standard`) - the interface `Z2UI5_IF_LP_KPI`, the
   sample `Z2UI5_CL_LP_KPI_HELLO_WORLD` and the OData service
   `Z2UI5_PROXY_KPI_SRV`

**Start** - call the count of the sample class:
`.../sap/opu/odata/sap/Z2UI5_PROXY_KPI_SRV/ENTITYCollection/$count?$filter=CLASS eq 'z2ui5_cl_lp_kpi_hello_world'`

## Usage

1. The launchpad-kpi addon is accessed via a single interface and method:
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
2. Include it into your app to return KPIs as shown here:
```abap
CLASS zcl_my_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_lp_kpi.
    INTERFACES z2ui5_if_app.

ENDCLASS.

CLASS zcl_my_app IMPLEMENTATION.

  METHOD z2ui5_if_lp_kpi~count.
    "kpi calculation....
    result = 10.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    "abap2UI5 app logic here...
  ENDMETHOD.

ENDCLASS.
```

3. Maintain the KPI at the Launchpad with the following endpoint:
`.../sap/opu/odata/sap/Z2UI5_PROXY_KPI_SRV/ENTITYCollection/$count?$filter=CLASS eq 'zcl_my_app'`

The sample `z2ui5_cl_lp_kpi_hello_world` also shows how to pass a second
`FILTER` condition (a JSON string) to `count` for different calculations:
`...$filter=CLASS eq 'z2ui5_cl_lp_kpi_hello_world' and FILTER eq '{ "PROP1" : "B", "PROP2" : "VAL2" }'`

## Features

* KPI Connector: Send KPIs of your abap2UI5 Apps to SAP Fiori Launchpad
* User-Friendly: Implement just a single interface and method to return the KPI value
* Project Consistency: Easily integrable with your abap2UI5 apps

## Demo

### Idea
<img width="600" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_launchpad_kpi/assets/102328295/c7db9e46-6876-40d8-a632-be79e2fbcb91">

### Preview
<img width="300" alt="Pasted Graphic 3" src="https://github.com/abap2UI5/abap2UI5-connector_launchpad_kpi/assets/102328295/1b24c31e-5570-4324-92d0-5db915394ceb">

## Limitations & Todo

* Implement a CDS/SADL based OData Service for `ABAP for Cloud` compatibility

## Contributing

Issues and pull requests are welcome! Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated.

## License

MIT - see [LICENSE](LICENSE).
