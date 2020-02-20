#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'
load '../lib/shared'
load '../lib/run'

# export PODMAN_COMPOSE_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
# export BATS_MOCK_TMPDIR=$PWD

@test "Run without a prebuilt image" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND="echo hello world"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'echo hello world' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image and an empty command" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=""
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image and a custom workdir" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=""
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_WORKDIR=/test_workdir
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --workdir=/test_workdir --rm myservice : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image with a quoted command" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND="sh -c 'echo hello world'"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'sh -c \'echo hello world\'' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image with a multi-line command" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND="cmd1
cmd2
cmd3"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'cmd1\ncmd2\ncmd3' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image with a command config" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=""
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_COMMAND_0=echo
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_COMMAND_1="hello world"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice echo hello world' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a prebuilt image with custom env" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ENV_0=MYENV=0
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ENV_1=MYENV
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ENVIRONMENT_0=MYENV=2
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ENVIRONMENT_1=MYENV
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ENVIRONMENT_2=ANOTHER="this is a long string with spaces; and semi-colons"

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f docker-compose.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 -e MYENV=0 -e MYENV -e MYENV=2 -e MYENV -e ANOTHER=this\ is\ a\ long\ string\ with\ spaces\;\ and\ semi-colons --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a prebuilt image" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a prebuilt image and custom config file" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG=tests/composefiles/docker-compose.v2.0.yml
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f tests/composefiles/docker-compose.v2.0.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f tests/composefiles/docker-compose.v2.0.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice-tests/composefiles/docker-compose.v2.0.yml : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice-tests/composefiles/docker-compose.v2.0.yml : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a prebuilt image and multiple custom config files" {
export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG_0=tests/composefiles/docker-compose.v2.0.yml
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG_1=tests/composefiles/docker-compose.v2.1.yml
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f tests/composefiles/docker-compose.v2.0.yml -f tests/composefiles/docker-compose.v2.1.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f tests/composefiles/docker-compose.v2.0.yml -f tests/composefiles/docker-compose.v2.1.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice-tests/composefiles/docker-compose.v2.0.yml-tests/composefiles/docker-compose.v2.1.yml : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice-tests/composefiles/docker-compose.v2.0.yml-tests/composefiles/docker-compose.v2.1.yml : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a single prebuilt image, no retry on failed pull" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : exit 2"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_failure
  assert_output --partial "Exited with 2"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a single prebuilt image, retry on failed pull" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_PULL_RETRIES=3

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : exit 2" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without a TTY" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_TTY=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 -T --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice without tty"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice without tty"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without dependencies" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_DEPENDENCIES=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --no-deps --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice without dependencies"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice without dependencies"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run without ansi output" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_ANSI=false

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --no-ansi --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice without ansi output"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice without ansi output"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with use aliases" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_USE_ALIASES=true

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 --use-aliases --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice with use aliases output"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice with use aliases output"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with a volumes option" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_VOLUMES_0="./dist:/app/dist"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_VOLUMES_1="./pkg:/app/pkg"

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 -v $PWD/dist:/app/dist -v $PWD/pkg:/app/pkg --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice with volumes"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice with volumes"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with an external volume" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_VOLUMES="buildkite:/buildkite"

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 -v buildkite:/buildkite --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice with volumes"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice with volumes"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with default volumes, extra delimiters" {
  # Tests introduction of extra delimiters, as would occur if
  # EXPORT BUILDKITE_PODMAN_DEFAULT_VOLUMES="new:mount; ${BUILDKITE_PODMAN_DEFAULT_VOLUMES:-}"
  # was used with no existing value
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PODMAN_DEFAULT_VOLUMES="buildkite:/buildkite; ./dist:/app/dist;; ;   ;"

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 -v buildkite:/buildkite -v $PWD/dist:/app/dist --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice with volumes"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice with volumes"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with default volumes" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND=pwd
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PODMAN_DEFAULT_VOLUMES="buildkite:/buildkite;./dist:/app/dist"

  stub podman-compose \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml pull myservice : echo pulled myservice" \
    "-f docker-compose.yml -p buildkite1111 -f docker-compose.buildkite-1-override.yml run --name buildkite1111_myservice_build_1 -v buildkite:/buildkite -v $PWD/dist:/app/dist --rm myservice /bin/sh -e -c 'pwd' : echo ran myservice with volumes"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice : exit 0" \
    "meta-data get podman-compose-plugin-built-image-tag-myservice : echo myimage"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "ran myservice with volumes"
  unstub podman-compose
  unstub buildkite-agent
}

@test "Run with multiple config files" {
  export BUILDKITE_JOB_ID=1111
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_RUN=myservice
  export BUILDKITE_PIPELINE_SLUG=test
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_COMMAND="echo hello world"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CHECK_LINKED_CONTAINERS=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CLEANUP=false
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG_0="llamas1.yml"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG_1="llamas2.yml"
  export BUILDKITE_PLUGIN_PODMAN_COMPOSE_CONFIG_2="llamas3.yml"

  stub podman-compose \
    "-f llamas1.yml -f llamas2.yml -f llamas3.yml -p buildkite1111 build --pull : echo built myservice" \
    "-f llamas1.yml -f llamas2.yml -f llamas3.yml -p buildkite1111 run --name buildkite1111_myservice_build_1 --rm myservice /bin/sh -e -c 'echo hello world' : echo ran myservice"

  stub buildkite-agent \
    "meta-data exists podman-compose-plugin-built-image-tag-myservice-llamas1.yml-llamas2.yml-llamas3.yml : exit 1"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "built myservice"
  assert_output --partial "ran myservice"
  unstub podman-compose
  unstub buildkite-agent
}
