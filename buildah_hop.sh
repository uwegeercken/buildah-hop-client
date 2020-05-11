#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"

# where to push the resulting image
# values: remote or local. default is local
push_destination=${1:-local}

# name of the script to download the latest hop hop_package_folder
hop_download_script="get_latest_hop_package.sh"

# folder where the hop package files are located
hop_package_folder="hop"

# base image
image_base=openjdk:8

# image details
image_name="hop"
image_format="docker"
image_author="uwe.geercken@web.de"

# local artifactory
image_registry="silent1:8083"
image_registry_group="silent1:8082"
image_registry_user="admin"

# docker hub user
image_registry_docker="docker.io/uwegeercken"

# name of working container
working_container="hop-working-container"

# simplereplacer tool for merging environment variables with template
lib_simplereplacer="simplereplacer-0.0.1-SNAPSHOT.jar"

# variables for the image itself
application_folder_root="/opt/hop"
tools_folder_root="/opt/simplereplacer"

# start of build
echo "[INFO] start of image build and push process ..."

echo "[INFO] running script to get latest hop package: ${hop_download_script}"
source "${script_dir}/${hop_download_script}"

# if we have no latest version we abort here
if [ -z "${HOP_LATEST_VERSION}" ]
then
	echo "[ERROR] variable [HOP_LATEST_VERSION] is undefined"
	exit 1
elif [ ! -f "${HOP_LATEST_ZIP}" ]
then
	# if the zip file is not available, then it already has been processed
	exit 1
fi

# remove old unzipped files if existing
echo "[INFO] removing previously unzipped files: ${script_dir}/hop"
rm -rf "${script_dir}/hop"

# unzip latest hop package zip file
echo "[INFO] unzipping hop package: ${HOP_LATEST_ZIP}"
unzip -q "${HOP_LATEST_ZIP}"

# image version is the same as the downloaded hop package version
# and is determined by the hop download script
image_version="${HOP_LATEST_VERSION}"

# tags for the image for local artifactory
image_tag="${image_registry}/${image_name}:${image_version}"
image_tag_latest="${image_registry}/${image_name}:latest"

# tags for the image for docker hub
image_dockerhub_tag="${image_registry_docker}/${image_name}:${image_version}"
image_dockerhub_tag_latest="${image_registry_docker}/${image_name}:latest"

echo "[INFO] building image: ${image_tag}"
container=$(buildah --name "${working_container}" from ${image_registry_group}/${image_base})

# create application directories
buildah run $container mkdir -p "${application_folder_root}"
buildah run $container mkdir -p "${application_folder_root}/logs"
buildah run $container mkdir -p "${application_folder_root}/config/metastore"
buildah run $container mkdir -p "${application_folder_root}/config/environments"
buildah run $container mkdir -p "${application_folder_root}/lib/jdbc"
buildah run $container mkdir -p "${tools_folder_root}"

# copy required files
buildah copy $container "${hop_package_folder}/config" "${application_folder_root}/config"
buildah copy $container "${hop_package_folder}/lib" "${application_folder_root}/lib"
buildah copy $container "${hop_package_folder}/libswt" "${application_folder_root}/libswt"
buildah copy $container "${hop_package_folder}/plugins" "${application_folder_root}/plugins"

buildah copy $container "${hop_package_folder}/hop-run.sh" "${application_folder_root}"
buildah copy $container "${hop_package_folder}/hop-conf.sh" "${application_folder_root}"
buildah copy $container "${hop_package_folder}/LICENSE.txt" /
buildah copy $container entrypoint.sh /

# metastore folder is where the run config will be stored
buildah copy $container "config/metastore" "${application_folder_root}/config/metastore"
# environments folder is where the environment config is stored
buildah copy $container "config/environments" "${application_folder_root}/config/environments"
# copy jdbc drivers to the lib jdbc folder
buildah copy $container "lib/jdbc" "${application_folder_root}/lib"

# simple replacer tool
buildah copy $container simplereplacer/jar "${tools_folder_root}/jar"
buildah copy $container simplereplacer/template "${tools_folder_root}/template"
buildah copy $container simplereplacer/${lib_simplereplacer} "${tools_folder_root}"
buildah copy $container generate_pipeline_runconfig.sh /
buildah copy $container generate_workflow_runconfig.sh /
buildah copy $container generate_environment.sh /

# configuration
buildah config --author "${image_author}" $container

# environment variables
buildah config --env BASE_FOLDER="${application_folder_root}" $container
buildah config --env TOOLS_FOLDER="${tools_folder_root}" $container

# container entrypoint
buildah config --entrypoint /entrypoint.sh $container

#create image
buildah commit --format "${image_format}" $container "${image_name}:${image_version}"

echo "[INFO] build complete: ${image_tag}"

# remove container
buildah rm $container

# tag image
echo "[INFO] tagging image: ${image_tag}"
buildah tag  "${image_name}:${image_version}" "${image_tag}" "${image_tag_latest}"

# push version and push latest to local artifactory
if [ "${push_destination}" != "remote" ]
then
	# check if variable for local registry is defined
	if [ -z "${image_registry_password}" ];
	then
		echo "error: variable [image_registry_password] is undefined"
		exit 1
	fi
	# login to local artifactory
	echo "[INFO] login to registry: ${image_registry}"
	buildah login -u "${image_registry_user}" -p ${image_registry_password} "${image_registry}"

	echo "[INFO] pushing image to local artifactory: ${image_tag}"
	buildah push --tls-verify=false "${image_tag}" "docker://${image_tag}"
	echo "[INFO] pushing image to local artifactory: ${image_tag_latest}"
	buildah push --tls-verify=false "${image_tag}" "docker://${image_tag_latest}"
else
	# push version and push latest to docker hub
	echo "[INFO] pushing image to docker hub: ${image_dockerhub_tag}"
	buildah push --tls-verify=false "${image_tag}" "docker://${image_dockerhub_tag}"
	echo "[INFO] pushing image to docker hub: ${image_dockerhub_tag_latest}"
	buildah push --tls-verify=false "${image_tag}" "docker://${image_dockerhub_tag_latest}"
fi

echo "[INFO] removing hop package folder and files: ${hop_package_folder}"
rm -rf "${script_dir}/${hop_package_folder}"

echo "[INFO] removing hop package zip file: ${HOP_LATEST_ZIP}"
rm -f "${script_dir}/${HOP_LATEST_ZIP}"

echo "[INFO] end of image build and push process ..."
