@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Type Projection View'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity ZC_TR_REQ_TYPE
  as projection on ZI_TR_REQ_TYPE
{
  key RequestTypeId,
      RequestTypeName,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,
      IsActive
}
