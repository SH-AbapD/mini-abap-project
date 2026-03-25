CLASS lhc_Dept DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Dept RESULT result.

    METHODS deactivate FOR MODIFY
      IMPORTING keys FOR ACTION Dept~deactivate.

    METHODS reactivate FOR MODIFY
      IMPORTING keys FOR ACTION Dept~reactivate.

ENDCLASS.

CLASS lhc_Dept IMPLEMENTATION.

  METHOD get_global_authorizations.

    DATA lv_is_admin TYPE abap_bool.

    lv_is_admin = xsdbool( sy-uname = 'ADMIN' ).

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

    READ ENTITIES OF zi_tr_department IN  LOCAL MODE
        ENTITY Dept
        FIELDS ( IsActive DepartmentId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_dept).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_department\\Dept.

    LOOP AT lt_dept INTO DATA(ls_dept).
      IF ls_dept-IsActive = 'N'.
        APPEND VALUE #( %tky = ls_dept-%tky ) TO failed-dept.

        APPEND VALUE #(
          %tky = ls_dept-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |부서 { ls_dept-DepartmentId } 는 이미 비활성 상태입니다.| )
        ) TO reported-dept.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_dept-%tky
        IsActive = 'N'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_department IN LOCAL MODE
        ENTITY Dept
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-dept TO failed-dept.
      APPEND LINES OF lt_reported-dept TO reported-dept.

      LOOP AT lt_update INTO DATA(ls_update).
        APPEND VALUE #(
          %tky = ls_update-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text     = |부서가 정상적으로 비활성화되었습니다.| )
        ) TO reported-dept.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD reactivate.

    READ ENTITIES OF zi_tr_department IN LOCAL MODE
      ENTITY Dept
      FIELDS ( IsActive DepartmentId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_dept).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_department\\Dept.

    LOOP AT lt_dept INTO DATA(ls_dept).
      IF ls_dept-IsActive = 'A'.
        APPEND VALUE #( %tky = ls_dept-%tky ) TO failed-dept.

        APPEND VALUE #(
          %tky = ls_dept-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |부서 { ls_dept-DepartmentId } 는 이미 활성 상태입니다.| )
        ) TO reported-dept.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_dept-%tky
        IsActive = 'A'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_department IN LOCAL MODE
        ENTITY Dept
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-dept TO failed-dept.
      APPEND LINES OF lt_reported-dept TO reported-dept.

      LOOP AT lt_update INTO DATA(ls_update).
        APPEND VALUE #(
          %tky = ls_update-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text     = |부서가 정상적으로 활성화되었습니다.| )
        ) TO reported-dept.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
