CLASS z2ui5_cl_lp_kpi_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_lp_kpi_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entityset
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_lp_kpi_dpc_ext IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.

    DATA lt_result TYPE z2ui5_cl_lp_kpi_mpc=>tt_entity.
    DATA lt_filter_cond TYPE /iwbep/if_mgw_req_filter=>ty_t_mgw_select_option.
        DATA lv_classname TYPE string.
        FIELD-SYMBOLS <temp1> LIKE LINE OF lt_filter_cond.
        DATA temp6 LIKE sy-tabix.
        FIELD-SYMBOLS <temp2> LIKE LINE OF <temp1>-select_options.
        DATA temp7 LIKE sy-tabix.
        DATA temp1 TYPE z2ui5_cl_lp_kpi_mpc=>ts_entity.
        DATA lv_filter TYPE string.
        FIELD-SYMBOLS <temp7> LIKE LINE OF lt_filter_cond.
        DATA temp8 LIKE sy-tabix.
        FIELD-SYMBOLS <temp8> LIKE LINE OF <temp7>-select_options.
        DATA temp9 LIKE sy-tabix.
    DATA temp2 TYPE REF TO cl_abap_intfdescr.
    DATA lo_kpi_intf LIKE temp2.
    DATA lo_type TYPE REF TO cl_abap_typedescr.
      DATA temp3 TYPE z2ui5_cl_lp_kpi_mpc=>ts_entity.
    DATA li_proxy_kpi TYPE REF TO z2ui5_if_lp_kpi.
        DATA temp4 TYPE z2ui5_cl_lp_kpi_mpc=>ts_entity.
    DATA lv_count TYPE i.
      DATA temp5 TYPE z2ui5_cl_lp_kpi_mpc=>ts_entity.
    lt_filter_cond = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    TRY.



        temp6 = sy-tabix.
        READ TABLE lt_filter_cond WITH KEY property = `CLASS` ASSIGNING <temp1>.
        sy-tabix = temp6.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.


        temp7 = sy-tabix.
        READ TABLE <temp1>-select_options INDEX 1 ASSIGNING <temp2>.
        sy-tabix = temp7.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_classname   = to_upper( <temp2>-low ).
      CATCH cx_root.

        CLEAR temp1.
        temp1-id = `ERROR_NO_PARAMETER_FOUND_WITH_NAME_CLASS`.
        INSERT temp1 INTO TABLE lt_result.
        copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
        RETURN.
    ENDTRY.

    TRY.



        temp8 = sy-tabix.
        READ TABLE lt_filter_cond WITH KEY property = `FILTER` ASSIGNING <temp7>.
        sy-tabix = temp8.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.


        temp9 = sy-tabix.
        READ TABLE <temp7>-select_options INDEX 1 ASSIGNING <temp8>.
        sy-tabix = temp9.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_filter = to_upper( <temp8>-low ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " The class name comes from the request, so only a class that implements
    " z2ui5_if_lp_kpi is ever created. That is checked here, before CREATE
    " OBJECT: the typed reference below would refuse any other class too, but
    " only once the runtime got that far - this way no other class is ever
    " instantiated. A class that does not exist or does not implement the
    " interface is answered like a missing CLASS condition, not with a dump.

    temp2 ?= cl_abap_typedescr=>describe_by_name( `Z2UI5_IF_LP_KPI` ).

    lo_kpi_intf = temp2.

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_classname
                                         RECEIVING  p_descr_ref    = lo_type
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF    sy-subrc <> 0
       OR lo_type->kind <> cl_abap_typedescr=>kind_class
       OR lo_kpi_intf->applies_to_class( lv_classname ) = abap_false.

      CLEAR temp3.
      temp3-id = `ERROR_NO_KPI_CLASS_FOUND_WITH_THIS_NAME`.
      INSERT temp3 INTO TABLE lt_result.
      copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
      RETURN.
    ENDIF.


    TRY.
        CREATE OBJECT li_proxy_kpi TYPE (lv_classname).
      CATCH cx_sy_create_object_error cx_sy_move_cast_error.

        CLEAR temp4.
        temp4-id = `ERROR_NO_KPI_CLASS_FOUND_WITH_THIS_NAME`.
        INSERT temp4 INTO TABLE lt_result.
        copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
        RETURN.
    ENDTRY.

    lv_count = li_proxy_kpi->count( lv_filter ).

    DO lv_count TIMES.

      CLEAR temp5.
      temp5-id = sy-index.
      INSERT temp5 INTO TABLE lt_result.
    ENDDO.

    copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).

  ENDMETHOD.

ENDCLASS.
