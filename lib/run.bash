#!/bin/bash

compose_cleanup() {
  # Stop and remove all the linked services and network
  # - Podman Compose only supports the `down` command, so we can't try
  #   using `kill` or `rm` here
  # - Docker Compose has a --volumes option, for removing all volumes when
  #   shutting down, but this is currently missing from Podman Compose
  run_podman_compose down || true
}

# Checks for failed containers and writes logs for them the the provided dir
check_linked_containers_and_save_logs() {
  local service="$1"
  local logdir="$2"

  [[ -d "$logdir" ]] && rm -rf "$logdir"
  mkdir -p "$logdir"

  while read -r line ; do
    if [[ -z "${line}" ]]; then
      # Skip empty lines
      continue
    fi

    service_name="$(cut -d$'\t' -f2 <<<"$line")"
    service_container_id="$(cut -d$'\t' -f1 <<<"$line")"

    if [[ "$service_name" == "$service" ]] ; then
      continue
    fi

    service_exit_code="$(podman inspect --format='{{.State.ExitCode}}' "$service_container_id")"

    # Capture logs if the linked container failed
    if [[ "$service_exit_code" -ne 0 ]] ; then
      echo "+++ :warning: Linked service $service_name exited with $service_exit_code"
      plugin_prompt_and_run podman logs --timestamps --tail 5 "$service_container_id"
      podman logs -t "$service_container_id" &> "${logdir}/${service_name}.log"
    fi
  done <<< "$(podman_ps_by_project --format '{{.ID}}\t{{.Label "com.podman.compose.service"}}')"
}

# podman-compose's -v arguments don't do local path expansion like the .yml
# versions do. So we add very simple support, for the common and basic case.
#
# "./foo:/foo" => "/buildkite/builds/.../foo:/foo"
expand_relative_volume_path() {
  local path="$1"
  echo "${path/.\//$PWD/}"
}
