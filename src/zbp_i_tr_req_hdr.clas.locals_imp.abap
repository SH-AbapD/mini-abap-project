CLASS lhc_Req DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Req RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Req RESULT result.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION Req~approve.

    METHODS cancel FOR MODIFY
      IMPORTING keys FOR ACTION Req~cancel.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION Req~reject.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Req~setInitialStatus.

ENDCLASS.

CLASS lhc_Req IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD approve.
  ENDMETHOD.

  METHOD cancel.
  ENDMETHOD.

  METHOD reject.
  ENDMETHOD.

  METHOD setInitialStatus.
  ENDMETHOD.

ENDCLASS.
