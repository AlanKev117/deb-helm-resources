# Helm resources for DEB

In case you choose to host your Airflow cluster in a Kubernetes cluster from
a cloud provider, here are some templates and useful resources you can use to install Airflow
with its [official Helm Chart](https://airflow.apache.org/docs/helm-chart/stable/quick-start.html).

## Requirements

### 1. Create your K8s cluster on the cloud

Once you have run the `terraform apply` command, which will create your 
Kubernetes cluster (among other resources) in the cloud, then you are ready 
to install Airflow.

### 2. Make sure you have `Docker`, `helm` and `kubectl` installed

Install these commands according to your OS.

### 3. Setup your Airflow image

The Airflow Helm Chart may use a custom extended
image of your own. You let the chart know which one with the `images.airflow.repository` and the `images.airflow.tag` fields. These can be set in the `values.yaml` file.

> Go to [Docker section](./Docker/README.md) to see how to configure your image.


## Installation

First, a brief description of the config files:

- `nfs-server.yaml` has `helm` configuration to create an NFS volume to store Airflow logs
- `values.yaml` has `helm` configuration to install Airflow with the *Airflow Helm Chart*. It contains a list of environments variables that need to be set in the cluster to configure connections, secrets, and so on.
- `airflow_install` installs Airflow by reading values from terraform. Make sure yaml files are in the same location as this script.
- `airflow_remove` removes Airflow and the NFS volume from the cluster.

To run the instalation script make sure to replace the placeholders for vars `TERRAFORM_DIR`
 dir and `CREDENTIALS_FILE` with **absolute paths**.

```bash
# To run the installation script...
bash airflow_install.sh
```

After you run the installation script, you can access the Airflow web server by forwarding port 8080 from Airflow web server pod to your computer.

```bash
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
# exit with ctrl + c
```

Now you can go to `localhost:8080` from your web browser and access with user `admin` and password `admin` to view and invoke DAGs.
