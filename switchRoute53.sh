#!/bin/bash
#script to change Route53 name
#Pass in the ExternalDNS Alias name to switch the Route53 alias to
serviceName=$1
#clusterType=$2
#kubectl config use-context arn:aws:eks:us-east-2:364071744232:cluster/${clusterType}-cluster
hostedZoneID="Z3AADJGX6KTTL2"
echo Service :
kubectl get service $serviceName
echo .
lbHostname=""
retry=30
while [ "$lbHostname" == "" ]; do
  lbHostname=$(kubectl get service $serviceName -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ "$lbHostname" == "" ]; then sleep 1 ; else break ;fi
  let retry=$retry-1
  if [ "$retry" == "0" ]; then break; fi

done

echo $lbHostname , $hostedZoneID
inputJson="{\"Changes\": [{\"Action\": \"UPSERT\",\"ResourceRecordSet\": {\"Name\": \"mp-capstone.com\", \
    \"Type\": \"A\",\"AliasTarget\":{\"HostedZoneId\": \"$hostedZoneID\", \
        \"DNSName\":\"$lbHostname\" ,\"EvaluateTargetHealth\": false } }}] }"
echo $inputJson >record.json
aws route53 change-resource-record-sets --hosted-zone-id Z00239263PNAX6LDBU6B8 --change-batch file://record.json
