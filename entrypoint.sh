#!/bin/bash

FILE="${HOP_FILE}"
LEVEL=${HOP_LEVEL:-Basic}
PARAMETERS="${HOP_PARAMETERS}"
SYSTEM_PROPERTIES="${HOP_SYSTEM_PROPERTIES}"
PIPELINE_RUNCONFIG=${HOP_PIPELINE_RUNCONFIG:-default}
WORKFLOW_RUNCONFIG=${HOP_WORKFLOW_RUNCONFIG:-default}
ENVIRONMENT=${HOP_ENVIRONMENT:-default}
PIPELINE=${HOP_PIPELINE}
WORKFLOW=${HOP_WORKFLOW}

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

  # check if pipeline or workflow runconfig is specified
  if [ -n "$PIPELINE_RUNCONFIG" ]; then
    arguments=(${arguments[@]} "--runconfig=${PIPELINE_RUNCONFIG}")
  # else: check if workflow runconfig is specified
  elif [ -n "$WORKFLOW_RUNCONFIG" ]; then
    arguments=(${arguments[@]} "--runconfig=${WORKFLOW_RUNCONFIG}")
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

  echo "running script to create pipeline run configuratin: ${pipeline_runconfig_script}"
  ${pipeline_runconfig_script}

  echo "running script to create workflow run configuratin: ${workflow_runconfig_script}"
  ${workflow_runconfig_script}

  echo "running script to create environment configuratin: ${environment_script}"
  ${environment_script}

  echo "running script: ${run_hop_script} ${arguments[@]}"
  ${run_hop_script} "${arguments[@]}"

else
  echo "[ERROR] no file to run was specified"
fi
