@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.resultSet.sizeCategory: #XS
define root view entity ZC_TR_DEPARTMENT
  provider contract transactional_query 
    as projection on ZI_TR_DEPARTMENT
{
    key DepartmentId,
    DepartmentName,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    IsActive
}
