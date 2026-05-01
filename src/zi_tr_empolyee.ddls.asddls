@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_EMPOLYEE
  as select from ztr_employee association [0..1] to ZI_TR_DEPARTMENT as _Department
    on $projection.DepartmentId = _Department.DepartmentId
{
  key employee_uuid   as EmployeeUuid,
      employee_id     as EmployeeId,
      employee_name   as EmployeeName,
      
      @ObjectModel.text.element: ['DepartmentName']
      department_id as DepartmentId,
      position_name   as PositionName,
      email           as Email,
      
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      
      is_active       as IsActive,
      _Department.DepartmentName as DepartmentName,
      _Department
}
