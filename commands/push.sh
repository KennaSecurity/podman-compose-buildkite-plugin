#!/bin/bash
set -ueo pipefail

push_retries="$(plugin_read_config PUSH_RETRIES "0")"

# Targets for pushing come in a variety of forms:

# service <- just a service name
# service:image <- a service name and a specific image name to use
# service:image:tag <- a service name and a specific image and tag to use

# A push figures out the source image from either:
# 1. An image declaration in the docker-compose config for that service
# 2. The default projectname_service image format that docker-compose uses

pulled_services=("")

# Then we figure out what to push, and where
for line in $(plugin_read_list PUSH) ; do
  IFS=':' read -r -a tokens <<< "$line"
  service_name=${tokens[0]}
  service_image=$(compose_image_for_service "$service_name")

  # Pull down prebuilt image if one exists
  if prebuilt_image=$(get_prebuilt_image "$service_name") ; then

    # Only pull it down once
    if ! in_array "${service_name}" "${pulled_services[@]}" ; then
      echo "~~~ :podman: Pulling pre-built service ${service_name}" >&2;
      retry "$push_retries" plugin_prompt_and_run podman pull "$prebuilt_image"
      pulled_services+=("${service_name}")
    fi

    echo "~~~ :podman: Tagging pre-built service ${service_name} image ${prebuilt_image} as ${service_image}" >&2;
    plugin_prompt_and_run podman tag "$prebuilt_image" "$service_image"
  fi

  # Otherwise build service
  if [[ -z "$prebuilt_image" ]] && ! podman_image_exists "${service_image}" ; then
    echo "~~~ :podman: Building ${service_name}" >&2;
    run_podman_compose build "$service_name"
  elif [[ -n "$prebuilt_image" ]]; then
    echo "~~~ :podman: Using pre-built image ${prebuilt_image}"
  else
    echo "~~~ :warning: Skipping build. Using service image ${service_image} from Docker Compose config"
  fi

  # push: "service-name"
  if [[ ${#tokens[@]} -eq 1 ]] ; then
    echo "~~~ :podman: Pushing images for ${service_name}" >&2;
    retry "$push_retries" run_podman_compose push "${service_name}"
  # push: "service-name:repo:tag"
  else
    target_image="$(IFS=:; echo "${tokens[*]:1}")"
    echo "~~~ :podman: Pushing image $target_image" >&2;
    plugin_prompt_and_run podman tag "$service_image" "$target_image"
    retry "$push_retries" plugin_prompt_and_run podman push "$target_image"
  fi
done
