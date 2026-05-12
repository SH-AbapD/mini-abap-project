CLASS lhc_Pos DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Pos RESULT result.

    METHODS deactivate FOR MODIFY
      IMPORTING keys FOR ACTION Pos~deactivate.

    METHODS reactivate FOR MODIFY
      IMPORTING keys FOR ACTION Pos~reactivate.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Pos~setInitialStatus.

ENDCLASS.

CLASS lhc_Pos IMPLEMENTATION.

  METHOD get_global_authorizations.

    DATA lv_is_admin TYPE abap_bool.

    lv_is_admin = xsdbool( sy-uname = 'ADMIN' OR sy-uname = 'CB9980003740' ).

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

    IF requested_authorizations-%action-deactivate = if_abap_behv=>mk-on.
      result-%action-deactivate = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

    IF requested_authorizations-%action-reactivate = if_abap_behv=>mk-on.
      result-%action-reactivate = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
      ).
    ENDIF.

  ENDMETHOD.

  METHOD deactivate.

    READ ENTITIES OF zi_tr_position IN  LOCAL MODE
        ENTITY Pos
        FIELDS ( IsActive PositionId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_pos).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_position\\Pos.

    LOOP AT lt_pos INTO DATA(ls_pos).
      IF ls_pos-IsActive = 'N'.
        APPEND VALUE #( %tky = ls_pos-%tky ) TO failed-pos.

        APPEND VALUE #(
          %tky = ls_pos-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |직급 { ls_pos-PositionId } 는 이미 비활성 상태입니다.| )
        ) TO reported-pos.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_pos-%tky
        IsActive = 'N'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_position IN LOCAL MODE
        ENTITY Pos
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-pos TO failed-pos.
      APPEND LINES OF lt_reported-pos TO reported-pos.

      LOOP AT lt_update INTO DATA(ls_update).
        APPEND VALUE #(
          %tky = ls_update-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text     = |직급이 정상적으로 비활성화되었습니다.| )
        ) TO reported-pos.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD reactivate.

    READ ENTITIES OF zi_tr_position IN LOCAL MODE
      ENTITY Pos
      FIELDS ( IsActive PositionId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_dept).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_position\\Pos.

    LOOP AT lt_dept INTO DATA(ls_pos).
      IF ls_pos-IsActive = 'A'.
        APPEND VALUE #( %tky = ls_pos-%tky ) TO failed-pos.

        APPEND VALUE #(
          %tky = ls_pos-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |직급 { ls_pos-positionId } 는 이미 활성 상태입니다.| )
        ) TO reported-pos.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_pos-%tky
        IsActive = 'A'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_position IN LOCAL MODE
        ENTITY Pos
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-pos TO failed-pos.
      APPEND LINES OF lt_reported-pos TO reported-pos.

      LOOP AT lt_update INTO DATA(ls_update).
        APPEND VALUE #(
          %tky = ls_update-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text     = |직급이 정상적으로 활성화되었습니다.| )
        ) TO reported-pos.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD setinitialstatus.

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_position\\Pos.

    READ ENTITIES OF zi_tr_position IN LOCAL MODE
        ENTITY Pos
        FIELDS ( IsActive )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_pos).

    LOOP AT lt_pos INTO DATA(ls_pos).
      IF ls_pos-IsActive IS INITIAL.
        APPEND VALUE #(
          %tky     = ls_pos-%tky
          IsActive = 'A'
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_position IN LOCAL MODE
        ENTITY Pos
        UPDATE FIELDS ( IsActive )
        WITH lt_update.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
