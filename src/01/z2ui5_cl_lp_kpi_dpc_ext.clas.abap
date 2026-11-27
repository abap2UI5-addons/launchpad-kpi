CLASS z2ui5_cl_lp_kpi_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_lp_kpi_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entityset
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
    "! Up to this count a $count request still gets one row per counted item
    "! next to the response context's COUNT (see count_to_response)
    CONSTANTS c_rows_max TYPE i VALUE 1000.

    "! A $count request - the launchpad tile's - is answered with the number
    "! in the response context's COUNT, which Gateway answers $count with,
    "! and a large count builds no rows: a KPI of 200,000 would otherwise
    "! build 200,000 entities on every tile refresh. HAS_COUNT and COUNT are
    "! both looked up dynamically - a Gateway release without them (or a
    "! call that fails) gets the rows as before. Up to c_rows_max the rows
    "! are built anyway, so a small count comes out the same on a Gateway
    "! that counts the returned rows instead.
    "!
    "! @parameter build_rows | abap_false when the count alone answers the request
    METHODS count_to_response
      IMPORTING
        request    TYPE REF TO object
        count      TYPE i
      EXPORTING
        build_rows TYPE abap_bool
      CHANGING
        response   TYPE any.

    "! An error is answered as an OData error (HTTP 400) and never as an
    "! entity set: a pseudo row would make $count answer 1, and the
    "! launchpad tile would show that 1 as if it were the KPI. Returned and
    "! not raised here, so every exit of get_entityset stays visible where
    "! it happens.
    METHODS bad_request
      IMPORTING
        message       TYPE string
        previous      TYPE REF TO cx_root OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO /iwbep/cx_mgw_busi_exception.
ENDCLASS.



CLASS z2ui5_cl_lp_kpi_dpc_ext IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.

    DATA lt_result TYPE z2ui5_cl_lp_kpi_mpc=>tt_entity.
    DATA lx_error TYPE REF TO /iwbep/cx_mgw_busi_exception.
    DATA lx_root TYPE REF TO cx_root.
    DATA lv_classname TYPE string.
    DATA lv_filter TYPE string.

    " Read without table expressions: the 702 downport turns a failed one
    " into an ASSERT, so the optional FILTER would dump there when missing.
    " FILTER is handed to count( ) as it was sent - free text (the sample
    " reads it as JSON) whose case is the app's business; only the class
    " name is upper-cased.
    DATA(lt_filter_cond) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
    LOOP AT lt_filter_cond REFERENCE INTO DATA(lr_cond).
      READ TABLE lr_cond->select_options REFERENCE INTO DATA(lr_option) INDEX 1.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CASE lr_cond->property.
        WHEN `CLASS`.
          lv_classname = to_upper( lr_option->low ).
        WHEN `FILTER`.
          lv_filter = lr_option->low.
      ENDCASE.
    ENDLOOP.

    IF lv_classname IS INITIAL.
      lx_error = bad_request( `The $filter needs a condition CLASS eq '<class name>'.` ).
      RAISE EXCEPTION lx_error.
    ENDIF.

    " The class name comes from the request, so only a class that implements
    " z2ui5_if_lp_kpi is ever created. That is checked here, before CREATE
    " OBJECT: the typed reference below would refuse any other class too, but
    " only once the runtime got that far - this way no other class is ever
    " instantiated. A class that does not exist or does not implement the
    " interface is answered with an error, not with a dump.
    DATA(lo_kpi_intf) = CAST cl_abap_intfdescr( cl_abap_typedescr=>describe_by_name( `Z2UI5_IF_LP_KPI` ) ).
    DATA lo_type TYPE REF TO cl_abap_typedescr.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_classname
                                         RECEIVING  p_descr_ref    = lo_type
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF    sy-subrc <> 0
       OR lo_type->kind <> cl_abap_typedescr=>kind_class
       OR lo_kpi_intf->applies_to_class( lv_classname ) = abap_false.
      lx_error = bad_request( |No class { lv_classname } that implements Z2UI5_IF_LP_KPI.| ).
      RAISE EXCEPTION lx_error.
    ENDIF.

    DATA li_proxy_kpi TYPE REF TO z2ui5_if_lp_kpi.
    TRY.
        CREATE OBJECT li_proxy_kpi TYPE (lv_classname).
      CATCH cx_sy_create_object_error cx_sy_move_cast_error INTO lx_root.
        lx_error = bad_request( message  = |Class { lv_classname } cannot be instantiated.|
                                previous = lx_root ).
        RAISE EXCEPTION lx_error.
    ENDTRY.

    TRY.
        DATA(lv_count) = li_proxy_kpi->count( lv_filter ).
      CATCH cx_root INTO lx_root.
        lx_error = bad_request( message  = |{ lv_classname }->count( ) failed: { lx_root->get_text( ) }|
                                previous = lx_root ).
        RAISE EXCEPTION lx_error.
    ENDTRY.

    " one row per counted item - except for a large $count, see
    " count_to_response( )
    DATA lv_build_rows TYPE abap_bool.
    count_to_response( EXPORTING request    = io_tech_request_context
                                 count      = lv_count
                       IMPORTING build_rows = lv_build_rows
                       CHANGING  response   = es_response_context ).
    IF lv_build_rows = abap_true.
      DO lv_count TIMES.
        INSERT VALUE #( id = sy-index ) INTO TABLE lt_result.
      ENDDO.
    ENDIF.

    copy_data_to_ref( EXPORTING is_data = lt_result CHANGING cr_data = er_entityset ).

  ENDMETHOD.


  METHOD count_to_response.

    DATA lv_has_count TYPE abap_bool.
    FIELD-SYMBOLS <lv_count> TYPE any.

    build_rows = abap_true.

    " by the interface-qualified name: request is typed as object here
    TRY.
        CALL METHOD request->('/IWBEP/IF_MGW_REQ_ENTITYSET~HAS_COUNT')
          RECEIVING
            rv_has_count = lv_has_count.
      CATCH cx_sy_dyn_call_error.
        RETURN.
    ENDTRY.
    IF lv_has_count = abap_false.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT `COUNT` OF STRUCTURE response TO <lv_count>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    <lv_count> = count.

    IF count > c_rows_max.
      build_rows = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD bad_request.

    result = NEW #( textid   = /iwbep/cx_mgw_busi_exception=>business_error
                    message  = CONV bapi_msg( message )
                    previous = previous ).

  ENDMETHOD.

ENDCLASS.
