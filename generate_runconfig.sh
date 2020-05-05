#!/bin/bash

# tool will use the environment variables and merge them with
# a Apache Velocity template and create an output file which
# is the run configuration xml file for hop
#
# uwe geercken - 2020-05-05
#

# apache velocity folder and name of the template
template_folder="${TOOLS_FOLDER}/template"
template_name="default.xml.template"

# the name of the object to use inside the velocity template
key="environment"

# name of the output file of the merge of the environment variables
# and the template. needs to go to the folder of the user
outputfile="/root/.hop/metastore/hop/Pipeline Run Configuration/default.xml"

# run the template merge process
java -cp "${TOOLS_FOLDER}/*:${TOOLS_FOLDER}/jar/*" com.datamelt.velocity.SimpleReplacer -f="${template_folder}" -t="${template_name}" -k="${key}" -o="${outputfile}"
