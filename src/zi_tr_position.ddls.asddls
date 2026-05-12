@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position interface view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_POSITION 
 as select from ztr_position
 {
    key position_id as PositionId,
    position_name as PositionName,
    
    created_at as CreatedAt,
    created_by as CreatedBy,
    
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy,
    
    is_active as IsActive

}
