param(
    $bucketname = "local-glenfiddichbase-publicbucket-1mmtghaeejx68",
    $projectname = "glenlivet",
    $version = "test"
)

Set-DefaultAWSRegion ap-southeast-2
.".\Deployment.ps1"
$prefix = New-Deployment -bucketname $bucketname -projectname $projectname -version $version -deployroot ".\"

Write-Host "Deployment s3 prefix: $prefix"

return $prefix