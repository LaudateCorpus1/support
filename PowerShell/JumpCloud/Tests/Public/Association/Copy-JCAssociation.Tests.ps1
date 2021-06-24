# BeforeAll {
#     Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
#     If (-not (Get-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') | Where-Object { $_.TargetId -eq $PesterParams_UserGroup.id }))
#     {
#         Add-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') -TargetId:($PesterParams_UserGroup.id) -Force
#     }
# }
# Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
#     Context ('User and Id Association Tests') {
#         It '<testDescription>' -TestCases @(
#             @{  testDescription = 'Copy Associtations by username'
#                 QType           = "username"
#                 SourceTarget    = "Name"
#                 DestTarget      = "TargetName"
#             }
#             @{  testDescription = 'Copy Associtations by UserID'
#                 QType           = "_id"
#                 SourceTarget    = "Id"
#                 DestTarget      = "TargetId"
#             }
#         ) {
#             param (
#                 [string] $SourceTarget,
#                 [string] $DestTarget,
#                 [string] $QType
#             )
#             # build query
#             Invoke-Expression -Command:("Copy-JCAssociation -Type:('user') -$($SourceTarget):('$($PesterParams_User1.$QType)') -$($DestTarget):('$($PesterParams_User2.$QType)') -Force")
#             # compare results
#             $User1Associations = $PesterParams_User1 | Get-JCAssociation -Type:('user')
#             $User2Associations = $PesterParams_User2 | Get-JCAssociation -Type:('user')
#             $User1Associations.associationType | Should -Be $User2Associations.associationType
#             $User1Associations.type | Should -Be $User2Associations.type
#             $User1Associations.targetId | Should -Be $User2Associations.targetId
#             $User1Associations.targetType | Should -Be $User2Associations.targetType
#             # $User1Associations.compiledAttributes | Should -Be $User2Associations.compiledAttributes
#         }
#     }
# }
