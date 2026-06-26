@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request Type ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_TR_REQ_TYPE_VH
  as select from ZI_TR_REQ_TYPE
{
  key RequestTypeId,
      RequestTypeName
}
where
  IsActive = 'A'
