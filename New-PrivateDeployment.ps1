param(
    #$bucketname = "local-glenfiddichbase-publicbucket-1mmtghaeejx68",
    $bucketname = "dev-glenfiddichbase-publicbucket-s2lgz460omgc",
    $projectname = "glenlivet",
    $version = "test"
)

#Set-DefaultAWSRegion ap-southeast-2
Set-DefaultAWSRegion eu-west-1
.".\Deployment.ps1"
$prefix = New-Deployment -bucketname $bucketname -projectname $projectname -version $version -deployroot ".\"

Write-Host "Deployment s3 prefix: $prefix"

return $prefix

