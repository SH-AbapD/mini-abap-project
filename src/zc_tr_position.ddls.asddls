@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position projection view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TR_POSITION as projection on ZI_TR_POSITION
{
    key PositionId,
    PositionName,
    
    CreatedAt,
    CreatedBy,
    
    LastChangedAt,
    LastChangedBy,
    
    IsActive
}
