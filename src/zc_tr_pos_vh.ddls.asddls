@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_TR_POS_VH
  as select from ZI_TR_POSITION
{
  key PositionId,
      PositionName
}
where
  IsActive = 'A'
