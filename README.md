Scripts for building an image for project-hop command line client.

Project Hop is a fork of the well known Pentaho Data Integration (PDI) tool. The project aims to bring the tool to the next level. Read more about Project Hop: http://www.project-hop.org/

Hop has a command line client to run workflows and pipelines (forming ETL processes). The scripts here are used to

- download the latest project hop package
- build a OCI compliant image from which containers can be run
- push the image to a private or public registry (docker hub)

The entrypoint.sh and generate_runconfig.sh scripts are used inside the container to parse environment variables and create a run configuration for the hop-run.sh script.

The get_latest_hop_package.sh script downloads the maven metadata, retrieves the metadata and then downloads the latest project-hop package from the project-hop website.

The images are build using "buildah" - an alternative and modern way of creating OCI compliant images. These images are compatible with Docker. The image can be downloaded here: https://hub.docker.com/r/uwegeercken/hop

last update: uwe.geercken@web.de - 2020-05-05
