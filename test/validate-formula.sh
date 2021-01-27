#! /bin/bash

# this script is intended to be executed via PRs travis CI
set -e

SCRIPT_PATH=$(realpath $0)
SCRIPT_FOLDER=$(dirname $SCRIPT_PATH)

## run salt
function run_salt() {
  SCRIPT_FOLDER=$1
  sudo salt-call state.show_highstate --local --config-dir=$SCRIPT_FOLDER --pillar-root=$SCRIPT_FOLDER/pillar --module-dirs=$SCRIPT_FOLDER/_modules --retcode-passthrough -l debug
}

## this will generate the pillar substituting the METHOD variable
function generate_cluster_pillar() {
  PILLAR_FILE=$1
  METHOD=$2
  cat > $SCRIPT_FOLDER/pillar/cluster.sls <<EOF
# Test file $PILLAR_FILE
$(METHOD="$METHOD" envsubst < $PILLAR_FILE)
EOF
}

function create_config() {
  SCRIPT_FOLDER=$1
  cat >$SCRIPT_FOLDER/minion <<EOF
root_dir: $SCRIPT_FOLDER
file_roots:
  base:
    - $SCRIPT_FOLDER
    - $SCRIPT_FOLDER/..
id: travis
EOF
}

function create_salt_top() {
  SCRIPT_FOLDER=$1
  cat > $SCRIPT_FOLDER/top.sls <<EOF
base:
  '*':
    - cluster
EOF
}

function create_pillar_top() {
  SCRIPT_FOLDER=$1
  mkdir -p $SCRIPT_FOLDER/pillar
  cat > $SCRIPT_FOLDER/pillar/top.sls <<EOF
base:
  '*':
    - cluster
EOF
}

function run_test() {
  # Run the test
  PILLAR_FILE=$1
  echo "==========================================="
  echo " generating pillar from $PILLAR_FILE and top.sls conf files  "
  echo "==========================================="
  generate_cluster_pillar $PILLAR_FILE "hana01"

  echo "==========================================="
  echo "Using primary host - Running init"
  echo "==========================================="


  cat >$SCRIPT_FOLDER/grains <<EOF
host: hana01
EOF

  run_salt $SCRIPT_FOLDER

  echo "==========================================="
  echo " Using secondary host - Running join       "
  echo "==========================================="

  cat >$SCRIPT_FOLDER/grains <<EOF
host: hana02
EOF

  run_salt $SCRIPT_FOLDER

  echo
  echo "==========================================="
  echo " Using third host - Running remove         "
  echo "==========================================="

  cat >$SCRIPT_FOLDER/grains <<EOF
host: hana03
EOF

  run_salt $SCRIPT_FOLDER
}

# Run all the tests from test_pillar folder
create_config $SCRIPT_FOLDER
create_salt_top $SCRIPT_FOLDER
create_pillar_top $SCRIPT_FOLDER
for TEST_PILLAR_FILE in $SCRIPT_FOLDER/test_pillars/*; do
  run_test $TEST_PILLAR_FILE
done
