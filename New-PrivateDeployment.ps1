param(
    $bucketname = "bc-pvt-deployment",
    $projectname = "glenlivet",
    $version = "test"
)

Set-DefaultAWSRegion ap-southeast-2
.".\Deployment.ps1"
$prefix = New-Deployment -bucketname $bucketname -projectname $projectname -version $version -deployroot ".\"

Write-Host "Deployment s3 prefix: $prefix"

return $prefix