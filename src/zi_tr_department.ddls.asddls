@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_DEPARTMENT as select from ztr_department
{
    key department_id as DepartmentId,
    department_name as DepartmentName,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy,
    is_active as IsActive
}
