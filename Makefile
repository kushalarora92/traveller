#!make

-include .env
-include server/.env
-include client/.env

# Need both the dynamic and perminent env variables to be exported
export $(shell sed 's/=.*//' .env)
ifneq ("$(wildcard server/.env)","")
	export $(shell sed 's/=.*//' server/.env)
endif
ifneq ("$(wildcard client/.env)","")
	export $(shell sed 's/=.*//' client/.env)
endif

export GIT_LOCAL_BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
export DEPLOY_DATE?=$(shell date '+%Y%m%d%H%M')

define deployTag
"${PROJECT}-${DEPLOY_DATE}"
endef

# setup-env-dev				 - Setup environment for development env
# setup-env-prod			 - Setup environment for production env
# local-development          - Build and run the development image locally
# local-production           - Build and run the production image locally
# run-pipeline				 - Run pipeline for production env

setup-env-dev:				| setup-root-env setup-dev-env-server setup-dev-env-client
setup-env-prod:				| setup-root-env setup-prod-env-server setup-prod-env-server
local-development:          | build-local-development run-local-development
local-production:           | build-local-production run-local-production
run-pipeline:				| run-pipeline

#################
# Status Output #
#################

print-status:
	@echo " +---------------------------------------------------------+ "
	@echo " | Current Settings                                        | "
	@echo " +---------------------------------------------------------+ "
	@echo " | GIT_LOCAL_BRANCH: $(GIT_LOCAL_BRANCH) "
	@echo " | PROJECT: $(PROJECT) "
	@echo " | DB_NAME: $(DB_NAME) "
	@echo " | DB_USERNAME: $(DB_USERNAME) "
	@echo " | DATE: $(DEPLOY_DATE) "
	@echo " +---------------------------------------------------------+ "
	@docker-compose up api

####################
# Utility commands #
####################

setup-root-env:
	@echo "+\n++ Make: Setting up root environment...\n+"
	@cp ./.config/.env.root .env

setup-dev-env-server:
	@echo "+\n++ Make: Preparing server for development environment...\n+"
	@cp ./server/.config/.env.dev ./server/.env
	
setup-dev-env-client:
	@echo "+\n++ Make: Preparing client for development environment...\n+"
	@cp ./client/.config/.env.dev ./client/.env

setup-prod-env-server:
	@echo "+\n++ Make: Preparing server for production environment...\n+"
	@cp ./server/.config/.env.prod ./server/.env

setup-prod-env-client:
	@echo "+\n++ Make: Preparing client for production environment...\n+"
	@cp ./client/.config/.env.prod ./client/.env


######################################
# Local development [build] commands #
######################################

build-local-development:
	@echo "+\n++ Building local development Docker image...\n+"
	@docker-compose build --parallel

######################################
# Local production [build] commands #
######################################

build-local-production:
	@echo "+\n++ Building local production Docker image...\n+"
	@docker-compose -f docker-compose.production.yml build

####################################
# Local development [run] commands #
####################################

run-local-development:
	@echo "+\n++ Running development container locally\n+"
	@docker-compose up -d

run-local-development-server:
	@echo "+\n++ Running server development container locally"
	@docker-compose up server -d

run-local-development-client:
	@echo "+\n++ Running client development container locally"
	@docker-compose up client -d

run-local-development-db:
	@echo "+\n++ Running database development container locally- on port ${DB_PORT}"
	@docker-compose up db

####################################
# Local production [run] commands #
####################################

run-local-production:
	@echo "+\n++ Running production container locally\n+"
	@docker-compose -f docker-compose.production.yml up -d

run-local-production-server:
	@echo "+\n++ Running server development container locally"
	@docker-compose -f docker-compose.production.yml up server -d

run-local-production-client:
	@echo "+\n++ Running client development container locally"
	@docker-compose -f docker-compose.production.yml up client -d

run-local-production-db:
	@echo "+\n++ Running database development container locally"
	@docker-compose -f docker-compose.production.yml up db -d

############################
# Pipeline (prod) commands #
############################

run-pipeline:
	@echo "+\n++ Make: Running compose in pipeline ...\n+"
	@docker-compose -f docker-compose.production.yml up --build -d

############################
# Local workspace commands #
############################

local-sever-workspace:
	@echo "Shelling into local server application..."
	@docker exec -it $(PROJECT)-server bash

local-client-workspace:
	@echo "Shelling into local client application..."
	@docker exec -it $(PROJECT)-client sh

development-database:
	@echo "Shelling into local database..."
	@ docker exec -i $(PROJECT)-database mysql -u$(DB_USERNAME) -p$(DB_DATABASE)" 

########################
# Close local commands #
########################

close-local-development:
	@echo "+\n++ Closing local development container\n+"
	@docker-compose down

close-local-production:
	@echo "+\n++ Closing local production container\n+"
	@docker-compose -f docker-compose.production.yml down
