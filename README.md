Scripts for building an image for project-hop command line client.

Project Hop is a fork of the well known Pentaho Data Integration (PDI) tool. The project aims to bring the tool to the next level. Read more about Project Hop: http://www.project-hop.org/

Hop has a command line client to run workflows and pipelines (forming ETL processes). The scripts here are used to:

- download the latest project hop package
- build a OCI compliant image from which containers can be run
- push the image to a private or public registry (docker hub)

The central script is the buildah_hop.sh script. It invokes the get_latest_hop_package.sh script downloads the maven metadata, retrieves the metadata and then downloads the latest project-hop package from the project-hop website. From here the contaimer image is build.

The entrypoint.sh, generate_pipeline_runconfig.sh, generate_workflow_runconfig.sh and generate_environment.sh scripts are used inside the container to parse environment variables and create a default run configuration and default environment for the hop-run.sh script. The files are created using Apache Velocity templates and merging them with the relevant environment variables. The default run configuration and default environment is used whenver no other config directory folder is specified in HOP_CONFIG_DIRECTORY variable.

The get_latest_hop_package.sh script can also be run on it's own to download the latest hop package. It will be downloaded only if the same version was not already downloaded, so this works well for a CI/CD pipeline.

The images are build with the buildah_hop.sh script and using "buildah" - an alternative and modern way of creating OCI compliant images. These images are compatible with Docker. The image can be downloaded here: https://hub.docker.com/r/uwegeercken/hop

last update: uwe.geercken@web.de - 2020-05-11
