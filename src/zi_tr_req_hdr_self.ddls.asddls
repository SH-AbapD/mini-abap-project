@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Request Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_REQ_HDR_SELF
  as select from ztr_req_hdr
  association [1..1] to ZI_TR_REQ_TYPE as _RequestType on $projection.RequestTypeId = _RequestType.RequestTypeId
  association [1..1] to ZI_TR_EMPOLYEE  as _Employee    on $projection.EmployeeId    = _Employee.EmployeeId
{
  key request_uuid    as RequestUuid,
      employee_id     as EmployeeId,
      request_type_id as RequestTypeId,
      title           as Title,
      request_content as RequestContent,
      request_date    as RequestDate,
      status          as Status,
      processed_id    as ProcessedId,
      processed_at    as ProcessedAt,
      reject_reason   as RejectReason,
      
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      
      _RequestType,
      _Employee
}
