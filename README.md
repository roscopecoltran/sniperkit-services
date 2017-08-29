#### Kubernetes based Jupyter Hub training enviroment for Scalable Machine Learning using Spark and Vora

A training environment based on Kubernetes that allows to launch applications within a few minutes. In this document we describe the usage in Google Cloud Environment as well as a bare metal Kubernetes cluster, but it is designed to work everywhere (e.g. AWS, Azure).

Currently we support the following :

  - Apache Spark
         
  - Apache Kafka (relevant for IoT scenarios and real-time machine learning applications)
         
  - HDFS
         
  - Machine Learning (TensorFlow, Spark ML, Sci-Kit Learn, R, …)
         
  - SAP Vora (all engines are supported incl. Vora vFlow;please note that we are utilizing a setup that
    was developed by the Vora team)
        
  - Advanced Scala (Scala is an ideal language for distributed data processing and a command
     of the language is beneficial to everyone who is actively working with Spark)
          
          

For the user interface,we are using Jupyter notebooks.The training environment has some nice features. After logging on with
an SAP account (using single-sign-on, we also support github based authentication), every user gets his/her individual Jupyter environment.

They are  three separate content folders:
 
 - Public Folder (read-only) - Containing training content and datasets
         
 - Personal Folder - Users have their own personal (and private) persistent hard drives .
         
 - Shared Folder - This is a shared drive to which everyone has read/write access to.It’s used for collaboration and 
    content sharing
       
       
Getting Started on Google container Engine 
 
  -  Clone the repository 
         
         git clone git@github.wdf.sap.corp:i033085/jupyterHub.git

  -  Set the Compute Zone for gcloud
         
         gcloud config set compute/zone us-west1-a

  -  Create a Container Engine Cluster with n nodes with kubernetes version 1.6.4 : 

         gcloud container clusters create jupyterhub --num-nodes=n --cluster-version=1.6.4

  -  Create a namespace for Kubernetes

         kubectl create namespace jupyterhub 

  -  For persistency we use an NFS based Storage.If you have an NFS server already running you can skip this step
      and proceed to step for provisioning the NFS Volumes
         
         -  Create Disk which acts as the underlying storage for NFS.This script creates a disk 
            on the google cloud,attaches the disk to a provisioner instance
            and mounts the disk in the configured path

               ./make-disk.sh jupyterhub-persistency 100GB

         -  Create the required folder structures to store Public,Shared and Personal Data

               ./prepare-dish.sh jupyterhub-persistency

         -  You can also copy your Data-Sets to this disk as below (Optional): 

                gcloud compute copy-files ~/LOCAL-FILE-1 ~/LOCAL-FILE-2 provisioner-01:/mnt/disks/RawData 
                gcloud compute copy-files ~/LOCAL-FILE-1 ~/LOCAL-FILE-2 provisioner-01:/mnt/disks/SharedData

         -  Un-Mount the disk and delete the provisioner instance :
                           
                ./unmount-disk.sh jupyterhub-persistency
                  
 -  Running the NFS Server
               
         -  Create the NFS Server. Make note of the cluster IP of the NFS Server 
                  kubectl create --namespace=jupyterhub -f nfsDisk/nfsServer.yaml
                 
 - Provision the NFS volumes
        
         -  For installation in the google cloud please use nfsDisk/nfsChart/gke_values.template 
            as reference and update the NFS server IP address from above.
          
         -  If you have followed the instructions above to run the NFS server 
            the simplest way would be to :
          
                  cp nfsDisk/nfsChart/gke_values.template nfsDisk/nfsChart/values.yaml
          
         -   After adjusting the helm-chart values
             run the helm chart for provisioning the NFS volumes as below:
                  
                           helm install nfsDisk/nfsChart --name=nfs --namespace=jupyterhub
                  
- Install Dynamic NFS Provisioner for Individual User Persistency
  
         -   Each user is assigned a persistent volume.We use Dynamic NFS provisioning for that .
             To install this,the simplest way would be to use nfs-client/nfsProvisioner/gke_values.yaml
             as reference and update the NFS server IP from above.
                  
                           cp nfs-client/nfsProvisioner/gke_values.yaml nfs-client/nfsProvisioner/values.yaml
                  
         -   Install the helm-chart as below :
                   
                   helm install nfs-client/nfsProvisioners --name=provisioner --namespace=jupyterhub
   
- Set up a Kubernetes based Spark Cluster
   
         -   ./start-spark.sh gke
              For detailed instructions on setting up a spark cluster refer to: 
              [spark](./spark/README.md)
      
- Launch the Jupyter Hub environment
         
         -   helm init
   
         -  We support Oauth based user authentication for Jupyterhub.Currently there is support
            for SAP single sign on using HCP oauth services as well as Github based authentication 
            or you can skip the authentication.
            
            Simplest way to get started here is using jupyterHub/helm-chart/gke_values.template as reference 
            and update the authentication mechanism.To make the set-up simpler
            we set the authentication as dummy and start the Hub server as below :
           
              helm install jupyterHub/helm-chart --name=jupyterhub --namespace=jupyterhub -f jupyterhub/config.yaml
         
                  
                  
         
                  
         
         
                  
         
         
         
         
     
