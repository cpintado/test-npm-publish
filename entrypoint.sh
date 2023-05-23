#!/bin/bash

function configure_authentication() {

    if [ -n "$GHES_HOSTNAME" ]; then
	if [ "$SUBDOMAIN_ISOLATION" = "false" ]; then
	    URL="${GHES_HOSTNAME}/_registry/npm/"
	else
	    URL="npm.${GHES_HOSTNAME}/"
	fi
    else
	URL="npm.pkg.github.com/"
    fi	
    		
    npm config set "@${NAMESPACE}:registry" "https://${URL}"
    npm config set "//${URL}:_authToken" "$TOKEN"
}

function publish_npm_package() {

    # create new project
    npm init --scope "@${NAMESPACE}" -y

    npm pkg set name="@${NAMESPACE}/${PACKAGE_ID}"

    # if $PACKAGE_VERSION is not 1.0.0 (the default value of npm init), then set the version
    if [ "$PACKAGE_VERSION" != "1.0.0" ]; then
	npm version "$PACKAGE_VERSION" --git-tag-version false
    fi

    # set repository URL if necessary
    if [ -n "$REPOSITORY_URL" ]; then
	npm pkg set "repository=${REPOSITORY_URL}"
    fi

    # publish package
    npm publish

}

function download_npm_package() {

    npm install "@{NAMESPACE}/${PACKAGE_ID}@$PACKAGE_VERSION"

}

function validate_parameters() {

if [ -z "$MODE" ]; then
    echo "MODE not set. Using default value 'publish'"
    MODE="publish"
fi

if [[ ! "$MODE" =~ ^(publish|download)$ ]]; then
    echo "MODE must be either 'publish' or 'download'"
    exit 1
fi

if [[ ! $TOKEN =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid value for TOKEN or TOKEN not specified"
    exit 1
fi

if [[ ! $NAMESPACE =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid value for NAMESPACE or NAMESPACE not specified"
    exit 1
fi

if [ -z "$PACKAGE_ID" ]; then
    echo "Package_ID not set. Using ${NAMESPACE}-test-package as default"
    PACKAGE_ID="${NAMESPACE}-test-package"
fi

if [[ ! $PACKAGE_ID =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid value for PACKAGE_ID"
    exit 1
fi

if [ -z "$PACKAGE_VERSION" ]; then
    echo "PACKAGE_VERSION not set. Using 1.0.0 as default"
    PACKAGE_VERSION="1.0.0"
fi

if [[ ! $PACKAGE_VERSION =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$ ]]; then
    echo "Invalid value for PACKAGE_VERSION or PACKAGE_VERSION not specified"
    exit 1
fi

if [ -n "$REPOSITORY_URL" ]; then
    if [[ ! $REPOSITORY_URL =~ ^https://[a-zA-Z0-9./?=_-]*$ ]]; then
	echo "Invalid value for REPOSITORY_URL"
	exit 1
    fi
fi

if [ -n "$GHES_HOSTNAME" ]; then
    if [[ ! $GHES_HOSTNAME =~ ^[a-z0-9-]+[a-z0-9.-]*$ ]]; then
	echo "Invalid value for GHES_HOSTNAME"
	exit 1
    fi
fi

if [ -z "$REPOSITORY_URL" ]; then
    if [ -n "$GHES_HOSTNAME" ]; then
	echo "Warning: REPOSITORY_URL not set. Setting a repository URL is required to publish a npm package in GHES"
    fi
fi

}

function main() {

    validate_parameters

    configure_authentication

    if [ "$MODE" = "publish" ]; then
	publish_npm_package
    elif [ "$MODE" = "download" ]; then
	download_npm_package
    fi
}

main

