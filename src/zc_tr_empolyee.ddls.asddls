@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TR_EMPOLYEE
  as projection on ZI_TR_EMPOLYEE
{
  key EmployeeUuid,
      EmployeeId,
      EmployeeName,

      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZC_TR_DEPARTMENT',
            element: 'DepartmentId'
          }
        }
      ]
      DepartmentId,
      DepartmentName,
      PositionName,
      Email,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,
      IsActive
}
