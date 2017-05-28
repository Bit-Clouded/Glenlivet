param(
    $plcbucket = "local-glenfiddichbase-publicbucket-1mmtghaeejx68",
    $pvtbucket = "local-glenfiddichbase-privatebucket-1tw3hnwrqrrem",
    $region = "eu-west-1",
    $version = 'prod',
    $projectname = 'glenlivet'
)

Set-DefaultAWSRegion $region

cd $PSScriptRoot
.".\Deployment.ps1"
Get-S3Object -BucketName $pvtbucket -KeyPrefix "$projectname/$version/cache" | % {
    Remove-S3Object -BucketName $pvtbucket -Key $_.Key -Force
}
$prefix = New-Deployment -bucketname $plcbucket -projectname $projectname -version $version -deployroot ".\"

Write-Host "Deployment s3 prefix: $prefix"

return $prefix