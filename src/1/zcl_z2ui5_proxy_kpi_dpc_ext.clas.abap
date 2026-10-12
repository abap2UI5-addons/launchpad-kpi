CLASS zcl_z2ui5_proxy_kpi_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_z2ui5_proxy_kpi_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entityset
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_z2ui5_proxy_kpi_dpc_ext IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.

    DATA lt_result TYPE zcl_z2ui5_proxy_kpi_mpc=>tt_entity.
    DATA(lt_filter_cond) = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    TRY.
        DATA(lv_classname)   = to_upper( lt_filter_cond[ property = `CLASS` ]-select_options[ 1 ]-low ).
      CATCH cx_root.
        INSERT VALUE #( id = `ERROR_NO_PARAMETER_FOUND_WITH_NAME_CLASS` ) INTO TABLE lt_result.
        copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
        RETURN.
    ENDTRY.

    TRY.
        DATA(lv_filter) = to_upper( lt_filter_cond[ property = `FILTER` ]-select_options[ 1 ]-low ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " The class name comes from the request, so only a class that implements
    " z2ui5_if_lp_kpi is ever created. That is checked here, before CREATE
    " OBJECT: the typed reference below would refuse any other class too, but
    " only once the runtime got that far - this way no other class is ever
    " instantiated. A class that does not exist or does not implement the
    " interface is answered like a missing CLASS condition, not with a dump.
    DATA(lo_kpi_intf) = CAST cl_abap_intfdescr( cl_abap_typedescr=>describe_by_name( `Z2UI5_IF_LP_KPI` ) ).
    DATA lo_type TYPE REF TO cl_abap_typedescr.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_classname
                                         RECEIVING  p_descr_ref    = lo_type
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF    sy-subrc <> 0
       OR lo_type->kind <> cl_abap_typedescr=>kind_class
       OR lo_kpi_intf->applies_to_class( lv_classname ) = abap_false.
      INSERT VALUE #( id = `ERROR_NO_KPI_CLASS_FOUND_WITH_THIS_NAME` ) INTO TABLE lt_result.
      copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
      RETURN.
    ENDIF.

    DATA li_proxy_kpi TYPE REF TO z2ui5_if_lp_kpi.
    TRY.
        CREATE OBJECT li_proxy_kpi TYPE (lv_classname).
      CATCH cx_sy_create_object_error cx_sy_move_cast_error.
        INSERT VALUE #( id = `ERROR_NO_KPI_CLASS_FOUND_WITH_THIS_NAME` ) INTO TABLE lt_result.
        copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).
        RETURN.
    ENDTRY.
    DATA(lv_count) = li_proxy_kpi->count( lv_filter ).

    DO lv_count TIMES.
      INSERT VALUE #( id = sy-index ) INTO TABLE lt_result.
    ENDDO.

    copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).

  ENDMETHOD.

ENDCLASS.
