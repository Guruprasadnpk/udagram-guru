#!/bin/sh
pwd
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/backend-feed-deployment.yaml
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/backend-user-deployment.yaml
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/frontend-deployment.yaml
sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/reverseproxy-deployment.yaml
