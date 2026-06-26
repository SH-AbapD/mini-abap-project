@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_TR_DEPT_VH
  as select from ZI_TR_DEPARTMENT
{
  key DepartmentId,
      DepartmentName
}
where
  IsActive = 'A'
