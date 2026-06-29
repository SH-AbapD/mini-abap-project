@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TR_POSITION
  provider contract transactional_query
  as projection on ZI_TR_POSITION
{
  key PositionId,
      PositionName,

      CreatedAt,
      CreatedBy,

      LastChangedAt,
      LastChangedBy,

      IsActive
}
