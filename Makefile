QUARKUS_VERSION ?= 1.8.1.Final
AWS_REGION ?= eu-west-1
ENV ?= dev
GROUP_ID=$(shell ./mvnw org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.groupId -q -DforceStdout)
ARTIFACT_ID=$(shell ./mvnw org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.artifactId -q -DforceStdout)
VERSION=$(shell ./mvnw org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version -q -DforceStdout)
STACK_NAME=$(ARTIFACT_ID)-stack
BUCKET_NAME=$(ARTIFACT_ID)-artifact-bucket
FUNCTION_NAME=FaasTestQuarkus

PAYLOAD ?= -

init:
	@echo "----- 🔧 🔧 Generating AWS Lambda function Boilerplate 🔧 🔧 -----"
	mvn archetype:generate \
       -DarchetypeGroupId=io.quarkus \
       -DarchetypeArtifactId=quarkus-amazon-lambda-archetype \
       -DarchetypeVersion=$(QUARKUS_VERSION) \
	   -DartifactId=$(LAMBDA_NAME)

	@echo "----- Configuring environment -----"
	mv $(LAMBDA_NAME)/* .
	rm -rf $(LAMBDA_NAME) *gradle*
	mkdir payloads && mv payload.json payloads/base-test-payload.json
	git init
	
	@echo "----- pre-building new lambda -----"
	mvn -N io.takari:maven:0.7.7:wrapper
	./mvnw clean package && \
		cp target/sam.*.yaml . &&\
		sed -i "" "s+function.zip+target/function.zip+g" sam.*.yaml 

	@echo "----- Creating S3 bucket for new lambda with bucket name: ${STACK_NAME} to ${ENV} environment -----"
	aws s3 mb s3://$(BUCKET_NAME) \
		--profile $(AWS_PROFILE) \
		--region $(AWS_REGION)

	@echo "----- Environment setup COMPLETE. Happy hacking! 🚀  🚀  🚀  🚀  🚀 -----"
deploy:
	@echo "-----🚀  🚀 Deploying stack: ${STACK_NAME} to ${ENV} environment 🚀  🚀  -----"
	# ./mvnw clean install -Pnative -Dnative-image.docker-build=true
	sam deploy \
		 -t sam.native.yaml \
		 --stack-name $(STACK_NAME) \
		 --s3-bucket $(BUCKET_NAME) \
		 --region $(AWS_REGION) \
		 --tags \
		 	env=$(ENV) \
		 	app=$(ARTIFACT_ID) \
			groupId=$(GROUP_ID) \
			version=$(VERSION) \
		 --capabilities CAPABILITY_IAM
	@echo "----- Deployment of stack: ${STACK_NAME} to ${ENV} environment DONE -----"

local-deploy: local-deploy-lambda local-deploy-api

local-deploy-lambda:
	@echo "----- Deploying Lambda: ${STACK_NAME} to ${ENV} environment -----"
	./mvnw clean install
	sam local start-lambda \
		 -t sam.jvm.yaml
	@echo "----- Deployment of stack: ${STACK_NAME} to ${ENV} environment DONE -----"

local-deploy-lambda-native:
	@echo "----- Deploying Native Lambda: ${STACK_NAME} to ${ENV} environment -----"
	./mvnw clean install -Pnative -Dquarkus.native.container-build=true
	sam local start-lambda \
		 -t sam.native.yaml
	@echo "----- Deployment of stack: ${STACK_NAME} to ${ENV} environment DONE -----"

local-deploy-api:
	@echo "----- Deploying API: ${STACK_NAME} to ${ENV} environment -----"
	sam local start-api \
		 -t sam.native.yaml
	@echo "----- Deployment of stack: ${STACK_NAME} to ${ENV} environment DONE -----"

local-invoke:
	sam local invoke $(FUNCTION_NAME)\
		-t sam.jvm.yaml \
		--env-vars ./local_invoke/env.json \
		--event $(PAYLOAD)

local-invoke-native:
	sam local invoke  \
		-t sam.native.yaml \
		--env-vars ./local_invoke/env.json \
		--event $(PAYLOAD)

build-jvm:
	@echo "----- Building Lambda in JVM mode: ${STACK_NAME}-----"
	./mvnw clean install
	
build-native:
	@echo "----- Building Lambda in Native mode: ${STACK_NAME}-----"
	./mvnw clean install -Pnative -Dquarkus.native.container-build=true
	
	
	