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
        aws s3 mb s3://$SAM_BUCKET_NAME
    fi
}

package_SAM () {
    create_SAM_bucket_if_not_exist

    if [ ! -f .env ]; then
        echo DEVELOPMENT_SERVER_PORT=3000 > .env
        echo RELOAD_SERVER_PORT=3001 >> .env
    fi

    docker-compose run --rm lambda

    sam package \
        --template-file template.yaml \
        --output-template-file package.yaml \
        --s3-bucket $SAM_BUCKET_NAME
}

deploy_SAM () {
    package_SAM

    sam deploy \
	    --template-file package.yaml \
	    --stack-name $SAM_STACK_NAME \
	    --capabilities CAPABILITY_IAM

    sleep 2

    local generated_bucket_name=$(query_SAM_output BucketName)
    local generated_access_key_id=$(query_SAM_output ManagerAccessKeyId)
    local generated_function_arn=$(query_SAM_output HandleResumeUploadFunctionArn)
    local generated_bucket_arn=$(query_SAM_output BucketArn)
    local generated_secret_access_key_arn=$(query_SAM_output SecretManagerSecretAccessKeyArn)
    local generated_secret_access_key=$(query_SecretManager_value $generated_secret_access_key_arn)

    echo DEVELOPMENT_SERVER_PORT=3000 > .env
	echo RELOAD_SERVER_PORT=3001 >> .env
	echo >> .env
	echo AWS_S3_BUCKET_NAME=generated_bucket_name >> .env
	echo AWS_ACCESS_KEY_ID=$generated_access_key_id >> .env
	echo AWS_SECRET_ACCESS_KEY=$generated_secret_access_key >> .env
}

command=$1
case $command in
    packageSAM) package_SAM;;
    deploySAM) deploy_SAM;;
    generateEnv) generate_Env;;
esac
