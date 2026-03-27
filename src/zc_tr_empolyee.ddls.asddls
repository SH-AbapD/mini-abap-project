@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TR_EMPOLYEE as projection on ZI_TR_EMPOLYEE
{
    key EmployeeId,
    EmployeeName,
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
