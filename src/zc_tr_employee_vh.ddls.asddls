@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'valueHelp view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_TR_EMPLOYEE_VH
  as select from ZI_TR_EMPOLYEE
{
  key EmployeeId,
      EmployeeName,
      _Department.DepartmentName,
      _Position.PositionName
}
where
  IsActive = 'A'
