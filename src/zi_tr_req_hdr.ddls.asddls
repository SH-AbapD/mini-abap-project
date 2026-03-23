@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_REQ_HDR as select from ztr_req_hdr
{
    key request_uuid as RequestUuid,
    employee_id as EmployeeId,
    request_type_id as RequestTypeId,
    title as Title,
    request_content as RequestContent,
    request_date as RequestDate,
    status as Status,
    processed_id as ProcessedId,
    processed_at as ProcessedAt,
    reject_reason as RejectReason,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy

}
