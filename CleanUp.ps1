param(
    $TempStackPrefix = "Test-"
)

function SuperRemove-S3Bucket {
    param($bucketName)
    $region = (Get-S3BucketLocation -BucketName $bucketName).Value
    Remove-S3BucketPolicy -BucketName $bucketName -Force -Region $region
    Get-S3Version -BucketName $bucketName -Region $region | % {
        $_.Versions | % {
            Remove-S3Object -BucketName $bucketName -Key $_.Key -VersionId $_.VersionId -Force -Region $region
        }
    }
    Remove-S3Bucket -BucketName $bucketName -Force -Region $region
}

Function CleanUp {
    param([string]$region)
    Set-DefaultAWSRegion $region

    Get-CFNStack | ? {
        $_.StackName.StartsWith($TempStackPrefix)
    } | % {
        Remove-CFNStack $_.StackId -Force
    }

    Get-S3Bucket | ? {
        $_.BucketName.StartsWith($TempStackPrefix.ToLower())
    } | ? {
        $bucketRegion = (Get-S3BucketLocation -BucketName $_.BucketName).Value
        return ($region -eq $bucketRegion)
    } | % {
        SuperRemove-S3Bucket -bucketName $_.BucketName
    }
}

CleanUp us-east-1
CleanUp us-east-2
CleanUp us-west-1
CleanUp us-west-2
CleanUp eu-west-1
CleanUp eu-central-1
CleanUp sa-east-1
CleanUp ap-northeast-1
CleanUp ap-northeast-2
CleanUp ap-southeast-1
CleanUp ap-southeast-2
