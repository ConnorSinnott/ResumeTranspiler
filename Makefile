# Used for SAM development
.PHONY: samPackage

SAM_BUCKET_NAME="sam-resume-transpiler"
SAM_STACK_NAME="resume-transpiler"

GET_SAM_BUCKET_INSTANCE_COUNT = $(shell aws s3 ls | grep $(SAM_BUCKET_NAME) | wc -l)

QUERY_GENERATED_BUCKET_NAME = $(shell aws cloudformation \
								describe-stacks --stack-name $(SAM_STACK_NAME) \
								--query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
								--output text)

QUERY_GENERATED_ACCESS_KEY_ID = $(shell aws cloudformation \
								  describe-stacks --stack-name $(SAM_STACK_NAME) \
								  --query 'Stacks[0].Outputs[?OutputKey==`ManagerAccessKeyId`].OutputValue' \
								  --output text)

QUERY_GENERATED_SECRET_ACCESS_KEY = $(shell aws cloudformation \
								      describe-stacks --stack-name $(SAM_STACK_NAME) \
								      --query 'Stacks[0].Outputs[?OutputKey==`ManagerSecretAccessKey`].OutputValue' \
								      --output text)

samBuild:
	docker-compose run --rm lambda

samCreateBucketIfNotExist:
ifeq ($(GET_SAM_BUCKET_INSTANCE_COUNT),0)
	aws s3 mb s3://$(SAM_BUCKET_NAME)
endif

samPackage: samCreateBucketIfNotExist samBuild
	sam package \
		--template-file template.yaml \
		--output-template-file package.yaml \
		--s3-bucket $(SAM_BUCKET_NAME)

samDeploy: samCreateBucketIfNotExist samPackage
	sam deploy \
	  --template-file package.yaml \
	  --stack-name $(SAM_STACK_NAME) \
	  --capabilities CAPABILITY_IAM

samGenerateEnv:
	echo DEVELOPMENT_SERVER_PORT=3000 > .env
	echo RELOAD_SERVER_PORT=3001 >> .env
	echo >> .env
	echo AWS_S3_BUCKET_NAME=$(QUERY_GENERATED_BUCKET_NAME) >> .env
	echo AWS_ACCESS_KEY_ID=$(QUERY_GENERATED_ACCESS_KEY_ID) >> .env
	echo AWS_SECRET_ACCESS_KEY=$(QUERY_GENERATED_SECRET_ACCESS_KEY) >> .env

