#!/bin/bash
#script to change Route53 name
#Pass in the ExternalDNS Alias name to switch the Route53 alias to
serviceName=$1
hostedZoneID="Z3AADJGX6KTTL2"
lbHostname=$(kubectl get service $serviceName -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $lbHostname , $hostedZoneID
inputJson="{\"Changes\": [{\"Action\": \"UPSERT\",\"ResourceRecordSet\": {\"Name\": \"mp-capstone.com\", \
    \"Type\": \"A\",\"AliasTarget\":{\"HostedZoneId\": \"$hostedZoneID\", \
	\"DNSName\":\"$lbHostname\" ,\"EvaluateTargetHealth\": false } }}] }"
echo $inputJson >record.json
aws route53 change-resource-record-sets --hosted-zone-id Z00239263PNAX6LDBU6B8 --change-batch file://record.json 
