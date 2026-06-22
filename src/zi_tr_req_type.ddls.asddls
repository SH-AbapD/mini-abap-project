@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Type Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_REQ_TYPE as select from ztr_req_type
{
    key request_type_id as RequestTypeId,
    request_type_name as RequestTypeName,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy,
    is_active as IsActive
}
