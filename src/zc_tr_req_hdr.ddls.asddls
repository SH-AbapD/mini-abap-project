@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Header Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TR_REQ_HDR
  as projection on ZI_TR_REQ_HDR
{
  key RequestUuid,

      @Consumption.valueHelpDefinition: [{
      entity: {
        name:    'ZC_TR_EMPOLYEE',
        element: 'EmployeeId'
      }
      }]
      EmployeeId,
      _Employee.EmployeeName,

      @Consumption.valueHelpDefinition: [{
        entity: {
          name:    'ZC_TR_REQ_TYPE',
          element: 'RequestTypeId'
        }
      }]
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
      LastChangedBy,

      _RequestType : redirected to ZC_TR_REQ_TYPE,
      _Employee    : redirected to ZC_TR_EMPOLYEE
}
