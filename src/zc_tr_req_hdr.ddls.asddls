@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Header Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TR_REQ_HDR
  as projection on ZI_TR_REQ_HDR
{
  key RequestUuid,
      EmployeeId,
      RequestTypeId,
      Title,
      RequestContent,
      RequestDate,
      Status,
      ProcessedId,
      ProcessedAt,
      RejectReason,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy
}
