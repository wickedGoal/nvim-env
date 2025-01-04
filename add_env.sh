#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
# echo $SCRIPT_DIR

# if RUNNING_DIR is not set, set it to current dir
if [ -z "$RUNNING_DIR" ]; then
  RUNNING_DIR=$(pwd)
fi
# RUNNING_DIR=$(pwd)
# echo $(pwd)

#check if envs dir exists
if [ ! -d "$SCRIPT_DIR/envs" ]; then
  echo "envs dir does not exist"
  exit 1
fi

#check if .config dir exists in RUNNING_DIR
if [ ! -d "$RUNNING_DIR/.config" ]; then
  echo "Seems like you are not in a env dir (no .config dir)"
  read -p "Where is the env dir? " NVIM_ENV_DIR
  # check if NVIM_ENV_DIR exists
  if [ ! -d "$NVIM_ENV_DIR" ]; then
    echo "Directory $NVIM_ENV_DIR does not exist"
    exit 1
  fi
  # check if .config dir exists in NVIM_ENV_DIR
  if [ ! -d "$NVIM_ENV_DIR/.config" ]; then
    echo "Directory $NVIM_ENV_DIR does not contain .config dir"
    exit 1
  fi
else
  NVIM_ENV_DIR=$RUNNING_DIR
fi

ENVS_DIR=$SCRIPT_DIR/envs

echo "nvim env dir: $NVIM_ENV_DIR"

#get last dir name in NVIM_ENV_DIR
NVIM_ENV_NAME=${NVIM_ENV_DIR##*/}

# echo $NVIM_ENV_NAME

# get one-depth subdirectories' name in ENVS_DIR
envs=($(find $ENVS_DIR -maxdepth 1 -mindepth 1 -type d -printf "%f\n"))
# envs=$(find $ENVS_DIR -maxdepth 1 -type d -printf "%f\n")

# echo "${envs[0]}"

# remove element named core from envs
# commented out for now, other envs get to start with no 2
# envs=("${envs[@]/core/}")

# echo "${envs[@]}"

echo -e "\n"
echo "Environments: "
for index in "${!envs[@]}"; do
  # if envs[index] is not empty
  if [ -n "${envs[$index]}" ]; then
    echo "$((index + 1)) ${envs[$index]}"
  fi
done

read -p "Enter env numbers to install (ex: 1 2 3): " env_index

# get item numbers delimited by space in env_index
env_index=($env_index)

for env in "${env_index[@]}"; do
  if [[ ${envs[$((env - 1))]} == "" ]]; then
    echo "Invalid env number: $env, skipping..."
    continue
  fi
  DEST_DIR=$NVIM_ENV_DIR/.config/$NVIM_ENV_NAME/lua
  if [ ! -d "$DEST_DIR" ]; then
    echo "No lua dir in $NVIM_ENV_DIR"
    exit 1
  fi
  # echo DEST_DIR: $DEST_DIR
  echo "Copying env ${envs[$((env - 1))]}..."
  cp -v -r $ENVS_DIR/${envs[$((env - 1))]}/* $NVIM_ENV_DIR/.config/$NVIM_ENV_NAME/lua
done

echo "Done"

# echo "${env_index[@]}"
