#!/bin/bash

# Arguments
# -r Resource Group Name
# -l Location Name
# -w Log Analytics Workspace (Logic Apps Logging)
# -s Storage Account
# -f Function App
# 
# Executing it with minimum parameters:
#   ./azuredeploy.sh -r aisrabbitmq-rg -l westeurope -w aisrabbitmq-ws -s aisrabbitmqst01 -f aisrabbitmq-fa
#
# This script assumes that you already executed "az login" to authenticate 
#
# For Azure DevOps it's best practice to create a Service Principle for the deployement
# In the Cloud Shell:
# For example: az ad sp create-for-rbac --name aissync-sp
# Copy output JSON: AppId and password

while getopts r:l:w:s:f: option
do
	case "${option}"
	in
		r) RESOURCEGROUP=${OPTARG};;
		l) LOCATION=${OPTARG};;
		w) LOGANALYTICS=${OPTARG};;	
		s) STORAGEACC=${OPTARG};;	
		f) FUNCTIONAPP=${OPTARG};;	
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
echo "   Log Analytics Workspace: ${LOGANALYTICS}"
echo "   Storage Account: ${STORAGEACC}"
echo "   Function App: ${FUNCTIONAPP}"; echo

#--------------------------------------------
# Registering providers & extentions
#--------------------------------------------
echo "Registering providers"
az provider register -n Microsoft.OperationsManagement
az provider register -n Microsoft.Function
az provider register -n Microsoft.Storage
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

#--------------------------------------------
# Creating Storage Account
#-------------------------------------------- 
echo "Creating Storage Account ${STORAGEACC}"
RESULT=$(az storage account show -n $STORAGEACC -g $RESOURCEGROUP)
if [[ -z "$RESULT"  &&  -n "$STORAGEACC" ]]
then
	az storage account create -n $STORAGEACC -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS --kind StorageV2
else
	echo "   Storage Account ${STORAGEACC} already exists or is not provided"
fi

#--------------------------------------------
# Creating Function App
#-------------------------------------------- 
echo "Creating Function App ${FUNCTIONAPP}"
RESULT=$(az functionapp show --name $FUNCTIONAPP --resource-group $RESOURCEGROUP)
if [ "$RESULT" = "" ]
then
	az functionapp create \
		--name $FUNCTIONAPP \
		--storage-account $STORAGEACC \
		--consumption-plan-location $LOCATION \
		--resource-group $RESOURCEGROUP \
		--functions-version 2
else
	echo "   Function App ${FUNCTIONAPP} already exists"
fi