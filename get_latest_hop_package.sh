#!/bin/bash
#
# script to download the maven package xml file, retrieve the version number,
# construct the full remote zipfile name, download the file and unzip it to
# the folder where the script resides.
#
# uwe geercken - 2020-05-05
#

script_dir="$(dirname "$(readlink -f "$0")")"
package_xml=latest_hop_package.xml
url="https://artifactory.project-hop.org/artifactory/hop-snapshots-local/org/hop/hop-assemblies-client/0.20-SNAPSHOT/"

echo "[INFO] getting maven metadata from: ${url}"
curl -s -o "${package_xml}" https://artifactory.project-hop.org/artifactory/hop-snapshots-local/org/hop/hop-assemblies-client/0.20-SNAPSHOT/maven-metadata.xml

# finding the version in the maven xml file
version_xml=$(xmllint --xpath '//snapshotVersion/extension[text()="zip"]/../value' "${package_xml}")
# stripping the tags
version=$(echo $version_xml | sed 's/<value>//' | sed 's/<\/value>//')
export HOP_LATEST_VERSION=${version}

# construct full zip file name
zipfile_name="hop-assemblies-client-${version}.zip"

# download and unzip file if not already done for the latest version
if [ ! -f "${zipfile_name}" ]
then
	echo "[INFO] downloading: ${zipfile_name}"
	curl -s -o ${zipfile_name} ${url}/${zipfile_name}

	echo "[INFO] removing existing folder: ${script_dir}/hop"
	rm -rf "${script_dir}/hop"

	echo "[INFO] unzipping: ${zipfile_name}"
	unzip -q ${zipfile_name}
else
	echo "[INFO] zip file already exists: ${zipfile_name}"
fi

echo "[INFO] removing maven metadata file"
rm "${package_xml}"
echo "[INFO] rm downloaded zip file"
rm "${zipfile_name}"
