param(
    $bucketname = "bc-glenfiddich-local",
    $projectname = "aws-lego",
    $version = "integration-testing"
)

$prefix = .\New-PrivateDeployment.ps1 -bucketname $bucketname -projectname $projectname -version $version

<#$regions = Get-AWSRegion
$regions | % {
    .\ExecuteAllTemplates.ps1 -region $_.Region -prefix $prefix
}
#>