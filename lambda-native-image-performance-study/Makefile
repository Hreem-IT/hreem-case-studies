GROUPNAME = lambda-performance
SERVICE = $(GROUPNAME)-$(PROJECT)
AWS_REGION ?= eu-west-1

## BUILD
build:
	# Building functions
	mvn clean install \
		-f $(PROJECT) \
		-T 1C

build_native:
	# Building functions in native mode
	mvn clean install \
		-f $(PROJECT) \
		-T 1C -Dnative-image.docker-build=true

## DEPLOYMENT
deploy_persistent:
	# Deploy persistent stack to CloudFormation
	aws cloudformation deploy \
		--template-file ./$(PROJECT)/cloudformation/persistent.yaml \
		--stack-name $(SERVICE)-persistent-stack \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			Service=$(SERVICE)

deploy_serverless:
	# Deploy serverless stack to CloudFormation
	sam deploy \
		--template-file ./$(PROJECT)/cloudformation/template.yaml \
		--stack-name $(SERVICE)-stack \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--s3-bucket $(SERVICE)-artifacts \
		--parameter-overrides \
			GroupName=$(GROUPNAME) \
			Service=$(SERVICE)

deploy_serverless_native:
	# Deploy natively packaged serverless stack to CloudFormation
	sam deploy \
		--template-file ./$(PROJECT)/cloudformation/template.native.yaml \
		--stack-name $(SERVICE)-native-stack \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--s3-bucket $(SERVICE)-artifacts \
		--parameter-overrides \
			GroupName=$(GROUPNAME) \
			Service=$(SERVICE)

deploy:	deploy_persistent build deploy_serverless
deploy_native: deploy_persistent build_native deploy_serverless_native
