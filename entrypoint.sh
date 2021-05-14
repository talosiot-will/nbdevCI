#!/usr/bin/env bash 
set -e


DEPLOYKEYS="${INPUT_DEPLOYKEYS:-__deploykeys}"
nbdev_test_nbs_args="${INPUT_NBDEV_TEST_NBS_ARGS}"

source ./ci_funcs
main
