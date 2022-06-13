#!/bin/bash

helm delete airflow -n airflow
helm delete nfs-subdir-external-provisioner -n storage
AIRFLOW_VOID_STRING=""

# Wait until all airflow pods are down
until [ "${AIRFLOW_VOID_STRING}" = "No resources found in airflow namespace." ]
do
    AIRFLOW_VOID_STRING=$(kubectl get pods -n airflow 2>&1)
done

kubectl delete namespaces airflow storage