#!/bin/bash

FILE="${HOP_FILE}"
LEVEL=${HOP_LEVEL:-Basic}
PARAMETERS="${HOP_PARAMETERS}"
SYSTEM_PROPERTIES="${HOP_SYSTEM_PROPERTIES}"
ENVIRONMENT=${HOP_ENVIRONMENT:-default}
FORCE_PIPELINE=${HOP_FORCE_PIPELINE}
FORCE_WORKFLOW=${HOP_FORCE_WORKFLOW}
RUNCONFIG=${HOP_RUNCONFIG:-default}

# script to run hop
run_hop_script="${BASE_FOLDER}/hop-run.sh"

# script to create a default pipeline run config using an Apache Velocity
# template and environment variables
pipeline_runconfig_script="/generate_pipeline_runconfig.sh"

# script to create a default workflow run config using an Apache Velocity
# template and environment variables
workflow_runconfig_script="/generate_workflow_runconfig.sh"

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

  # check if a runconfig is specified
  arguments=(${arguments[@]} "--runconfig=${RUNCONFIG}")

  # check if environment is specified
  if [ -n "$ENVIRONMENT" ]; then
    arguments=(${arguments[@]} "--environment=${ENVIRONMENT}")
  fi
  # check if force pipeline is specified
  if [ -n "$FORCE_PIPELINE" ]; then
    arguments=(${arguments[@]} "--pipeline")
  fi
  # check if force workflow is specified
  if [ -n "$FORCE_WORKFLOW" ]; then
    arguments=(${arguments[@]} "--workflow")
  fi

  # check if config directory variable is undefined. if so use the
  # hop base folder variable
  if [ ! -n "${HOP_CONFIG_DIRECTORY}" ]; then
    export HOP_CONFIG_DIRECTORY="${BASE_FOLDER}/config"
  fi

  echo "[INFO] running script to create pipeline run configuratin: ${pipeline_runconfig_script}"
  ${pipeline_runconfig_script}

  echo "[INFO] running script to create workflow run configuratin: ${workflow_runconfig_script}"
  ${workflow_runconfig_script}

  echo "[INFO] running script to create environment configuratin: ${environment_script}"
  ${environment_script}

  echo "[INFO] running script: ${run_hop_script} ${arguments[@]}"
  ${run_hop_script} "${arguments[@]}"

else
  echo "[ERROR] no file to run was specified"
fi
