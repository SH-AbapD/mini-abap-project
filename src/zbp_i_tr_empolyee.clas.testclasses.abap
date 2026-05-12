*"* use this source file for your ABAP unit test classes
CLASS ltcl_emp_action DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA : mv_active_uuid   TYPE sysuuid_x16,
           mv_inactive_uuid TYPE sysuuid_x16.

    METHODS:
      setup,
      teardown,
      deactivate_active_emp   FOR TESTING RAISING cx_static_check,  " 정상 케이스
      deactivate_inactive_emp FOR TESTING RAISING cx_static_check,  " 이미 비활성
      reactivate_inactive_emp FOR TESTING RAISING cx_static_check,  " 정상 케이스
      reactivate_active_emp   FOR TESTING RAISING cx_static_check.  " 이미 활성

ENDCLASS.


CLASS ltcl_emp_action IMPLEMENTATION.

  METHOD setup.
    mv_active_uuid   = cl_system_uuid=>create_uuid_x16_static( ).
    mv_inactive_uuid = cl_system_uuid=>create_uuid_x16_static( ).

    DATA lv_ts TYPE timestamp.
    GET TIME STAMP FIELD lv_ts.

    INSERT ztr_employee FROM @( VALUE #(
      client          = sy-mandt
      employee_uuid   = mv_active_uuid
      employee_id     = 'EMP1001'
      employee_name   = 'Test Active'
      department_id   = 'FI'
      position_id     = 'Manager'
      created_at      = lv_ts
      created_by      = sy-uname
      last_changed_at = lv_ts
      last_changed_by = sy-uname
      is_active       = 'A'
    ) ).

    INSERT ztr_employee FROM @( VALUE #(
      client          = sy-mandt
      employee_uuid   = mv_inactive_uuid
      employee_id     = 'EMP1000'
      employee_name   = 'Test Inactive'
      department_id   = 'FI'
      position_id     = 'Manager'
      created_at      = lv_ts
      created_by      = sy-uname
      last_changed_at = lv_ts
      last_changed_by = sy-uname
      is_active       = 'N'
    ) ).
  ENDMETHOD.

  METHOD teardown.
    " 테스트 끝나면 데이터 롤백
    DELETE FROM ztr_employee
      WHERE employee_uuid = @mv_active_uuid
         OR employee_uuid = @mv_inactive_uuid.
    ROLLBACK WORK.
  ENDMETHOD.

  METHOD deactivate_active_emp.
    " 활성(A) 사원 비활성화 → failed 없어야 함 (성공 케이스)
    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      EXECUTE deactivateEmployee
      FROM VALUE #( ( %key-EmployeeUuid = mv_active_uuid ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    cl_abap_unit_assert=>assert_initial(
      act = lt_failed-emp
      msg = '활성 사원 비활성화는 성공해야 함' ).
  ENDMETHOD.

  METHOD deactivate_inactive_emp.
    " 비활성(N) 사원 비활성화 → failed 있어야 함 (에러 케이스)
    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      EXECUTE deactivateEmployee
      FROM VALUE #( ( %key-EmployeeUuid = mv_inactive_uuid ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    cl_abap_unit_assert=>assert_not_initial(
      act = lt_failed-emp
      msg = '이미 비활성 사원은 failed에 담겨야 함' ).
  ENDMETHOD.

  METHOD reactivate_inactive_emp.
    " 비활성(N) 사원 활성화 → failed 없어야 함 (성공 케이스)
    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      EXECUTE reactivateEmployee
      FROM VALUE #( ( %key-EmployeeUuid = mv_inactive_uuid ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    cl_abap_unit_assert=>assert_initial(
      act = lt_failed-emp
      msg = '비활성 사원 활성화는 성공해야 함' ).
  ENDMETHOD.

  METHOD reactivate_active_emp.
    " 활성(A) 사원 활성화 → failed 있어야 함 (에러 케이스)
    MODIFY ENTITIES OF zi_tr_empolyee IN LOCAL MODE
      ENTITY Emp
      EXECUTE reactivateEmployee
      FROM VALUE #( ( %key-EmployeeUuid = mv_active_uuid ) )
      FAILED   DATA(lt_failed)
      REPORTED DATA(lt_reported).

    cl_abap_unit_assert=>assert_not_initial(
      act = lt_failed-emp
      msg = '이미 활성 사원은 failed에 담겨야 함' ).
  ENDMETHOD.

ENDCLASS.
