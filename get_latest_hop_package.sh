#!/bin/bash
#
# script to download the hop package and unzip it to the current folder.
# steps:
# - download maven metadata to determine latest version - this will define the folder to download from
# - download maven metadata from the folder determined above, to detrmine the package version
# - variable HOP_LATEST_VERSION will be exported
# - if the same zipfile has not already been downloaded, download and unzip it
# - remove metadata files and zip file
#
# uwe geercken - 2020-05-09
#

script_dir="$(dirname "$(readlink -f "$0")")"
maven_metadata_xml=latest_maven-metadata.xml
package_xml=latest_hop_package.xml
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

#echo "[INFO] latest hop version zip file: ${zipfile_name}"

# check if we had a previous download
if [ -f latest_download_version.txt ]
then
	previous_download=$(cat latest_download_version.txt)
fi

# download and unzip file if not already done for the latest version
if [ "${zipfile_name}" != "${previous_download}" ]
then
	echo "[INFO] downloading: ${zipfile_name}"
	curl -s -o ${zipfile_name} ${full_url}/${zipfile_name}

	echo "${zipfile_name}" > latest_download_version.txt

	#echo "[INFO] removing existing folder: ${script_dir}/hop"
	rm -rf "${script_dir}/hop"

	echo "[INFO] unzipping: ${zipfile_name}"
	unzip -q ${zipfile_name}

	#echo "[INFO] removing downloaded zip file"
	rm "${zipfile_name}"
else
	echo "[INFO] latest version already download: ${zipfile_name}"
fi

#echo "[INFO] removing maven metadata files"
rm "${maven_metadata_xml}"
rm "${package_xml}"

