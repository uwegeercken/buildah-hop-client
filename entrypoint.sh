#!/bin/bash

FILE="${HOP_FILE}"
LEVEL=${HOP_LEVEL:-Basic}
PARAMETERS="${HOP_PARAMETERS}"
SYSTEM_PROPERTIES="${HOP_SYSTEM_PROPERTIES}"
RUNCONFIG=${HOP_RUNCONFIG:-default}
ENVIRONMENT=${HOP_ENVIRONMENT:-default}
PIPELINE=${HOP_PIPELINE}
WORKFLOW=${HOP_WORKFLOW}

# script to run hop
run_hop_script="${BASE_FOLDER}/hop-run.sh"

# script to create a default run config using an Apache Velocity
# template and environment variables
runconfig_script="/generate_runconfig.sh"

# script to create a default environment config using an Apache Velocity
# template and environment variables
environment_script="/generate_environment.sh"

# arguments array to construct arguments for the hop-run.sh script
arguments=(${arguments[@]} "--level=${LEVEL}")

# we need at least the filename, otherwise we cannot start
if [ -n "$FILE" ]; then
  arguments=(${arguments[@]} "--file=${FILE}")

  # check if parameters is specified
  if [ -n "$PARAMETERS" ]; then
    arguments=(${arguments[@]} "--parameters=${PARAMETERS}")
  fi
  # check if system properties is specified
  if [ -n "$SYSTEM_PROPERTIES" ]; then
    arguments=(${arguments[@]} "--system-properties=${SYSTEM_PROPERTIES}")
  fi
  # check if runconfig is specified
  if [ -n "$RUNCONFIG" ]; then
    arguments=(${arguments[@]} "--runconfig=${RUNCONFIG}")
  fi
  # check if environment is specified
  if [ -n "$ENVIRONMENT" ]; then
    arguments=(${arguments[@]} "--environment=${ENVIRONMENT}")
  fi
  # check if pipeline is specified
  if [ -n "$PIPELINE" ]; then
    arguments=(${arguments[@]} "--pipeline")
  fi
  # check if workflow is specified
  if [ -n "$WORKFLOW" ]; then
    arguments=(${arguments[@]} "--workflow")
  fi

  echo "running script to create run configuratin: ${runconfig_script}"
  ${runconfig_script}

  echo "running script to create environment configuratin: ${environment_script}"
  ${environment_script}

  echo "running script: ${run_hop_script} ${arguments[@]}"
  ${run_hop_script} "${arguments[@]}"

else
  echo "[ERROR] no file to run was specified"
fi
