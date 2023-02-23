## Spring Petclinic App - SpringBoot Based Microservices On OpenShift
 Deploy petclinic app with eG BTM monitoring enabled.
 
 ## eG Service Topology

![topology](https://github.com/eginnovations/spring-petclinic-microservices/blob/master/docs/petclinic-service-topology.png)
 
## Pre-Requisites
 - git
 - java 8
 - maven 3.5.0+
 - docker
   - Ensure that docker cli pre-configured with docker registry to push the images.
 - oc
   - Ensure that oc cli pre-configured with cluster.

   
## Clone

    git clone https://github.com/eginnovations/spring-petclinic-microservices.git
    cd spring-petclinic-microservices
    
## [Optional] Update eG RUM Script In The Frontend App
    vi spring-petclinic/src/main/resources/templates/fragments/layout.html

## Build Application Jars

    mvn clean package -f spring-petclinic/pom.xml  
    mvn clean package -f OwnerService/pom.xml  
    mvn clean package -f PetService/pom.xml  
    mvn clean package -f VetService/pom.xml  
    mvn clean package -f VisitService/pom.xml
    
## Verify Application Jars

    ls -alth spring-petclinic/target/*.jar 
    ls -alth OwnerService/target/*.jar 
    ls -alth PetService/target/*.jar 
    ls -alth VetService/target/*.jar 
    ls -alth VisitService/target/*.jar 



## Build Docker Images
  Note: **egapm** is a docker hub namespace name, replace with yours. 
  
    docker build --squash -t egapm/spring-petclinic:frontend-svc -f spring-petclinic/Dockerfile spring-petclinic/.  
    docker build --squash -t egapm/spring-petclinic:owners-svc -f OwnerService/Dockerfile OwnerService/.  
    docker build --squash -t egapm/spring-petclinic:pets-svc -f PetService/Dockerfile PetService/.  
    docker build --squash -t egapm/spring-petclinic:vets-svc -f VetService/Dockerfile VetService/.  
    docker build --squash -t egapm/spring-petclinic:visits-svc -f VisitService/Dockerfile VisitService/.  
    docker build --squash -t egapm/spring-petclinic:mysql-db -f mysql/Dockerfile mysql/.

## Push Docker Images

    docker push egapm/spring-petclinic:frontend-svc  
    docker push egapm/spring-petclinic:pets-svc  
    docker push egapm/spring-petclinic:owners-svc  
    docker push egapm/spring-petclinic:vets-svc  
    docker push egapm/spring-petclinic:visits-svc  
    docker push egapm/spring-petclinic:mysql-db
    
## Create PullSecret To Avoid Docker Hub Pull Request Limitation    

    oc create secret generic regcred \
    --from-file=.dockerconfigjson=/root/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
    
## Update eG Manager Details In The eG Agent Daemonset Yaml
    vi k8s/eg-agent/egagent.yaml
        
## Deploy eG Agent Into OpenShift
    oc apply -f k8s/eg-agent/.
 
## Deploy Microservices Into OpenShift
   Note: Update your new image name in all the YAMLs. 
   
    # Petclinic App
    oc apply -f k8s/app/namespace_and_service_account/.
    oc apply -f k8s/app/db/.
    oc apply -f k8s/app/.
    
## Verify Pods
    
    # eG Agent
    oc get pods -n egagent
    
    # Petclinic App
    oc get pods -n spring-petclinic

## Get URL To Access The App
    
    # Petclinic App
    oc get routes -n spring-petclinic
    
## Delete Microservices From OpenShift
    # Petclinic App
    oc delete -f k8s/app/db/.
    oc delete -f k8s/app/.

## Delete App Namespace From OpenShift - Full Clean-Up

    # Petclinic App
    oc delete -f k8s/app/namespace_and_service_account/.

## Delete eG Agent From OpenShift
    # eG Agent
    oc delete -f k8s/eg-agent/.
    
    
# To Deploy App Only
   - If you dont want to build and dont want to monitor using eG, use below cmd to try out Petclinic app.
   Note: Update your new image name in all the YAMLs. 

         oc apply -f k8s/plain-app/namespace_and_service_account/.
         oc apply -f k8s/plain-app/db/.
         oc apply -f k8s/plain-app/.



