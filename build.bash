#!/usr/bin/env bash

SAM_BUCKET_NAME="sam-resume-transpiler"
SAM_STACK_NAME="resume-transpiler"

query_SAM_output () {
    aws cloudformation \
        describe-stacks --stack-name $SAM_STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" \
        --output text
}

query_SecretManager_value () {
    aws secretsmanager \
        get-secret-value --secret-id $1 \
        | grep -P '(?<="SecretString": ").*(?=")' -o
}


create_SAM_bucket_if_not_exist () {
    local instance_count=$(aws s3 ls | grep $SAM_BUCKET_NAME | wc -l)

    if [ $instance_count = 0 ]; then
        echo "Creating bucket $SAM_BUCKET_NAME"
        aws s3 mb s3://$SAM_BUCKET_NAME
    fi
}

package_SAM () {
    create_SAM_bucket_if_not_exist

    if [ ! -f .env ]; then
        echo DEVELOPMENT_SERVER_PORT=3000 > .env
        echo RELOAD_SERVER_PORT=3001 >> .env
    fi

    if [ ! -f .env.hctiapi ]; then
        echo Enter HCTIApiUserID
        read userid

        echo Enter HCTIApiKey
        read key

        echo HCTI_API_USER_ID=$userid > .env.hctiapi
        echo HCTI_API_KEY=$key >> .env.hctiapi
    fi

    source .env.hctiapi

    echo "Compiling renderer"

    cd resume-renderer && make && cd -

    echo "Compiling lambda"

    cd handleResumeUploadLambda && make && cd -

    echo "Packaging SAM"

    sam package \
        --template-file template.yaml \
        --output-template-file package.yaml \
        --s3-bucket $SAM_BUCKET_NAME
}

generate_env () {
    echo "Building .env file"

    local generated_bucket_name=$(query_SAM_output BucketName)
    local generated_access_key_id=$(query_SAM_output ManagerAccessKeyId)
    local generated_function_arn=$(query_SAM_output HandleResumeUploadFunctionArn)
    local generated_bucket_arn=$(query_SAM_output BucketArn)
    local generated_secret_access_key_arn=$(query_SAM_output SecretManagerSecretAccessKeyArn)
    local generated_secret_access_key=$(query_SecretManager_value $generated_secret_access_key_arn)

    echo DEVELOPMENT_SERVER_PORT=3000 > .env
    echo RELOAD_SERVER_PORT=3001 >> .env
    echo >> .env
    echo AWS_S3_BUCKET_NAME=$generated_bucket_name >> .env
    echo AWS_ACCESS_KEY_ID=$generated_access_key_id >> .env
    echo AWS_FUNCTION_ARN=$generated_function_arn >> .env
    echo AWS_BUCKET_ARN=$generated_bucket_arn >> .env
    echo AWS_SECRET_ACCESS_KEY=$generated_secret_access_key >> .env
}

deploy_SAM () {
    package_SAM

    echo "Deploying SAM"

    sam deploy \
	    --template-file package.yaml \
	    --stack-name $SAM_STACK_NAME \
	    --capabilities CAPABILITY_IAM \
	    --parameter-overrides \
	        HCTIApiUserID=${HCTI_API_USER_ID} \
	        HCTIApiKey=${HCTI_API_KEY}

    echo "Allowing the server time to update"

    sleep 2

    generate_env
    source .env

    if [ "$(aws s3api get-bucket-notification-configuration --bucket ${AWS_S3_BUCKET_NAME})" == "" ]; then
        echo "Adding a notification configuration to the generated bucket"

        aws lambda add-permission \
            --function-name ${AWS_FUNCTION_ARN} \
            --action lambda:InvokeFunction \
            --principal s3.amazonaws.com \
            --source-arn ${AWS_BUCKET_ARN} \
            --statement-id 1

        echo "
          {
            \"LambdaFunctionConfigurations\": [
              {
                \"Id\": \"s3-event-configuration\",
                \"LambdaFunctionArn\": \"${AWS_FUNCTION_ARN}\",
                \"Events\": [ \"s3:ObjectCreated:Put\" ],
                \"Filter\": {
                  \"Key\": {
                    \"FilterRules\": [
                      {
                        \"Name\": \"suffix\",
                        \"Value\": \".zip\"
                      }
                    ]
                  }
                }
              }
            ]
          }
        " >> notification.json

        aws s3api put-bucket-notification-configuration \
            --bucket ${AWS_S3_BUCKET_NAME} \
            --notification-configuration file://notification.json

        rm notification.json
    fi

    rm package.yaml
}

command=$1
case $command in
    packageSAM) package_SAM;;
    deploySAM) deploy_SAM;;
    generateEnv) generate_env;;
esac
