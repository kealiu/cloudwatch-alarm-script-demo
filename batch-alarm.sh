#!/bin/bash

METRIC_NAME="HTTPCode_Target_4XX_Count"
ALARM_PERIOD=60
ALARM_THRESHOLD=10
ALARM_COUNTS=1
ALARM_SNS_ARN=arn:aws:sns:us-east-1:111122223333:MyTopic

# get interested metrics
# refer: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudwatch/list-metrics.html
TARGETS=$(aws cloudwatch list-metrics --namespace "AWS/ApplicationELB" --metric-name ${METRIC_NAME} | jq -r '.Metrics[].Dimensions[] | select(.Name=="TargetGroup") | .Value')

# create alarms for all target group
# refer: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudwatch/put-metric-alarm.html
for target in ${TARGETS}
do
	aws cloudwatch put-metric-alarm --alarm-name "ELB-ALARM-TargetGroup-${target}" --alarm-description "Alarm for target group ${target}" --metric-name ${METRIC_NAME} --namespace AWS/ApplicationELB --statistic Sum --period ${ALARM_PERIOD} --threshold ${ALARM_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions "Name=TargetGroup,Value=${target}"  --evaluation-periods ${ALARM_COUNTS} --alarm-actions ${ALARM_SNS_ARN} --unit Count
done
