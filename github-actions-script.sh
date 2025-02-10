#!/bin/bash

# # Checks whether a repository has CHANGELOG.md.
# # Checks that each commit to the repository is updated in the CHANGELOG.md.
# # The CHANGELOG version number is updated in the format # 1.0.2, # 12.3.10, # 1.10.1
# #Checks that there is jira ticket number associated with the commit.

# #Checking if CHANGELOG.md exists
echo "Checking for CHANGELOG.md"

if [ ! -f "CHANGELOG.md" ]
then
    echo "::error::CHANGELOG file NOT FOUND"
    exit 1
else
    echo "CHANGELOG.md  found"
fi

# ## Checks if there is version number.
# ## The version here could be any number of digits provided defined in the following order:
# ## 1.0.0, # 20.5.1, # 1.203.4

version=$(egrep -o "# [0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" CHANGELOG.md)

if [[ -z "${version}" ]];
then
    echo -e "\CHANGELOG.md must have a version number.\n"
    exit
    else
    echo -e "\Available Version numbers listed below.\n"
    echo "$version"
fi

# ## Check if jira ticket number is documented.
# ## This will identify the most recent jira ticket.
 jira_ticket=$(git log --oneline --no-merges | egrep -o [A-Z]*-[0-9]* CHANGELOG.md)

    if [[ -z "${jira_ticket}"  ]]
    then
        echo -e "\nCommit-log is missing a Jira ticket number.\n"
        exit 1
    else
        echo -e "\nJira ticket from commit-log is <${jira_ticket}>\n"
    fi

echo -e "\nPull-Request files are excellent.\n"


echo "egrep -o "# [0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}"
#git diff main..PENG-20792 CHANGELOG | egrep '+version'
#This checks if the most recent version is updated
#It works by comparing the newer version to the older one.
#Hence, it will not work if the commit is an initial one.
#It compares the version in the main to that of the branch being pushed/PR.

NEW_COMMIT=$(git diff main..GOVT-20792 -- CHANGELOG.md | egrep -o "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" | head -n 1)
echo $NEW_COMMIT
OLD_COMMIT=$(git diff main..GOVT-20792 -- CHANGELOG.md | egrep -o "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" | head -2 | tail -1)
echo $OLD_COMMIT

nv1=$NEW_COMMIT
nv2=$OLD_COMMIT

echo ${nv1//./}
echo ${nv2//./}


if [[ ${nv1//./} -gt ${nv2//./} ]]; then
 echo "version is updated"
else
 echo "please update version"
fi



Aggregation

AWSTemplateFormatVersion: 2010-09-09
Resources:
  Bucket83908E77:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      Tags:
        - Key: 'aws-cdk:auto-delete-objects'
          Value: 'true'
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
  BucketPolicyE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref Bucket83908E77
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - Bucket83908E77
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - Bucket83908E77
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketPolicyQueryE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref QueryResultBucket148F46A4
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketAutoDeleteObjectsCustomResourceBAFD23C2:
    Type: 'Custom::S3AutoDeleteObjects'
    Properties:
      ServiceToken: !GetAtt 
        - CustomS3AutoDeleteObjectsCustomResourceProviderHandler9D90184F
        - Arn
      BucketName: !Ref Bucket83908E77
    DependsOn:
      - BucketPolicyE9A3008A
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
  BucketNotifications8F2E257D:
    Type: 'Custom::S3BucketNotifications'
    Properties:
      ServiceToken: !GetAtt 
        - BucketNotificationsHandler050a0587b7544547bf325f094a3db8347ECC3691
        - Arn
      BucketName: !Ref Bucket83908E77
      NotificationConfiguration:
        LambdaFunctionConfigurations:
          - Events:
              - 's3:ObjectCreated:*'
            LambdaFunctionArn: !GetAtt 
              - TransformFindings22CD8B75VP8pE7Rfglxa
              - Arn
      Managed: true
    DependsOn:
      - >-
        Bucket2AllowBucketNotificationsToAnalyticSinkTransformFindings358E3E79B06D8FB6
  Bucket2AllowBucketNotificationsToAnalyticSinkTransformFindings358E3E79B06D8FB6:
    Type: 'AWS::Lambda::Permission'
    Properties:
      Action: 'lambda:InvokeFunction'
      FunctionName: !GetAtt 
        - TransformFindings22CD8B75VP8pE7Rfglxa
        - Arn
      Principal: s3.amazonaws.com
      SourceAccount: !Ref 'AWS::AccountId'
      SourceArn: !GetAtt 
        - Bucket83908E77
        - Arn      
  CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
      ManagedPolicyArns:
        - !Sub >-
          arn:${AWS::Partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
  CustomS3AutoDeleteObjectsCustomResourceProviderHandler9D90184F:
    Type: 'AWS::Lambda::Function'
    Properties:
      Code:
        S3Bucket: !Ref >-
          S3bucketnameforCustomS3AutoDeleteObjectsCustomResourceProvider
        S3Key: !Join 
          - ''
          - - !Select 
              - 0
              - !Split 
                - '||'
                - !Ref >-
                  S3keyforCustomS3AutoDeleteObjectsCustomResourceProvider
      Description: !Join 
        - ''
        - - 'Lambda function for auto-deleting objects in '
          - !Ref Bucket83908E77
          - ' S3 bucket.'
      Handler: __entrypoint__.handler
      MemorySize: 128
      Role: !GetAtt 
      - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
      - Arn
      Runtime: nodejs14.x
      Timeout: 900
  QueryResultBucket148F46A4:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
    UpdateReplacePolicy: Retain
    DeletionPolicy: Retain
  TransformFindingsServiceRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: 2012-10-17
      ManagedPolicyArns:
        - !Join 
          - ''
          - - 'arn:'
            - !Ref 'AWS::Partition'
            - ':iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
  BucketParameterEB93D4D4:
    Type: 'AWS::SSM::Parameter'
    Properties:
      Type: String
      Value: !Ref Bucket83908E77
      Name: /AnalyticSinkStack/BucketName
  BucketArn8ED098D6:
    Type: 'AWS::SSM::Parameter'
    Properties:
      Type: String
      Value: !GetAtt 
        - Bucket83908E77
        - Arn
      Name: /AnalyticSinkStack/BucketArn
  TransformFindings22CD8B75VP8pE7Rfglxa:
    Type: 'AWS::Lambda::Function'
    Properties:
      Code:
        S3Bucket: !Ref >-
          S3bucketnameforTransformFindings
        S3Key: !Join 
          - ''
          - - !Select 
              - 0
              - !Split 
                - '||'
                - !Ref >-
                  S3keyforTransformFindings
      Description: 'lambda function that optimizes data for athena query and outputs to an s3 bucket'
      Handler: index.handler
      MemorySize: 2048
      Role: !GetAtt 
      - TransformFindingsServiceRole
      - Arn
      Runtime: python3.8
      Timeout: 900
      Environment:
        Variables:
          source_bucket_name: analyticsink-bucket83908e77-ihzuru7he6jq
          destination_bucket_name: analyticsink-queryresultbucket148f46a4-kqj74x4h6gnq
          destination_prefix: Findings
      Tags:
        - Key: 'lambda:createdBy'
          Value: SAM
  TransformFindingsServiceRoleDefaultPolicyFBD97DC1:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
              - 's3:Abort*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - Bucket83908E77
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - Bucket83908E77
                    - Arn
                  - /*
        Version: 2012-10-17
      PolicyName: TransformFindingsServiceRoleDefaultPolicyFBD97DC1
      Roles:
        - !Ref TransformFindingsServiceRole
  TransformFindingsQueryServiceRoleDefaultPolicyFBD97DC1:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucketAcl'
              - 's3:List*'
              - 's3:DeleteObject*'
              - 's3:PutObject'
              - 's3:PutObjectAcl'
              - 's3:AbortMultipartUpload'
              - 's3:PutObjectLegalHold'
              - 's3:PutObjectRetention'
              - 's3:PutObjectTagging'
              - 's3:PutObjectVersionTagging'
              - 's3:Abort*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
      PolicyName: TransformFindingsQueryServiceRoleDefaultPolicyFBD97DC1
      Roles:
        - !Ref TransformFindingsServiceRole
  QueryBucketPolicyE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref QueryResultBucket148F46A4
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: 2012-10-17
      ManagedPolicyArns:
        - !Join 
          - ''
          - - 'arn:'
            - !Ref 'AWS::Partition'
            - ':iam::aws:policy/service-role/AWSLambdaBasicExecutionRole' 
  BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleDefaultPolicy2CF63D36:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action: 's3:PutBucketNotification'
            Effect: Allow
            Resource: '*'
        Version: 2012-10-17
      PolicyName: >-
        BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleDefaultPolicy2CF63D36
      Roles:
        - !Ref BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC   
  BucketNotificationsHandler050a0587b7544547bf325f094a3db8347ECC3691:
    Type: 'AWS::Lambda::Function'
    Properties:
      Description: >-
        AWS CloudFormation handler for "Custom::S3BucketNotifications" resources
        (@aws-cdk/aws-s3)
      Code:
        ZipFile: >
          import boto3  # type: ignore

          import json

          import logging

          import urllib.request


          s3 = boto3.client("s3")


          EVENTBRIDGE_CONFIGURATION = 'EventBridgeConfiguration'


          CONFIGURATION_TYPES = ["TopicConfigurations", "QueueConfigurations",
          "LambdaFunctionConfigurations"]


          def handler(event: dict, context):
            response_status = "SUCCESS"
            error_message = ""
            try:
              props = event["ResourceProperties"]
              bucket = props["BucketName"]
              notification_configuration = props["NotificationConfiguration"]
              request_type = event["RequestType"]
              managed = props.get('Managed', 'true').lower() == 'true'
              stack_id = event['StackId']

              if managed:
                config = handle_managed(request_type, notification_configuration)
              else:
                config = handle_unmanaged(bucket, stack_id, request_type, notification_configuration)

              put_bucket_notification_configuration(bucket, config)
            except Exception as e:
              logging.exception("Failed to put bucket notification configuration")
              response_status = "FAILED"
              error_message = f"Error: {str(e)}. "
            finally:
              submit_response(event, context, response_status, error_message)

          def handle_managed(request_type, notification_configuration):
            if request_type == 'Delete':
              return {}
            return notification_configuration

          def handle_unmanaged(bucket, stack_id, request_type,
          notification_configuration):
            external_notifications = find_external_notifications(bucket, stack_id)

            if request_type == 'Delete':
              return external_notifications

            def with_id(notification):
              notification['Id'] = f"{stack_id}-{hash(json.dumps(notification, sort_keys=True))}"
              return notification

            notifications = {}
            for t in CONFIGURATION_TYPES:
              external = external_notifications.get(t, [])
              incoming = [with_id(n) for n in notification_configuration.get(t, [])]
              notifications[t] = external + incoming

            if EVENTBRIDGE_CONFIGURATION in notification_configuration:
              notifications[EVENTBRIDGE_CONFIGURATION] = notification_configuration[EVENTBRIDGE_CONFIGURATION]
            elif EVENTBRIDGE_CONFIGURATION in external_notifications:
              notifications[EVENTBRIDGE_CONFIGURATION] = external_notifications[EVENTBRIDGE_CONFIGURATION]

            return notifications

          def find_external_notifications(bucket, stack_id):
            existing_notifications = get_bucket_notification_configuration(bucket)
            external_notifications = {}
            for t in CONFIGURATION_TYPES:
              external_notifications[t] = [n for n in existing_notifications.get(t, []) if not n['Id'].startswith(f"{stack_id}-")]

            if EVENTBRIDGE_CONFIGURATION in existing_notifications:
              external_notifications[EVENTBRIDGE_CONFIGURATION] = existing_notifications[EVENTBRIDGE_CONFIGURATION]

            return external_notifications

          def get_bucket_notification_configuration(bucket):
            return s3.get_bucket_notification_configuration(Bucket=bucket)

          def put_bucket_notification_configuration(bucket,
          notification_configuration):
            s3.put_bucket_notification_configuration(Bucket=bucket, NotificationConfiguration=notification_configuration)

          def submit_response(event: dict, context, response_status: str,
          error_message: str):
            response_body = json.dumps(
              {
                "Status": response_status,
                "Reason": f"{error_message}See the details in CloudWatch Log Stream: {context.log_stream_name}",
                "PhysicalResourceId": event.get("PhysicalResourceId") or event["LogicalResourceId"],
                "StackId": event["StackId"],
                "RequestId": event["RequestId"],
                "LogicalResourceId": event["LogicalResourceId"],
                "NoEcho": False,
              }
            ).encode("utf-8")
            headers = {"content-type": "", "content-length": str(len(response_body))}
            try:
              req = urllib.request.Request(url=event["ResponseURL"], headers=headers, data=response_body, method="PUT")
              with urllib.request.urlopen(req) as response:
                print(response.read().decode("utf-8"))
              print("Status code: " + response.reason)
            except Exception as e:
                print("send(..) failed executing request.urlopen(..): " + str(e))
      Handler: index.handler
      Role: !GetAtt 
        - BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC
        - Arn
      Runtime: python3.7
      Timeout: 300  
  CrawlerRoleA9495AEE:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: glue.amazonaws.com
        Version: 2012-10-17
  CrawlerRoleDefaultPolicy145A4322:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucket*'
              - 's3:List*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
          - Action:
              - 's3:GetBucketLocation'
              - 's3:ListBucket'
              - 's3:ListAllMyBuckets'
              - 's3:GetBucketAcl'
            Effect: Allow
            Resource: !Join 
              - ''
              - - !GetAtt 
                  - QueryResultBucket148F46A4
                  - Arn
                - '*'
          - Action:
              - 'glue:*'
              - 'iam:ListRolePolicies'
              - 'iam:GetRole'
              - 'iam:GetRolePolicy'
            Effect: Allow
            Resource: '*'
          - Action: 's3:GetObject'
            Effect: Allow
            Resource:
              - 'arn:aws:s3:::crawler-public*'
              - 'arn:aws:s3:::aws-glue-*'
          - Action:
              - 'logs:CreateLogGroup'
              - 'logs:CreateLogStream'
              - 'logs:PutLogEvents'
            Effect: Allow
            Resource: 'arn:aws:logs:*:*:/aws-glue/*'
        Version: 2012-10-17
      PolicyName: CrawlerRoleDefaultPolicy145A4322
      Roles:
        - !Ref CrawlerRoleA9495AEE
  SecurityHubDatabase138DA1F1:
    Type: 'AWS::Glue::Database'
    Properties:
      CatalogId: !Ref 'AWS::AccountId'
      DatabaseInput:
        Name: security_hub_database
  SecurityHubCrawler:
    Type: 'AWS::Glue::Crawler'
    Properties:
      Role: !GetAtt 
        - CrawlerRoleA9495AEE
        - Arn
      Targets:
        S3Targets:
          - Path: !Join 
              - ''
              - - 's3://'
                - !Ref QueryResultBucket148F46A4
                - /Findings
      DatabaseName: !Ref SecurityHubDatabase138DA1F1
      Name: SecurityHubCrawler
      Schedule:
        ScheduleExpression: cron(0 0/1 * * ? *)
      TablePrefix: security-hub-crawled-
Parameters:
  S3bucketnameforCustomS3AutoDeleteObjectsCustomResourceProvider:
    Type: String
    Description: >-
      S3 bucket for asset
      "aws-securityhub-233675669795"
  S3keyforCustomS3AutoDeleteObjectsCustomResourceProvider:
    Type: String
    Description: >-
      S3 key for asset version
      "AnalyticSink-CustomS3AutoDeleteObjectsCustomResource.zip"
  S3bucketnameforTransformFindings:
    Type: String
    Description: >-
      S3 bucket for asset
      "aws-securityhub-233675669795"
  S3keyforTransformFindings:
    Type: String
    Description: >-
      S3 key for asset version
      "AnalyticSink-TransformFindings.zip"

Analyzing
AWSTemplateFormatVersion: 2010-09-09
Resources:
  Bucket83908E77:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      Tags:
        - Key: 'aws-cdk:auto-delete-objects'
          Value: 'true'
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
  BucketPolicyE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref Bucket83908E77
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - Bucket83908E77
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - Bucket83908E77
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketPolicyQueryE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref QueryResultBucket148F46A4
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketAutoDeleteObjectsCustomResourceBAFD23C2:
    Type: 'Custom::S3AutoDeleteObjects'
    Properties:
      ServiceToken: !GetAtt 
        - CustomS3AutoDeleteObjectsCustomResourceProviderHandler9D90184F
        - Arn
      BucketName: !Ref Bucket83908E77
    DependsOn:
      - BucketPolicyE9A3008A
    UpdateReplacePolicy: Delete
    DeletionPolicy: Delete
  BucketNotifications8F2E257D:
    Type: 'Custom::S3BucketNotifications'
    Properties:
      ServiceToken: !GetAtt 
        - BucketNotificationsHandler050a0587b7544547bf325f094a3db8347ECC3691
        - Arn
      BucketName: !Ref Bucket83908E77
      NotificationConfiguration:
        LambdaFunctionConfigurations:
          - Events:
              - 's3:ObjectCreated:*'
            LambdaFunctionArn: !GetAtt 
              - TransformFindings22CD8B75VP8pE7Rfglxa
              - Arn
      Managed: true
    DependsOn:
      - >-
        Bucket2AllowBucketNotificationsToAnalyticSinkTransformFindings358E3E79B06D8FB6
  Bucket2AllowBucketNotificationsToAnalyticSinkTransformFindings358E3E79B06D8FB6:
    Type: 'AWS::Lambda::Permission'
    Properties:
      Action: 'lambda:InvokeFunction'
      FunctionName: !GetAtt 
        - TransformFindings22CD8B75VP8pE7Rfglxa
        - Arn
      Principal: s3.amazonaws.com
      SourceAccount: !Ref 'AWS::AccountId'
      SourceArn: !GetAtt 
        - Bucket83908E77
        - Arn      
  CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
      ManagedPolicyArns:
        - !Sub >-
          arn:${AWS::Partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
  CustomS3AutoDeleteObjectsCustomResourceProviderHandler9D90184F:
    Type: 'AWS::Lambda::Function'
    Properties:
      Code:
        S3Bucket: !Ref >-
          S3bucketnameforCustomS3AutoDeleteObjectsCustomResourceProvider
        S3Key: !Join 
          - ''
          - - !Select 
              - 0
              - !Split 
                - '||'
                - !Ref >-
                  S3keyforCustomS3AutoDeleteObjectsCustomResourceProvider
      Description: !Join 
        - ''
        - - 'Lambda function for auto-deleting objects in '
          - !Ref Bucket83908E77
          - ' S3 bucket.'
      Handler: __entrypoint__.handler
      MemorySize: 128
      Role: !GetAtt 
      - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
      - Arn
      Runtime: nodejs14.x
      Timeout: 900
  QueryResultBucket148F46A4:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
    UpdateReplacePolicy: Retain
    DeletionPolicy: Retain
  TransformFindingsServiceRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: 2012-10-17
      ManagedPolicyArns:
        - !Join 
          - ''
          - - 'arn:'
            - !Ref 'AWS::Partition'
            - ':iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
  BucketParameterEB93D4D4:
    Type: 'AWS::SSM::Parameter'
    Properties:
      Type: String
      Value: !Ref Bucket83908E77
      Name: /AnalyticSinkStack/BucketName
  BucketArn8ED098D6:
    Type: 'AWS::SSM::Parameter'
    Properties:
      Type: String
      Value: !GetAtt 
        - Bucket83908E77
        - Arn
      Name: /AnalyticSinkStack/BucketArn
  TransformFindings22CD8B75VP8pE7Rfglxa:
    Type: 'AWS::Lambda::Function'
    Properties:
      Code:
        S3Bucket: !Ref >-
          S3bucketnameforTransformFindings
        S3Key: !Join 
          - ''
          - - !Select 
              - 0
              - !Split 
                - '||'
                - !Ref >-
                  S3keyforTransformFindings
      Description: 'lambda function that optimizes data for athena query and outputs to an s3 bucket'
      Handler: index.handler
      MemorySize: 2048
      Role: !GetAtt 
      - TransformFindingsServiceRole
      - Arn
      Runtime: python3.8
      Timeout: 900
      Environment:
        Variables:
          source_bucket_name: analyticsink-bucket83908e77-ihzuru7he6jq
          destination_bucket_name: analyticsink-queryresultbucket148f46a4-kqj74x4h6gnq
          destination_prefix: Findings
      Tags:
        - Key: 'lambda:createdBy'
          Value: SAM
  TransformFindingsServiceRoleDefaultPolicyFBD97DC1:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
              - 's3:Abort*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - Bucket83908E77
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - Bucket83908E77
                    - Arn
                  - /*
        Version: 2012-10-17
      PolicyName: TransformFindingsServiceRoleDefaultPolicyFBD97DC1
      Roles:
        - !Ref TransformFindingsServiceRole
  TransformFindingsQueryServiceRoleDefaultPolicyFBD97DC1:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucketAcl'
              - 's3:List*'
              - 's3:DeleteObject*'
              - 's3:PutObject'
              - 's3:PutObjectAcl'
              - 's3:AbortMultipartUpload'
              - 's3:PutObjectLegalHold'
              - 's3:PutObjectRetention'
              - 's3:PutObjectTagging'
              - 's3:PutObjectVersionTagging'
              - 's3:Abort*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
      PolicyName: TransformFindingsQueryServiceRoleDefaultPolicyFBD97DC1
      Roles:
        - !Ref TransformFindingsServiceRole
  QueryBucketPolicyE9A3008A:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref QueryResultBucket148F46A4
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetBucket*'
              - 's3:List*'
              - 's3:DeleteObject*'
            Effect: Allow
            Principal:
              AWS: !GetAtt 
                - CustomS3AutoDeleteObjectsCustomResourceProviderRole3B1BD092
                - Arn
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
        Version: 2012-10-17
  BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: 2012-10-17
      ManagedPolicyArns:
        - !Join 
          - ''
          - - 'arn:'
            - !Ref 'AWS::Partition'
            - ':iam::aws:policy/service-role/AWSLambdaBasicExecutionRole' 
  BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleDefaultPolicy2CF63D36:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action: 's3:PutBucketNotification'
            Effect: Allow
            Resource: '*'
        Version: 2012-10-17
      PolicyName: >-
        BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleDefaultPolicy2CF63D36
      Roles:
        - !Ref BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC   
  BucketNotificationsHandler050a0587b7544547bf325f094a3db8347ECC3691:
    Type: 'AWS::Lambda::Function'
    Properties:
      Description: >-
        AWS CloudFormation handler for "Custom::S3BucketNotifications" resources
        (@aws-cdk/aws-s3)
      Code:
        ZipFile: >
          import boto3  # type: ignore

          import json

          import logging

          import urllib.request


          s3 = boto3.client("s3")


          EVENTBRIDGE_CONFIGURATION = 'EventBridgeConfiguration'


          CONFIGURATION_TYPES = ["TopicConfigurations", "QueueConfigurations",
          "LambdaFunctionConfigurations"]


          def handler(event: dict, context):
            response_status = "SUCCESS"
            error_message = ""
            try:
              props = event["ResourceProperties"]
              bucket = props["BucketName"]
              notification_configuration = props["NotificationConfiguration"]
              request_type = event["RequestType"]
              managed = props.get('Managed', 'true').lower() == 'true'
              stack_id = event['StackId']

              if managed:
                config = handle_managed(request_type, notification_configuration)
              else:
                config = handle_unmanaged(bucket, stack_id, request_type, notification_configuration)

              put_bucket_notification_configuration(bucket, config)
            except Exception as e:
              logging.exception("Failed to put bucket notification configuration")
              response_status = "FAILED"
              error_message = f"Error: {str(e)}. "
            finally:
              submit_response(event, context, response_status, error_message)

          def handle_managed(request_type, notification_configuration):
            if request_type == 'Delete':
              return {}
            return notification_configuration

          def handle_unmanaged(bucket, stack_id, request_type,
          notification_configuration):
            external_notifications = find_external_notifications(bucket, stack_id)

            if request_type == 'Delete':
              return external_notifications

            def with_id(notification):
              notification['Id'] = f"{stack_id}-{hash(json.dumps(notification, sort_keys=True))}"
              return notification

            notifications = {}
            for t in CONFIGURATION_TYPES:
              external = external_notifications.get(t, [])
              incoming = [with_id(n) for n in notification_configuration.get(t, [])]
              notifications[t] = external + incoming

            if EVENTBRIDGE_CONFIGURATION in notification_configuration:
              notifications[EVENTBRIDGE_CONFIGURATION] = notification_configuration[EVENTBRIDGE_CONFIGURATION]
            elif EVENTBRIDGE_CONFIGURATION in external_notifications:
              notifications[EVENTBRIDGE_CONFIGURATION] = external_notifications[EVENTBRIDGE_CONFIGURATION]

            return notifications

          def find_external_notifications(bucket, stack_id):
            existing_notifications = get_bucket_notification_configuration(bucket)
            external_notifications = {}
            for t in CONFIGURATION_TYPES:
              external_notifications[t] = [n for n in existing_notifications.get(t, []) if not n['Id'].startswith(f"{stack_id}-")]

            if EVENTBRIDGE_CONFIGURATION in existing_notifications:
              external_notifications[EVENTBRIDGE_CONFIGURATION] = existing_notifications[EVENTBRIDGE_CONFIGURATION]

            return external_notifications

          def get_bucket_notification_configuration(bucket):
            return s3.get_bucket_notification_configuration(Bucket=bucket)

          def put_bucket_notification_configuration(bucket,
          notification_configuration):
            s3.put_bucket_notification_configuration(Bucket=bucket, NotificationConfiguration=notification_configuration)

          def submit_response(event: dict, context, response_status: str,
          error_message: str):
            response_body = json.dumps(
              {
                "Status": response_status,
                "Reason": f"{error_message}See the details in CloudWatch Log Stream: {context.log_stream_name}",
                "PhysicalResourceId": event.get("PhysicalResourceId") or event["LogicalResourceId"],
                "StackId": event["StackId"],
                "RequestId": event["RequestId"],
                "LogicalResourceId": event["LogicalResourceId"],
                "NoEcho": False,
              }
            ).encode("utf-8")
            headers = {"content-type": "", "content-length": str(len(response_body))}
            try:
              req = urllib.request.Request(url=event["ResponseURL"], headers=headers, data=response_body, method="PUT")
              with urllib.request.urlopen(req) as response:
                print(response.read().decode("utf-8"))
              print("Status code: " + response.reason)
            except Exception as e:
                print("send(..) failed executing request.urlopen(..): " + str(e))
      Handler: index.handler
      Role: !GetAtt 
        - BucketNotificationsHandler050a0587b7544547bf325f094a3db834RoleB6FB88EC
        - Arn
      Runtime: python3.7
      Timeout: 300  
  CrawlerRoleA9495AEE:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: 'sts:AssumeRole'
            Effect: Allow
            Principal:
              Service: glue.amazonaws.com
        Version: 2012-10-17
  CrawlerRoleDefaultPolicy145A4322:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyDocument:
        Statement:
          - Action:
              - 's3:GetObject*'
              - 's3:GetBucket*'
              - 's3:List*'
            Effect: Allow
            Resource:
              - !GetAtt 
                - QueryResultBucket148F46A4
                - Arn
              - !Join 
                - ''
                - - !GetAtt 
                    - QueryResultBucket148F46A4
                    - Arn
                  - /*
          - Action:
              - 's3:GetBucketLocation'
              - 's3:ListBucket'
              - 's3:ListAllMyBuckets'
              - 's3:GetBucketAcl'
            Effect: Allow
            Resource: !Join 
              - ''
              - - !GetAtt 
                  - QueryResultBucket148F46A4
                  - Arn
                - '*'
          - Action:
              - 'glue:*'
              - 'iam:ListRolePolicies'
              - 'iam:GetRole'
              - 'iam:GetRolePolicy'
            Effect: Allow
            Resource: '*'
          - Action: 's3:GetObject'
            Effect: Allow
            Resource:
              - 'arn:aws:s3:::crawler-public*'
              - 'arn:aws:s3:::aws-glue-*'
          - Action:
              - 'logs:CreateLogGroup'
              - 'logs:CreateLogStream'
              - 'logs:PutLogEvents'
            Effect: Allow
            Resource: 'arn:aws:logs:*:*:/aws-glue/*'
        Version: 2012-10-17
      PolicyName: CrawlerRoleDefaultPolicy145A4322
      Roles:
        - !Ref CrawlerRoleA9495AEE
  SecurityHubDatabase138DA1F1:
    Type: 'AWS::Glue::Database'
    Properties:
      CatalogId: !Ref 'AWS::AccountId'
      DatabaseInput:
        Name: security_hub_database
  SecurityHubCrawler:
    Type: 'AWS::Glue::Crawler'
    Properties:
      Role: !GetAtt 
        - CrawlerRoleA9495AEE
        - Arn
      Targets:
        S3Targets:
          - Path: !Join 
              - ''
              - - 's3://'
                - !Ref QueryResultBucket148F46A4
                - /Findings
      DatabaseName: !Ref SecurityHubDatabase138DA1F1
      Name: SecurityHubCrawler
      Schedule:
        ScheduleExpression: cron(0 0/1 * * ? *)
      TablePrefix: security-hub-crawled-
Parameters:
  S3bucketnameforCustomS3AutoDeleteObjectsCustomResourceProvider:
    Type: String
    Description: >-
      S3 bucket for asset
      "aws-securityhub-233675669795"
  S3keyforCustomS3AutoDeleteObjectsCustomResourceProvider:
    Type: String
    Description: >-
      S3 key for asset version
      "AnalyticSink-CustomS3AutoDeleteObjectsCustomResource.zip"
  S3bucketnameforTransformFindings:
    Type: String
    Description: >-
      S3 bucket for asset
      "aws-securityhub-233675669795"
  S3keyforTransformFindings:
    Type: String
    Description: >-
      S3 key for asset version
      "AnalyticSink-TransformFindings.zip"





**********

import boto3
import json

def get_all_regions(profile_name):
    """Fetches all available AWS regions for the given profile."""
    session = boto3.Session(profile_name=profile_name)
    ec2_client = session.client("ec2", region_name="us-east-1")
    return [region["RegionName"] for region in ec2_client.describe_regions()["Regions"]]

def list_unattached_security_groups(ec2_client):
    """Finds security groups that are not attached to any resource."""
    sg_response = ec2_client.describe_security_groups()["SecurityGroups"]
    eni_response = ec2_client.describe_network_interfaces()["NetworkInterfaces"]

    attached_sgs = {sg for eni in eni_response for sg in eni["Groups"]}
    unattached_sgs = [sg for sg in sg_response if sg["GroupId"] not in attached_sgs]

    return unattached_sgs

def delete_unattached_security_groups(ec2_client, region):
    """Lists and optionally deletes unattached security groups."""
    unattached_sgs = list_unattached_security_groups(ec2_client)
    if not unattached_sgs:
        print(f"No unattached security groups found in {region}.")
        return

    print(f"\nUnattached Security Groups in {region}:")
    for sg in unattached_sgs:
        print(f"  - {sg['GroupId']} ({sg['GroupName']})")

    confirm = input("\nDelete all unattached security groups? (yes/no): ").strip().lower()
    if confirm == "yes":
        for sg in unattached_sgs:
            try:
                ec2_client.delete_security_group(GroupId=sg["GroupId"])
                print(f"Deleted: {sg['GroupId']} ({sg['GroupName']})")
            except Exception as e:
                print(f"Failed to delete {sg['GroupId']}: {e}")

def list_and_fix_open_security_groups(ec2_client, region):
    """Lists security groups open to the internet and optionally restricts them to VPC CIDR."""
    sg_response = ec2_client.describe_security_groups()["SecurityGroups"]
    vpcs = {vpc["VpcId"]: vpc["CidrBlock"] for vpc in ec2_client.describe_vpcs()["Vpcs"]}

    open_sgs = []
    for sg in sg_response:
        vpc_cidr = vpcs.get(sg["VpcId"], "Unknown VPC CIDR")
        for rule in sg.get("IpPermissions", []):
            for ip_range in rule.get("IpRanges", []):
                if ip_range["CidrIp"] == "0.0.0.0/0":
                    open_sgs.append((sg, vpc_cidr))
                    break

    if not open_sgs:
        print(f"No security groups found open to the internet in {region}.")
        return

    print(f"\nSecurity Groups Open to the Internet in {region}:")
    for sg, vpc_cidr in open_sgs:
        print(f"  - {sg['GroupId']} ({sg['GroupName']}) | VPC CIDR: {vpc_cidr}")

    confirm = input("\nReplace 0.0.0.0/0 with VPC CIDR? (yes/no): ").strip().lower()
    if confirm == "yes":
        for sg, vpc_cidr in open_sgs:
            try:
                for rule in sg["IpPermissions"]:
                    for ip_range in rule.get("IpRanges", []):
                        if ip_range["CidrIp"] == "0.0.0.0/0":
                            ec2_client.revoke_security_group_ingress(
                                GroupId=sg["GroupId"],
                                IpProtocol=rule["IpProtocol"],
                                FromPort=rule["FromPort"],
                                ToPort=rule["ToPort"],
                                CidrIp="0.0.0.0/0"
                            )
                            ec2_client.authorize_security_group_ingress(
                                GroupId=sg["GroupId"],
                                IpProtocol=rule["IpProtocol"],
                                FromPort=rule["FromPort"],
                                ToPort=rule["ToPort"],
                                CidrIp=vpc_cidr
                            )
                print(f"Updated: {sg['GroupId']} ({sg['GroupName']}) - Now restricted to {vpc_cidr}")
            except Exception as e:
                print(f"Failed to update {sg['GroupId']}: {e}")

def main():
    """Main function to run the security group cleanup process."""
    profile_name = input("Enter AWS profile name: ").strip()
    regions = get_all_regions(profile_name)

    print("\nAvailable AWS Regions:")
    for i, region in enumerate(regions):
        print(f"  {i + 1}. {region}")

    selected_regions = input("\nEnter region numbers (comma-separated) or 'all': ").strip()
    if selected_regions.lower() == "all":
        selected_regions = regions
    else:
        selected_regions = [regions[int(i) - 1] for i in selected_regions.split(",") if i.isdigit()]

    for region in selected_regions:
        print(f"\nProcessing region: {region}")
        session = boto3.Session(profile_name=profile_name, region_name=region)
        ec2_client = session.client("ec2")

        delete_unattached_security_groups(ec2_client, region)
        list_and_fix_open_security_groups(ec2_client, region)

if __name__ == "__main__":
    main()

######

import boto3
import json
import sys

def get_all_regions(profile_name):
    """Fetches all available AWS regions for the given profile."""
    session = boto3.Session(profile_name=profile_name)
    ec2_client = session.client("ec2", region_name="us-east-1")
    return [region["RegionName"] for region in ec2_client.describe_regions()["Regions"]]

def list_unattached_security_groups(ec2_client, region):
    """Finds security groups that are not attached to any resource."""
    try:
        sg_response = ec2_client.describe_security_groups()["SecurityGroups"]
        eni_response = ec2_client.describe_network_interfaces()["NetworkInterfaces"]

        attached_sgs = {sg["GroupId"] for eni in eni_response for sg in eni.get("Groups", [])}
        unattached_sgs = [sg for sg in sg_response if sg["GroupId"] not in attached_sgs]

        if not unattached_sgs:
            print(f"[INFO] No unattached security groups found in {region}.")
        return unattached_sgs
    except Exception as e:
        print(f"[ERROR] Failed to retrieve security groups in {region}: {e}")
        return []

def delete_unattached_security_groups(ec2_client, region):
    """Lists and optionally deletes unattached security groups."""
    unattached_sgs = list_unattached_security_groups(ec2_client, region)
    if not unattached_sgs:
        return

    print(f"\nUnattached Security Groups in {region}:")
    for sg in unattached_sgs:
        print(f"  - {sg['GroupId']} ({sg['GroupName']})")

    confirm = input("\nDelete all unattached security groups? (yes/no): ").strip().lower()
    if confirm == "yes":
        for sg in unattached_sgs:
            try:
                ec2_client.delete_security_group(GroupId=sg["GroupId"])
                print(f"[SUCCESS] Deleted: {sg['GroupId']} ({sg['GroupName']})")
            except Exception as e:
                print(f"[ERROR] Failed to delete {sg['GroupId']}: {e}")

def list_and_fix_open_security_groups(ec2_client, region):
    """Lists security groups open to the internet and optionally restricts them to VPC CIDR."""
    try:
        sg_response = ec2_client.describe_security_groups()["SecurityGroups"]
        vpcs = {vpc["VpcId"]: vpc["CidrBlock"] for vpc in ec2_client.desc





