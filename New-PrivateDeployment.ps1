param(
    $plcbucket = "local-glenfiddichbase-publicbucket-1mmtghaeejx68",
    $pvtbucket = "local-glenfiddichbase-privatebucket-1tw3hnwrqrrem",
    $region = "eu-west-1",
    $version = 'prod',
    $projectname = 'glenlivet'
)

Set-DefaultAWSRegion $region

cd $PSScriptRoot

function New-Deployment {
    param (
        [string]$bucketname,
        [string]$projectname,
        [string]$version,
        [string]$deployroot = ".\"
    )

    $prefix = "$projectname/$version/"
    $oldfiles = Get-S3Object -BucketName $bucketname -KeyPrefix $prefix | ? {
        $_.Key.EndsWith(".template")
    } | % {
        Write-Host "Removing > $($_.Key)"
        Remove-S3Object -BucketName $bucketname -Key $_.Key -Force
    }
    Write-S3Object -BucketName $bucketname -KeyPrefix $prefix -Folder $deployroot -Recurse -SearchPattern "*.template" | Out-Null

    # now test the templates.
    $region = (Get-DefaultAWSRegion).Region
    Get-S3Object -BucketName $bucketname -KeyPrefix $prefix | ? {
        $_.Key.EndsWith(".template")
    } | % {
        Write-Host "Testing > $($_.Key)"
        Write-Host (Test-CFNTemplate -TemplateURL "https://s3-$region.amazonaws.com/$bucketname/$($_.Key)")
    } | Out-Null

    $deploymentUrl = "https://s3-$region.amazonaws.com/$bucketname/$projectname/$version/"
    return $deploymentUrl
}

Get-S3Object -BucketName $pvtbucket -KeyPrefix "$projectname/$version/cache" | % {
    Remove-S3Object -BucketName $pvtbucket -Key $_.Key -Force
}
$prefix = New-Deployment -bucketname $plcbucket -projectname $projectname -version $version -deployroot ".\"

Write-Host "Deployment s3 prefix: $prefix"

return $prefix