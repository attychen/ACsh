#!/bin/bash

# Author: ac
# Contact: WeChat [attychen]

# ANSI color codes
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function: Push image
push_image() {
  local image_name=$1
  echo -e "Pushing image [${YELLOW}${image_name}${NC}] to remote repository: ${NC} ${BLUE}${image_name}${NC}"
  if docker push "$image_name"; then
    echo -e "${GREEN}[Push successful]${NC}"
    return 0
  else
    echo -e "${RED}[Push failed]${NC}"
    return 1
  fi
}

# Ensure log directory exists
log_dir="$HOME/autopush"
mkdir -p "$log_dir"

# Log file path
log_file="$log_dir/autopush_$(date +%Y_%m_%d).log"

# Get namespace with default value
default_namespace="ac-script"
echo -e "${YELLOW}Please enter the namespace of the image repository (default: ${default_namespace}): ${NC}"
read -r namespace
namespace=${namespace:-$default_namespace}

# Check if a new tag argument is passed
if [ "$#" -eq 0 ]; then
  echo "No new tag provided, using old tag as default."
else
  new_tag=$1
fi

# List image packages in the current path
echo -e "${YELLOW}List of image packages in the current path: ${NC}"
echo "================================================================================"
mirrors=(*.tar*)
if [ ${#mirrors[@]} -eq 0 ]; then
  echo -e "${RED}No image packages found.${NC}"
  exit 1
fi

for index in "${!mirrors[@]}"; do
  echo "$((index+1)). ${mirrors[index]}"
done
echo "================================================================================"

# Loop through each image package
for index in "${!mirrors[@]}"; do
  selected_file=${mirrors[index]}
  echo -e "Selected image package: ${YELLOW}[$((index+1)).${selected_file}]${NC}"

  # Process the selected image package
  echo "Processing image file: $selected_file"
  
  # Load image and capture load information
  echo "Loading image..."
  if ! load_output=$(docker load -i "$selected_file" 2>&1); then
    echo -e "${RED}[$((index+1)).${selected_file}] Loading failed, please check if the image package file is correct.${NC}"
    read -p "Do you want to skip [${YELLOW}[$((index+1)).${selected_file}]${NC}] and continue with the next image package? (y/n): " skip
    if [[ $skip != "y" ]]; then
      echo "Stopping execution."
      exit 1
    fi
    continue
  fi
  loaded_image=$(echo "$load_output" | grep 'Loaded image: ' | awk '{print $3}')

  # Extract image name and tag
  if [[ $loaded_image =~ (.+)/(.+):(.+) ]]; then
    repo_name=${BASH_REMATCH[2]}
    old_tag=${BASH_REMATCH[3]}
    # If no new tag is provided, use the old tag
    if [ -z "$new_tag" ]; then
      new_tag=$old_tag
    fi
  else
    echo "Unable to parse image name and tag"
    continue
  fi

  echo -e "Obtained image repository ${YELLOW}[ac-script]${NC} service name ${YELLOW}[bitwarden]${NC} version number is ${YELLOW}[${new_tag}]${NC} : ${BLUE}${namespace}/${repo_name}:${new_tag}${NC}"

  # Tag the image
  echo -e "${BLUE}Tagging...${NC}"
  echo -e "Latest summary: ${BLUE}${namespace}/${repo_name}:${new_tag}${NC}"
  new_image_name="registry.cn-hangzhou.aliyuncs.com/${namespace}/${repo_name}:${new_tag}"
  docker tag "$loaded_image" "$new_image_name"

  # Push the image
  push_image "$new_image_name"
  push_status=$?
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $selected_file - $new_image_name - $([ $push_status -eq 0 ] && echo "Push successful" || echo "Push failed")" >> "$log_file"
done

# Print the list of image push statuses
echo -e "${GREEN}List of image push statuses: ${NC}"
echo "================================================================================"
for index in "${!mirrors[@]}"; do
  selected_file=${mirrors[index]}
  service_name=$(basename "$selected_file" .tar)
  if grep "$selected_file" "$log_file" | grep "Push successful"; then
    echo -e "${YELLOW}[$((index+1)).${service_name}][${BLUE}${new_tag}${NC}]-[${GREEN}Push successful${NC}]"
  else
    echo -e "${YELLOW}[$((index+1)).${service_name}][${BLUE}${new_tag}${NC}]-[${RED}Push failed${NC}]"
  fi
done
echo "================================================================================"

# Prompt the user with the absolute path of the log file
echo -e "Log file generated: ${YELLOW}${log_file}${NC}"
