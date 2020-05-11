#!/bin/bash

# tool will use the environment variables and merge them with
# a Apache Velocity template and create an output file which
# is the run configuration xml file for hop
#
# uwe geercken - 2020-05-05
#

# apache velocity folder and name of the template
template_folder="${TOOLS_FOLDER}/template/pipeline-runconfig"
template_name="default.xml.template"

# the name of the object to use inside the velocity template.
# example placeholder inside the template: environment.HOP_LEVEL=Basic
key="environment"

# name of the output file of the merge of the environment variables
# and the template. needs to go to the config directory
outputfile="${BASE_FOLDER}/config/metastore/Pipeline Run Configuration/default.xml"

mkdir -p "${BASE_FOLDER}/config/metastore/Pipeline Run Configuration"

# run the template merge process
java -cp "${TOOLS_FOLDER}/*:${TOOLS_FOLDER}/jar/*" com.datamelt.velocity.SimpleReplacer -f="${template_folder}" -t="${template_name}" -k="${key}" -o="${outputfile}"
