CLASS z2ui5_cl_lp_kpi_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_lp_kpi_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! The generated model, with CLASS and FILTER filterable: the service
    "! is only ever called with $filter on them (the tile URL of the
    "! README), and SEGW generated both as sap:filterable="false" - which a
    "! metadata-driven consumer (a smart tile configurator, a SmartFilterBar,
    "! a validator) takes at its word. Gateway itself filters either way.
    METHODS define
        REDEFINITION.

    "! At least the time define( ) here last changed the model, so a
    "! $metadata cached from before is built again
    METHODS get_last_modified
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
    "! When define( ) of this class last changed the model (UTC)
    CONSTANTS c_changed_at TYPE timestamp VALUE '20261127000000'.
ENDCLASS.



CLASS z2ui5_cl_lp_kpi_mpc_ext IMPLEMENTATION.

  METHOD define.

    " typed, not inline: the 7.02 downport cannot type an inline
    " declaration from a Gateway (void) method
    DATA lo_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ.

    super->define( ).

    lo_entity_type = model->get_entity_type( 'ENTITY' ).
    lo_entity_type->get_property( 'CLASS' )->set_filterable( abap_true ).
    lo_entity_type->get_property( 'FILTER' )->set_filterable( abap_true ).

  ENDMETHOD.


  METHOD get_last_modified.

    rv_last_modified = super->get_last_modified( ).
    IF rv_last_modified < c_changed_at.
      rv_last_modified = c_changed_at.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
