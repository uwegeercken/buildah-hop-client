#!/bin/bash

# check if variables are defined
if [ -z "${image_registry_password}" ];
then
	echo "error: variable [image_registry_password] is undefined"
	exit 1
fi

script_dir="$(dirname "$(readlink -f "$0")")"

# base image
image_base=openjdk:8

# new image
image_name="hop"
image_version="0.1"
image_format="docker"
image_author="uwe.geercken@web.de"

image_registry="silent1:8083"
image_registry_group="silent1:8082"
image_registry_user="admin"
image_tag="${image_registry}/${image_name}:${image_version}"
image_tag_latest="${image_registry}/${image_name}:latest"

# name of working container
working_container="hop-working-container"

# simplereplacer tool for merging variables with template
lib_simplereplacer="simplereplacer-0.0.1-SNAPSHOT.jar"

# folder where the hop package files are located
hop_package_folder="hop"

# variables for image
application_folder_root="/opt/hop"
tools_folder_root="/opt/simplereplacer"

# start of build
echo "[INFO] building image: ${image_tag}"
container=$(buildah --name "${working_container}" from ${image_registry_group}/${image_base})

# create application directories
buildah run $container mkdir -p "${application_folder_root}"
buildah run $container mkdir -p "${application_folder_root}/logs"
buildah run $container mkdir -p "/root/.hop/metastore/hop/Pipeline Run Configuration"
buildah run $container touch "/root/.hop/hop.properties"
buildah run $container mkdir -p "${tools_folder_root}"
buildah run $container mkdir -p "${tools_folder_root}/jar"

# copy required files
buildah copy $container "${hop_package_folder}/lib" "${application_folder_root}/lib"
buildah copy $container "${hop_package_folder}/libswt" "${application_folder_root}/libswt"
buildah copy $container "${hop_package_folder}/plugins" "${application_folder_root}/plugins"
buildah copy $container "${hop_package_folder}/hop-run.sh" "${application_folder_root}"
buildah copy $container "${hop_package_folder}/LICENSE.txt" /
buildah copy $container entrypoint.sh /

# simple replacer tool
buildah copy $container simplereplacer/jar "${tools_folder_root}/jar"
buildah copy $container simplereplacer/template "${tools_folder_root}/template"
buildah copy $container simplereplacer/${lib_simplereplacer} "${tools_folder_root}"
buildah copy $container generate_runconfig.sh /

# configuration
buildah config --author "${image_author}" $container

# environment variables for kafka properties files
buildah config --env BASE_FOLDER="${application_folder_root}" $container
buildah config --env TOOLS_FOLDER="${tools_folder_root}" $container
buildah config --entrypoint /entrypoint.sh $container

#create image
buildah commit --format "${image_format}" $container "${image_name}:${image_version}"

# remove container
buildah rm $container

# tag image
echo "[INFO] tagging image: ${image_tag}"
buildah tag  "${image_name}:${image_version}" "${image_tag}" "${image_tag_latest}"

# login to local artifactory
echo "[INFO] login to registry: ${image_registry}"
buildah login -u "${image_registry_user}" -p ${image_registry_password} "${image_registry}"

# push version and push latest to artifactory
echo "[INFO] pushing image: ${image_tag}"
buildah push --tls-verify=false "${image_tag}" "docker://${image_tag}"
echo "[INFO] pushing image: ${image_tag_latest}"
buildah push --tls-verify=false "${image_tag}" "docker://${image_tag_latest}"

echo "[INFO] build complete: ${image_tag}"
