param(
    $prefix = "https://s3-ap-southeast-2.amazonaws.com/bc-glenfiddich-local/aws-lego/integration-testing/",
    $region = "eu-west-1",
    $environment = "Test",
    $kp = "none-prod",
    $ubuntuAmi = "ami-ed82e39e"
)

.".\Deployment.ps1"
Set-DefaultAWSRegion $region

$tags = @(
    @{"Key" = "Project"; "Value" = "Glenlivet"},
    @{"Key" = "Environment"; "Value" = $environment}
)

# Network Create Start
$rawLogBucketName = "bc-raw-integrationtest-$([Guid]::NewGuid().ToString())"
$accessLogBucketName = "bc-access-integrationtest-$([Guid]::NewGuid().ToString())"
$elasticSearchBucketName = "bc-elasticsearch-$([Guid]::NewGuid().ToString())"
$logStore = Get-StackLinkParameters -StackParameters @(
    @{"Key" = "RawLogBucketName"; "Value" = $rawLogBucketName},
    @{"Key" = "AccessLogBucketName"; "Value" = $accessLogBucketName }
) -TemplateUrl "$($prefix)analytics/logs-store.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-LogStore
Wait-StackLink -StackLinkId $logStore

$vpc = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/vpc.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-PrimaryVpc
Wait-StackLink -StackLinkId $vpc

$gatewaySubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/public-out-subnets.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-GatewaySubnets

$privateSubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/private-subnets.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-PrivateSubnets

Wait-StackLink -StackLinkId $gatewaySubnets
$natGatewaySubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/nat-gateway-subnets.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-NatGateway

$webServerSubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/public-in-out-subnets.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-WebServerSubnets

Wait-StackLink -StackLinkId $natGatewaySubnets
$natEnabledSubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/nat-subnets.template"  |
    Upsert-StackLink -Tags $tags -StackName $environment-NatSubnets
Wait-StackLink -StackLinkId $natEnabledSubnets

$elbSubnets = Get-StackLinkParameters -TemplateUrl "$($prefix)networking/elb-subnets.template" |
    Upsert-StackLink -Tags $tags -StackName $environment-ElbSubnets
Wait-StackLink -StackLinkId $privateSubnets
Wait-StackLink -StackLinkId $webServerSubnets
Wait-StackLink -StackLinkId $elbSubnets
# Network Create Finish

# ElasticSearch Create Start
$elasticSearch = Get-StackLinkParameters -TemplateUrl "$($prefix)analytics/elasticsearch.template" -StackParameters @(
    @{"Key" = "KeyPairName"; "Value" = $kp},
    @{"Key" = "EsClusterAmi"; "Value" = $ubuntuAmi},
    @{"Key" = "SnapshotBucketName"; "Value" = $elasticSearchBucketName}
) | Upsert-StackLink -Tags $tags -StackName "$environment-Elasticsearch"
Wait-StackLink -StackLinkId $elasticSearch
$logstash = Get-StackLinkParameters -TemplateUrl "$($prefix)analytics/aws-logstash.template" -StackParameters @(
    @{"Key" = "KeyPairName"; "Value" = $kp},
    @{"Key" = "UbuntuAmi"; "Value" = $ubuntuAmi}
) | Upsert-StackLink -Tags $tags -StackName "$environment-Logstash"
Wait-StackLink -StackLinkId $logstash
# ElasticSearch Create Finish


function SuperRemove-S3Bucket {
    param($bucketName)
    Remove-S3BucketPolicy -BucketName $bucketName -Force
    Get-S3Version -BucketName $bucketName | % {
        $_.Versions | % {
            Remove-S3Object -BucketName $bucketName -Key $_.Key -VersionId $_.VersionId -Force
        }
    }
    Remove-S3Bucket -BucketName $bucketName -Force
}

# ElasticSearch Delete Start
Remove-CFNStack -StackName $elasticSearch -Force
Remove-CFNStack -StackName $logstash -Force
Wait-StackLink -StackLinkId $elasticSearch
Wait-StackLink -StackLinkId $logstash
# ElasticSearch Delete Finish

# Network Delete Start
Remove-CFNStack -StackName $elbSubnets -Force
Remove-CFNStack -StackName $webServerSubnets -Force
Remove-CFNStack -StackName $privateSubnets -Force
Wait-StackLink -StackLinkId $elbSubnets

Remove-CFNStack -StackName $natEnabledSubnets -Force
Wait-StackLink -StackLinkId $natEnabledSubnets

Remove-CFNStack -StackName $natGatewaySubnets -Force
Wait-StackLink -StackLinkId $natGatewaySubnets

Remove-CFNStack -StackName $gatewaySubnets -Force
Wait-StackLink -StackLinkId $gatewaySubnets

Wait-StackLink -StackLinkId $webServerSubnets
Wait-StackLink -StackLinkId $privateSubnets

Remove-CFNStack -StackName $vpc -Force
Wait-StackLink -StackLinkId $vpc

Remove-CFNStack -StackName $logStore -Force
Wait-StackLink $logStore

SuperRemove-S3Bucket -bucketName $rawLogBucketName
SuperRemove-S3Bucket -bucketName $elasticSearchBucketName
SuperRemove-S3Bucket -bucketName $accessLogBucketName
# Network Delete Finish