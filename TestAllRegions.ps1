param(
    $bucketname = "bc-glenfiddich-local",
    $projectname = "aws-lego",
    $version = "integration-testing"
)

$prefix = .\New-PrivateDeployment.ps1 -bucketname $bucketname -projectname $projectname -version $version

$regions = @(
    @{region = "us-east-1"; ubuntuId = "" },
    @{region = "us-west-1"; ubuntuId = "" },
    @{region = "us-west-2"; ubuntuId = "" },
    @{region = "eu-west-1"; ubuntuId = "" },
    @{region = "eu-central-1"; ubuntuId = "" },
    @{region = "ap-northeast-1"; ubuntuId = "" },
    @{region = "ap-northeast-2"; ubuntuId = "" },
    @{region = "ap-southeast-1"; ubuntuId = "" },
    @{region = "ap-southeast-2"; ubuntuId = "" }
    #@{region = "sa-east-1"; ubuntuId = "" }
)

$regions | % {
    .\ExecuteAllTemplates.ps1 -region $_.region -prefix $prefix -ubuntuAmi $ami.ImageId
}