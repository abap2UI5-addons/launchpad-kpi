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

    " FILTER goes to count( ) as the caller wrote it - a JSON string whose
    " values the KPI class compares; only the class name is upper-cased
    TRY.
        DATA(lv_filter) = CONV string( lt_filter_cond[ property = `FILTER` ]-select_options[ 1 ]-low ).
      CATCH cx_root.
    ENDTRY.

    " a class that does not exist or does not implement z2ui5_if_lp_kpi is
    " answered like a missing CLASS condition, not with a short dump
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
