@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_DEPARTMENT as select from ztr_department
{
    key department_id as DepartmentId,
    department_name as DepartmentName
}
