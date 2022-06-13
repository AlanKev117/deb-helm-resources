## Docker folder

This folder holds the Dockerfile to build the custom version of
your Airflow image for the Helm Chart.

You may tweak it as you need. Currently, it installs a few dependencies
to your container and copies resources from `assets` and `dags` folder.

### The `dags` folder

This is where to place your Airflow DAGs

* The .airflowignore file in `dags` prevents Airflow to parse Python
files as DAGs.

* The `custom_modules` folder holds additional python dependencies for your DAGs.

### The `assets` folder

Basically, where you can place additional resources to be consumed by your DAGs.

```bash
# Build your image
docker build -t your-repo/image-name:semver-number .
# i.e. docker build -t myrepo/airflow-deb:0.0.1 .

# Push your imge to docker hub (you need to be logged in Docker hub)
docker push your-repo/image-name:semver-number
# i.e. docker push myrepo/airflow-deb:0.0.1
```

### The `docker-context-files` folder

If you place a Python requirements file, dependencies in it will be installed during the building of the Docker image. It's an alternative to explicitly install them with `pip` in the Dockerfile.