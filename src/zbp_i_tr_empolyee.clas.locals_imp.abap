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
    METHODS validateDuplicateEmpId FOR VALIDATE ON SAVE
      IMPORTING keys FOR Emp~validateDuplicateEmpId.

ENDCLASS.

CLASS lhc_Emp IMPLEMENTATION.

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
        IF NOT line_exists( lt_failed-emp[ KEY id %tky = ls_update-%tky ] ).
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
        IF NOT line_exists( lt_failed-emp[ KEY id %tky = ls_update-%tky ] ).
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

    DATA lt_target LIKE lt_emp.
    lt_target = lt_emp.
    DELETE lt_target WHERE EmployeeId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
           nr_range_nr = '01'
           object = 'ZNR_EMP'
           quantity = CONV #( lines( lt_target ) )
          IMPORTING
           number = DATA(lv_number)
           returned_quantity = DATA(lv_qty) ).
      CATCH cx_number_ranges INTO DATA(lx_nr).
        RETURN.
    ENDTRY.

    DATA lv_next TYPE i.

    lv_next = lv_number - lv_qty + 1.

    DATA lt_update TYPE TABLE FOR UPDATE zi_tr_empolyee.

    LOOP AT lt_target INTO DATA(ls_emp).
      APPEND VALUE #(
    %tky       = ls_emp-%tky
    EmployeeId = |EMP{ lv_next WIDTH = 4 PAD = '0' }|
  ) TO lt_update.
      lv_next = lv_next + 1.
    ENDLOOP.

    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      UPDATE FIELDS ( EmployeeId )
      WITH lt_update.

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

  METHOD validateDuplicateEmpId.
    READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
        ENTITY Emp
        FIELDS ( EmployeeId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_emp).

    LOOP AT lt_emp INTO DATA(ls_emp).
      SELECT SINGLE employee_id
      FROM ztr_employee
      WHERE employee_id = @ls_emp-EmployeeId
      AND employee_uuid <> @ls_emp-EmployeeUuid
      INTO @DATA(lv_existing).

      IF sy-subrc = 0.
        APPEND VALUE #(
          %tky = ls_emp-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |직원 ID { ls_emp-EmployeeId }가 이미 존재합니다.| )
        ) TO reported-emp.
        APPEND VALUE #( %tky = ls_emp-%tky ) TO failed-emp.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
