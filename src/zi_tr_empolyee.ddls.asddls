@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_EMPOLYEE as select from ztr_employee
{
    key employee_id as EmployeeId,
    employee_name as EmployeeName,
    department_id as DepartmentId,
    department_name as DepartmentName,
    position_name as PositionName,
    email as Email,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy,
    is_active as IsActive
}
