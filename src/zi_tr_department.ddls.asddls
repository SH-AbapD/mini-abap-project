@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_DEPARTMENT
  as select from ztr_department
{
  key department_id   as DepartmentId,
      department_name as DepartmentName,

      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      
      is_active       as IsActive
}
