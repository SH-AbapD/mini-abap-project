CLASS lhc_Req DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Req RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Req RESULT result.

    METHODS cancel FOR MODIFY
      IMPORTING keys FOR ACTION Req~cancel.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Req~setInitialStatus.
    METHODS validateRequestDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Req~validateRequestDate.

ENDCLASS.

CLASS lhc_Req IMPLEMENTATION.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zi_tr_req_hdr_self IN LOCAL MODE
        ENTITY Req
        FIELDS ( Status CreatedBy )
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

      IF requested_authorizations-%action-cancel = if_abap_behv=>mk-on.
        <r>-%action-cancel = COND #(
          WHEN ls_req-Status = 'P' and ls_req-CreatedBy = sy-uname
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA lv_is_admin TYPE abap_bool.

    lv_is_admin = xsdbool( sy-uname = 'ADMIN' OR sy-uname = 'CB9980000379' ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%action-cancel = if_abap_behv=>mk-on.
      result-%action-cancel = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

  METHOD cancel.

    MODIFY ENTITIES OF zi_tr_req_hdr_self IN LOCAL MODE
        ENTITY Req
        UPDATE FIELDS ( Status )
         WITH VALUE #(
         FOR key IN keys (
             %tky   = key-%tky
             Status = 'C'
    )
  ).

  ENDMETHOD.

  METHOD setInitialStatus.

    MODIFY ENTITIES OF zi_tr_req_hdr_self IN LOCAL MODE
        ENTITY Req
        UPDATE FIELDS ( Status )
        WITH VALUE #(
            FOR key IN keys (
                %tky = key-%tky
                Status = 'P'
             )
         ).

  ENDMETHOD.

  METHOD validateRequestDate.

    READ ENTITIES OF zi_tr_req_hdr_self IN LOCAL MODE
        ENTITY Req
        FIELDS ( RequestDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_req).

    LOOP AT lt_req INTO DATA(ls_req).
      IF ls_req-RequestDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %tky = ls_req-%tky ) TO failed-req.

        APPEND VALUE #(
           %tky = ls_req-%tky
           %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text = '요청일은 오늘 이후 날짜여야 합니다.'
           )
         ) TO reported-req.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
