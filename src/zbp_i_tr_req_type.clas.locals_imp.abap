CLASS lhc_ReqType DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ReqType RESULT result.

    METHODS deactivateReqType FOR MODIFY
      IMPORTING keys FOR ACTION ReqType~deactivateReqType.

    METHODS reactivateReqType FOR MODIFY
      IMPORTING keys FOR ACTION ReqType~reactivateReqType.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ReqType~setInitialStatus.

ENDCLASS.

CLASS lhc_ReqType IMPLEMENTATION.

  METHOD get_global_authorizations.

    DATA lv_is_admin TYPE abap_bool.

    lv_is_admin = xsdbool( sy-uname = 'ADMIN' OR sy-uname = 'CB9980000379' ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

    IF requested_authorizations-%action-deactivateReqType = if_abap_behv=>mk-on.
      result-%action-deactivateReqType = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

    IF requested_authorizations-%action-reactivateReqType = if_abap_behv=>mk-on.
      result-%action-reactivateReqType = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
      ).
    ENDIF.
  ENDMETHOD.

  METHOD deactivateReqType.
    READ ENTITIES OF zi_tr_req_type IN LOCAL MODE
        ENTITY ReqType
        FIELDS ( isActive )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_reqType).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_req_type.

    LOOP AT lt_reqType INTO DATA(ls_reqType).
      IF ls_reqtype-IsActive = 'N'.

        APPEND VALUE #( %tky = ls_reqtype-%tky ) TO failed-reqtype.

        APPEND VALUE #(
            %tky = ls_reqtype-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |요청 타입 { ls_reqtype-RequestTypeName } 은 이미 비활성 상태입니다.| )
         ) TO reported-reqType.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
          %tky = ls_reqType-%tky
          isActive = 'N'
       ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_req_type IN LOCAL MODE
       ENTITY ReqType
       UPDATE FIELDS ( isActive )
       WITH lt_update
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-ReqType  TO failed-ReqType.
      APPEND LINES OF lt_reported-ReqType TO reported-ReqType.

      LOOP AT lt_update INTO DATA(ls_update).
        IF NOT line_exists( lt_failed-ReqType[ KEY id %tky = ls_update-%tky ] ).
          APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |요청 타입이 정상적으로 비활성화되었습니다.| )
          ) TO reported-ReqType.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD reactivateReqType.
    READ ENTITIES OF zi_tr_req_type IN LOCAL MODE
      ENTITY ReqType
      FIELDS ( IsActive )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reqType).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_req_type.

    LOOP AT lt_reqType INTO DATA(ls_reqType).
      IF ls_reqType-IsActive = 'A'.
        APPEND VALUE #( %tky = ls_reqType-%tky ) TO failed-reqType.

        APPEND VALUE #(
          %tky = ls_reqType-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |요청 타입 { ls_reqType-RequestTypeName } 는 이미 활성 상태입니다.| )
        ) TO reported-reqType.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_reqType-%tky
        IsActive = 'A'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_req_type IN LOCAL MODE
        ENTITY ReqType
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-reqType TO failed-reqType.
      APPEND LINES OF lt_reported-reqType TO reported-reqType.

      LOOP AT lt_update INTO DATA(ls_update).
        IF NOT line_exists( lt_failed-reqType[ KEY id %tky = ls_update-%tky ] ).
          APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |요청 타입이 정상적으로 활성화되었습니다.| )
          ) TO reported-reqType.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD setInitialStatus.
    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_req_type.
    DATA ls_update LIKE LINE OF lt_update.

    READ ENTITIES OF zi_tr_req_type IN LOCAL MODE
        ENTITY ReqType
        FIELDS ( IsActive RequestTypeId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_reqType).

    LOOP AT lt_reqType INTO DATA(ls_reqType).
      IF ls_reqType-IsActive IS INITIAL.
        APPEND VALUE #(
          %tky     = ls_reqType-%tky
          IsActive = 'A'
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_req_type IN LOCAL MODE
          ENTITY ReqType
          UPDATE FIELDS ( IsActive )
          WITH lt_update.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
