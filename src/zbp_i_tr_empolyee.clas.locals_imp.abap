CLASS lhc_Emp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Emp RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Emp~setInitialStatus.

    METHODS deactivateEmployee FOR MODIFY
      IMPORTING keys FOR ACTION Emp~deactivateEmployee.

    METHODS reactivateEmployee FOR MODIFY
      IMPORTING keys FOR ACTION Emp~reactivateEmployee.

    METHODS setEmployeeId FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Emp~setEmployeeId.

    METHODS validateEmail FOR VALIDATE ON SAVE
      IMPORTING keys FOR Emp~validateEmail.

ENDCLASS.

CLASS lhc_Emp IMPLEMENTATION.

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

    IF requested_authorizations-%action-deactivateEmployee = if_abap_behv=>mk-on.
      result-%action-deactivateEmployee = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

    IF requested_authorizations-%action-reactivateEmployee = if_abap_behv=>mk-on.
      result-%action-reactivateEmployee = COND #(
        WHEN lv_is_admin = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized
      ).
    ENDIF.

  ENDMETHOD.

  METHOD setinitialstatus.

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_empolyee\\Emp.

    READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        FIELDS ( IsActive )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_emp).

    LOOP AT lt_emp INTO DATA(ls_emp).
      IF ls_emp-IsActive IS INITIAL.
        APPEND VALUE #(
          %tky     = ls_emp-%tky
          IsActive = 'A'
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        UPDATE FIELDS ( IsActive )
        WITH lt_update.
    ENDIF.

  ENDMETHOD.


  METHOD deactivateEmployee.

    READ ENTITIES OF zi_tr_empolyee IN  LOCAL MODE
        ENTITY Emp
        FIELDS ( IsActive )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_emp).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_empolyee\\Emp.

    LOOP AT lt_emp INTO DATA(ls_emp).
      IF ls_emp-IsActive = 'N'.
        APPEND VALUE #( %tky = ls_emp-%tky ) TO failed-emp.

        APPEND VALUE #(
          %tky = ls_emp-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |사원 { ls_emp-EmployeeId } 는 이미 비활성 상태입니다.| )
        ) TO reported-emp.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_emp-%tky
        IsActive = 'N'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-emp TO failed-emp.
      APPEND LINES OF lt_reported-emp TO reported-emp.

      LOOP AT lt_update INTO DATA(ls_update).
        IF NOT line_exists( lt_failed-emp[ %tky = ls_update-%tky ] ).
          APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |사원이 정상적으로 비활성화되었습니다.| )
          ) TO reported-emp.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD reactivateEmployee.

    READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      FIELDS ( IsActive )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_emp).

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_empolyee\\Emp.

    LOOP AT lt_emp INTO DATA(ls_emp).
      IF ls_emp-IsActive = 'A'.
        APPEND VALUE #( %tky = ls_emp-%tky ) TO failed-emp.

        APPEND VALUE #(
          %tky = ls_emp-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |사원 { ls_emp-EmployeeId } 는 이미 활성 상태입니다.| )
        ) TO reported-emp.

        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_emp-%tky
        IsActive = 'A'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        UPDATE FIELDS ( IsActive )
        WITH lt_update
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-emp TO failed-emp.
      APPEND LINES OF lt_reported-emp TO reported-emp.

      LOOP AT lt_update INTO DATA(ls_update).
        IF NOT line_exists( lt_failed-emp[ %tky = ls_update-%tky ] ).
          APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |사원이 정상적으로 활성화되었습니다.| )
          ) TO reported-emp.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD setEmployeeId.

    READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        FIELDS ( EmployeeUuid EmployeeId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_emp).

    SELECT MAX( employee_id )
        FROM ztr_employee
        INTO @DATA(lv_max_id).

    DATA lv_next_num TYPE i.

    IF lv_max_id IS INITIAL.
      lv_next_num = 1.
    ELSE.
      lv_next_num = lv_max_id+3 + 1.
    ENDIF.

    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      UPDATE FIELDS ( EmployeeId )
      WITH VALUE #(
        FOR ls_emp IN lt_emp
        WHERE ( EmployeeId IS INITIAL )
        ( %tky       = ls_emp-%tky
          EmployeeId = |EMP{ lv_next_num WIDTH = 4 PAD = '0' }| ) ).

  ENDMETHOD.

  METHOD validateemail.

    READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        FIELDS ( Email )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_emp).

    LOOP AT lt_emp INTO DATA(ls_emp).

      IF ls_emp-Email IS INITIAL.
        APPEND VALUE #(
          %tky = ls_emp-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = '이메일을 입력해주세요.' )
        ) TO reported-emp.
        APPEND VALUE #( %tky = ls_emp-%tky ) TO failed-emp.
        CONTINUE.
      ENDIF.

      FIND PCRE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' IN ls_emp-Email.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          %tky = ls_emp-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |올바른 이메일 형식이 아닙니다. 입력값: '{ ls_emp-Email }'| )
        ) TO reported-emp.
        APPEND VALUE #( %tky = ls_emp-%tky ) TO failed-emp.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
