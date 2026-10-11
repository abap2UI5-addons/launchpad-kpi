CLASS z2ui5_cl_lp_kpi_hello_world DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_lp_kpi.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_lp_kpi_hello_world IMPLEMENTATION.


  METHOD z2ui5_if_lp_kpi~count.

    "way1 - simple version, just use the classname
    "https://<<system>>/sap/opu/odata/sap/Z2UI5_PROXY_KPI_SRV/ENTITYCollection/$count?$filter=CLASS eq 'z2ui5_cl_lp_kpi_hello_world'
    result = 12.


    "way2 - use the importing parameter for different calculations and results
    "https://<<system>>/sap/opu/odata/sap/Z2UI5_PROXY_KPI_SRV/ENTITYCollection/$count?$filter=CLASS eq 'z2ui5_cl_lp_kpi_hello_world' and FILTER eq '{ "PROP1" : "B", "PROP2" : "VAL2" }'
    TRY.
        DATA lr_val TYPE REF TO data.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json             = filter                 " JSON string
          CHANGING
            data             = lr_val                 " Data to serialize
        ).

        ASSIGN ('LR_VAL->PROP1->*') TO FIELD-SYMBOL(<prop1>).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        CASE <prop1>.
          WHEN `A`.
            result = 10.
          WHEN `B`.
            result = 20.
        ENDCASE.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
