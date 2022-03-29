#!/bin/bash

METRIC_NAME="HTTPCode_Target_4XX_Count"
ALARM_PERIOD=60
ALARM_THRESHOLD=10
ALARM_SNS_ARN=arn:aws:sns:us-east-1:111122223333:MyTopic

# get interested metrics

TARGETS=$(aws cloudwatch list-metrics --namespace "AWS/ApplicationELB" --metric-name ${METRIC_NAME} | jq -r '.Metrics[].Dimensions[] | select(.Name=="TargetGroup") | .Value')

for target in ${TARGETS}
do
	aws cloudwatch put-metric-alarm --alarm-name "ELB-ALARM-TargetGroup-${target}" --alarm-description "Alarm for target group ${target}" --metric-name ${METRIC_NAME} --namespace AWS/ApplicationELB --statistic Sum --period ${ALARM_PERIOD} --threshold ${ALARM_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions "Name=TargetGroup,Value=${target}"  --evaluation-periods 1 --alarm-actions ${ALARM_SNS_ARN} --unit Count
done
