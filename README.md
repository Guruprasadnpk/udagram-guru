# Udagram

[![Build Status](https://travis-ci.com/Guruprasadnpk/udagram-guru.svg?branch=master)](https://travis-ci.com/github/Guruprasadnpk/udagram-guru)

Udagram is 

  - Type some Markdown on the left
  - See HTML in the right
  - Magic
### Components

Udagram uses a number of components to work properly:

* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework
* [AWS EKS] - Amazon Elastic Kubernetes Service (Amazon EKS) is a fully managed Kubernetes service.
* [AWS CDN] - Amazon CloudFront is a fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency, high transfer speeds, all within a developer-friendly environment. 
* [AWS S3] - Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance.
* [Travis CI] - CI/CD framework
* [Docker Hub] - a cloud-based repository in which Docker users and partners create, test, store and distribute container images.

### Prerequisites
* aws cli - The AWS Command Line Interface (CLI) is a unified tool to manage your AWS services. Installation instructions provided here: https://aws.amazon.com/cli/
* kubectl - The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. Installation instructions provided here: https://kubernetes.io/docs/tasks/tools/install-kubectl/
* eksctl - Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS IAM authenticator for Kubernetes. Installation instructions provided here: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
* aws-iam-authenticator - Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS IAM authenticator for Kubernetes. Installation instructions provided here: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
* KubeSeal - The kubeseal utility uses asymmetric crypto to encrypt secrets that only the controller can decrypt. 
https://github.com/bitnami-labs/sealed-secrets/releases


### Installation
Install the prerequisites

1. Create an EKS cluster using the following command
    ```
    eksctl create cluster\
           --name udagram\
           --version 1.16\
           --region us-west-2\
           --nodegroup-name standard-workers\
           --node-type t3.medium\
           --node-volume-size=20\
           --nodes 3\
           --nodes-min 1\
           --nodes-max 4\
           --ssh-access\
           --managed
    ```
2. Update kubeconfig: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
   ```aws eks --region us-west-2 update-kubeconfig --name udagram```
3. Install sealed secret Client-Side Utility: ```brew install kubeseal```
4. Install cluster-side controller
```kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.4/controller.yaml```

# Add secrets and configMap
* aws-secrets
Encode aws credentials:  ```cat ~/.aws/credentials | base64```
   Create aws-secrets.yaml
    ```
    apiVersion: v1
    data:
      credentials: <base64 encoded aws credentials>
    kind: Secret
    metadata:
      name: aws-secret
      namespace: default
    type: Opaque
    
    kubeseal --format=yaml < aws-secret.yaml > sealed-aws-secret.yaml
    kubectl apply -f deployment/k8s/sealed-aws-secret.yaml
    
* secrets
Encode Postgres and JWT secrets
    ```echo -n $POSTGRESS_USERNAME | base64```
    ```echo -n $POSTGRESS_PASSWORD | base64```
    ```echo -n $JWT_SECRET | base64```
    Create secrets.yaml
    ``` 
    apiVersion: v1
    data:
      JWT_SECRET: <base64 encoded JWT_SECRET>
      POSTGRESS_PASSWORD: <base64 encoded POSTGRESS_PASSWORD>
      POSTGRESS_USERNAME: <base64 encoded POSTGRESS_USERNAME>
    kind: Secret
    metadata:
      name: env-secrets
      namespace: default
    type: Opaque
    
    kubeseal --format=yaml < secret.yaml > sealed-secret.yaml
    kubectl apply -f deployment/k8s/sealed-secret.yaml

### Docker Build

    docker build -t <dockerhub>:backend-feed:VERSION udacity-c3-restapi-feed/
    docker push <dockerhub>:backend-feed:VERSION

    docker build -t <dockerhub>:backend-user:VERSION udacity-c3-restapi-user/
    docker push <dockerhub>:backend-user:VERSION
    
    docker build -t <dockerhub>:frontend:VERSION udacity-c3-frontend/
    docker push <dockerhub>:frontend:VERSION
    
    docker build -t <dockerhub>:reverseproxy:VERSION udacity-c3-reverseproxy/
    docker push <dockerhub>:reverseproxy:VERSION
    
   (or)
    
    docker-compose -f deployment/docker/docker-compose-build.yaml build --parallel

### Kubernetes Deployment
##### Frontend
* Deploy the frontend so that we can create a cloudfront from the LoadBalancer endpoint generated after the deployment.
    ```
    kubectl apply -f deployment/k8s/frontend-deployment.yaml
    kubectl apply -f deployment/k8s/frontend-service.yaml
    
    To get the ELB endpoint run this command: 
    kubectl describe svc frontend
    ```
* Create a cloud front distribution while choosing the Elastic Load Balancer listed obove and copy the CDN domain name.

* Create configMap:
    Change the Postgres and AWS configuration in AWS_MEDIA_BUCKET, AWS_PROFILE, AWS_REGION, POSTGRESS_DATABASE, POSTGRESS_HOST, URL in env-configmap.yaml. The URL must be the domain name from cloud front distribution obtained above.
    ```kubectl apply -f deployment/k8s/env-configmap.yaml```

##### Backend
* Feed Service
    ```
    kubectl apply -f deployment/k8s/backend-feed-deployment.yaml
    kubectl apply -f deployment/k8s/backend-feed-service.yaml
    ```
    
* User Service
    ```
    kubectl apply -f deployment/k8s/backend-user-deployment.yaml
    kubectl apply -f deployment/k8s/backend-user-service.yaml
    ```

* Reverse Proxy
    ```
    kubectl apply -f deployment/k8s/reverseproxy-deployment.yaml
    kubectl apply -f deployment/k8s/reverseproxy-service.yaml
    ```
    
* Configure Amazon CloudWatch Logs
    `
    wget https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluentd/fluentd.yaml`
    `kubectl apply -f fluentd.yaml`
    `kubectl logs -l k8s-app=fluentd-cloudwatch -n kube-system`
    
   [git-repo-url]: <https://github.com/Guruprasadnpk/udagram-guru.git>
   [node.js]: <http://nodejs.org>
   [express]: <http://expressjs.com>
   [NodeJS]: <https://nodejs.org>
   [AWS EKS]: <https://aws.amazon.com/eks/>
   [AWS CDN]: <https://aws.amazon.com/cloudfront/>
   [AWS S3]: <https://aws.amazon.com/s3/>
   [Travis CI]: <https://travis-ci.com/>
   [Docker Hub]: <https://hub.docker.com/>

