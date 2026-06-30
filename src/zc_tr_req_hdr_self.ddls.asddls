@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'providers request(self reqeust)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TR_REQ_HDR_SELF
  provider contract transactional_query
  as projection on ZI_TR_REQ_HDR_SELF
{
  key RequestUuid,

      @Consumption.valueHelpDefinition: [{
          entity : { name: 'ZC_TR_EMPLOYEE_VH', element : 'EmployeeId' }
      }]
      EmployeeId,
      _Employee.EmployeeName,
      
      @Consumption.valueHelpDefinition: [{
      entity: {
      name:    'ZC_TR_REQ_TYPE_VH',
      element: 'RequestTypeId'
      }
      }]
      RequestTypeId,
      _RequestType.RequestTypeName,      
      
      Title,
      RequestContent,
      RequestDate,
      Status,
      RejectReason,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,

      _Employee: redirected to ZC_TR_EMPOLYEE,
      _RequestType: redirected to ZC_TR_REQ_TYPE
}
