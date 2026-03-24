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
    READ ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
        ENTITY Req
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_req).

    LOOP AT lt_req INTO DATA(ls_req).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<r>).
      <r>-%tky = ls_req-%tky.

      IF requested_authorizations-%update = if_abap_behv=>mk-on.
        <r>-%update = COND #(
          WHEN ls_req-Status = 'P'
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%action-approve = if_abap_behv=>mk-on.
        <r>-%action-approve = COND #(
          WHEN ls_req-Status = 'P'
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%action-reject = if_abap_behv=>mk-on.
        <r>-%action-reject = COND #(
          WHEN ls_req-Status = 'P'
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%action-cancel = if_abap_behv=>mk-on.
        <r>-%action-cancel = COND #(
          WHEN ls_req-Status = 'P'
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA lv_is_admin TYPE abap_bool.

    lv_is_admin = xsdbool( sy-uname = 'ADMIN' ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%action-cancel = if_abap_behv=>mk-on.
      result-%action-cancel = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%action-approve = if_abap_behv=>mk-on.
      result-%action-approve = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%action-reject = if_abap_behv=>mk-on.
      result-%action-reject = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

  ENDMETHOD.

  METHOD approve.

    GET TIME STAMP FIELD DATA(lv_processed_at).

    MODIFY ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
     ENTITY Req
     UPDATE FIELDS ( Status ProcessedAt )
     WITH VALUE #(
         FOR key IN keys (
             %tky = key-%tky
             Status = 'A'
             ProcessedAt = lv_processed_at
          )
       ).
  ENDMETHOD.

  METHOD cancel.

    MODIFY ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
        ENTITY Req
        UPDATE FIELDS ( Status )
         WITH VALUE #(
         FOR key IN keys (
             %tky   = key-%tky
             Status = 'C'
    )
  ).

  ENDMETHOD.

  METHOD reject.

    GET TIME STAMP FIELD DATA(lv_processed_at).

    MODIFY ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
     ENTITY Req
     UPDATE FIELDS ( Status ProcessedAt )
     WITH VALUE #(
         FOR key IN keys (
             %tky = key-%tky
             Status = 'R'
             ProcessedAt = lv_processed_at
          )
       ).

  ENDMETHOD.

  METHOD setInitialStatus.

    MODIFY ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
        ENTITY Req
        UPDATE FIELDS ( Status )
        WITH VALUE #(
            FOR key IN keys (
                %tky = key-%tky
                Status = 'P'
             )
         ).

  ENDMETHOD.

ENDCLASS.
