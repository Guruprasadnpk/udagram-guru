#!/bin/sh
pwd
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/backend-feed-deployment.yml
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/backend-user-deployment.yml
#sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/frontend-deployment.yml
sed -i "s/VERSION/${TRAVIS_BUILD_NUMBER}/g" deployment/k8s/reverseproxy-deployment.yml
