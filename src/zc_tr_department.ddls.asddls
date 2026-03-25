@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TR_DEPARTMENT as projection on ZI_TR_DEPARTMENT

{
    key DepartmentId,
    DepartmentName
}
