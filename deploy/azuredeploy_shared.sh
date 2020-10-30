#!/bin/bash

# Arguments
# -r Resource Group Name
# -l Location Name
# -w Log Analytics Workspace (Logic Apps Logging)
# 
# Executing it with minimum parameters:
#   ./azuredeploy.sh -r aisshared-rg -l westeurope -w aisshared-ws
#
# This script assumes that you already executed "az login" to authenticate 
#
# For Azure DevOps it's best practice to create a Service Principle for the deployement
# In the Cloud Shell:
# For example: az ad sp create-for-rbac --name aissync-sp
# Copy output JSON: AppId and password

while getopts r:l:w: option
do
	case "${option}"
	in
		r) RESOURCEGROUP=${OPTARG};;
		l) LOCATION=${OPTARG};;
		w) LOGANALYTICS=${OPTARG};;	
	esac
done

# Functions
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Setting up some default values if not provided
# if [ -z ${RESOURCEGROUP} ]; then RESOURCEGROUP="aissync-rg"; fi 

echo "Input parameters"
echo "   Resource Group: ${RESOURCEGROUP}"
echo "   Location: ${LOCATION}"
echo "   Log Analytics Workspace: ${LOGANALYTICS}"; echo

#--------------------------------------------
# Registering providers & extentions
#--------------------------------------------
echo "Registering providers"
az provider register -n Microsoft.Logic
az provider register -n Microsoft.OperationsManagement

#--------------------------------------------
# Creating Resource group
#-------------------------------------------- 
echo "Creating resource group ${RESOURCEGROUP}"
RESULT=$(az group exists -n $RESOURCEGROUP)
if [ "$RESULT" != "true" ]
then
	az group create -l $LOCATION -n $RESOURCEGROUP
else
	echo "   Resource group ${RESOURCEGROUP} already exists"
fi

#--------------------------------------------
# Creating Log Analytics Workspace
#-------------------------------------------- 
echo "Creating Log Analytics Workspace ${LOGANALYTICS}"
RESULT=$(az monitor log-analytics workspace show -g $RESOURCEGROUP -n $LOGANALYTICS)
if [ "$RESULT" = "" ]
then
	az monitor log-analytics workspace create -g $RESOURCEGROUP -n $LOGANALYTICS
else
	echo "   Log Analytics Workspace ${LOGANALYTICS} already exists"
fi