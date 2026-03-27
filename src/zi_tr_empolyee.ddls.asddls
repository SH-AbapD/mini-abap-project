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
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZC_TR_DEPARTMENT',
            element: 'DepartmentId'
          }
        }
      ]
      department_id as DepartmentId,
      position_name   as PositionName,
      email           as Email,
      created_at      as CreatedAt,
      created_by      as CreatedBy,
      last_changed_at as LastChangedAt,
      last_changed_by as LastChangedBy,
      is_active       as IsActive,
      _Department.DepartmentName as DepartmentName,
      _Department
}
