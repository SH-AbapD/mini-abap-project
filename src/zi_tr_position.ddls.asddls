@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position interface view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TR_POSITION 
 as select from ztr_position
 {
    key position_id as PositionId,
    position_name as PositionName,
    
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
    
    is_active as IsActive

}
