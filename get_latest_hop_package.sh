#!/bin/bash
#
# script to download the hop package and unzip it to the current folder.
# steps:
# - download maven metadata to determine latest version - this will define the folder to download from
# - download maven metadata from the folder determined above, to detrmine the package version
# - variable HOP_LATEST_VERSION will be exported
# - variable HOP_LATEST_ZIP will be exported
# - remove metadata files
#
# uwe geercken - 2020-05-30
#

script_dir="$(dirname "$(readlink -f "$0")")"
maven_metadata_xml=latest_maven-metadata.xml
package_xml=latest_hop_package.xml
latest_version_file=latest_downloaded_version.info

# force download of zip even if latest was already downloaded.
# specify argument as -f=yes or -f=no
forcedownload="${1:3}"

# download url
url="https://artifactory.project-hop.org/artifactory/hop-snapshots-local/org/hop/hop-assemblies-client"

#echo "[INFO] getting maven metadata from: ${url}"
curl -s -o "${maven_metadata_xml}" ${url}/maven-metadata.xml

# find the latest latest package version in the maven metadata file
maven_metadata_latest_hop_version_xml=$(xmllint --xpath '//versioning/latest' "${maven_metadata_xml}")
# stripping the tags
maven_metadata_latest_hop_version=$(echo $maven_metadata_latest_hop_version_xml | sed 's/<latest>//' | sed 's/<\/latest>//')

# full url to the package
full_url=${url}/${maven_metadata_latest_hop_version}

#echo "[INFO] getting maven metadata about package from: ${full_url}"
curl -s -o "${package_xml}" ${full_url}/maven-metadata.xml

# finding the version in the maven xml file
version_xml=$(xmllint --xpath '//snapshotVersion/extension[text()="zip"]/../value' "${package_xml}")
# stripping the tags
version=$(echo $version_xml | sed 's/<value>//' | sed 's/<\/value>//')

# export variable
export HOP_LATEST_VERSION=${version}

# construct full zip file name
zipfile_name="hop-assemblies-client-${version}.zip"
export HOP_LATEST_ZIP=${zipfile_name}

#echo "[INFO] latest hop version zip file: ${zipfile_name}"

# check if we had a previous download
if [ -f ${latest_version_file} ]
then
	previous_download=$(cat ${latest_version_file})
fi

# download file if not previously done for the latest version
if [ "${zipfile_name}" != "${previous_download}" ] || [ "${forcedownload}" == "yes" ]
then
	# download zip file
	echo "[INFO] downloading: ${zipfile_name}"
	curl -s -o ${zipfile_name} ${full_url}/${zipfile_name}

	# save the latest version info to a file
	echo "${zipfile_name}" > ${latest_version_file}
else
	echo "[INFO] latest version already downloaded: ${zipfile_name}"
fi

#echo "[INFO] removing maven metadata files"
rm "${maven_metadata_xml}"
rm "${package_xml}"
