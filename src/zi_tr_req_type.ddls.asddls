@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Type Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_REQ_TYPE
  as select from ztr_req_type
{
  key request_type_id   as RequestTypeId,
      request_type_name as RequestTypeName,
      
      @Semantics.systemDateTime.createdAt: true
      created_at        as CreatedAt,
      @Semantics.user.createdBy: true
      created_by        as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at   as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by   as LastChangedBy,

      is_active         as IsActive
}
