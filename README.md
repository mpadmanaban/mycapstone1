# mycapstone1
Capstone project


# Web App
This web app is copied from nginx demos: https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello
This is a NGINX webserver that serves a simple page containing its hostname, and port as wells as the request URI and the local time of the webserver.

# Site Url 
Site is hosted at : http://mp-capstone.com

# Project Goal
Goal of this project is to  CI/CD pipeline for micro services applications with either blue/green deployment using EKS containers.

# Project Tasks
Cluster Creation:
EKS clusters for blue/green deployments are created using Jenkins with eksctl yaml files.

CI/CD Pipeline:
Initial step of CI/CD Pipleine is to lint the Dockerfile and webapp files.
Next Docker images are built usinged Dokerfile and published to DokerHub.
Image is pulled from Dockerhub and 
Once a specific deployment is completed, Route53 is used to direct the traffic from http://mp-capstone.com to exposed External Address.
There is also a confirmation task added to Jenkins pipeline to approve or abort deploying from blue to green.
