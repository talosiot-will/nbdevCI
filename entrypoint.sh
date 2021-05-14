#!/usr/bin/env bash 
#set -e


DEPLOYKEYS="${INPUT_DEPLOYKEYS:-__deploykeys}"
REQUIREMENTS_FILE="${INPUT_REQUIREMENTS_FILE:-settings.ini}"
nbdev_test_nbs_args="${INPUT_NBDEV_TEST_NBS_ARGS}"

function main () {
    get_github_deploy_keys
    nbdev_read_nbs
    check_for_clean_nbs
    check_for_library_nb_diff
    nbdev_test_nbs $nbdev_test_nbs_args
}


function get_github_deploy_key ()
{
    which jq > /dev/null || (echo "Must have jq installed: sudo apt install -y jq" && false)

    package=$1
    echo "🔑: "$package
    key=$(echo $package | sed -n -e 's/^.*\(@git+ssh:\/\/\)//p')
    fname=$DEPLOYKEYS/$( basename $key ).key
    aws secretsmanager get-secret-value --secret-id $key | jq '.SecretString' | tr -d '"' | sed 's/\\n/\n/g' > $fname
    chmod 600 $fname
}

function get_github_deploy_keys ()
{
    echo $REQUIREMENTS_FILE

    mkdir -p $DEPLOYKEYS
    packages=$(grep '@git+ssh' $REQUIREMENTS_FILE ) 
    for line in $packages ; do
        get_github_deploy_key $line
    done
}

function check_for_clean_nbs () {
    echo "Check we are starting with clean git checkout"
    git status
    if [ -n "$(git status -uno -s)" ]; then echo "git status is not clean"; false; fi
    echo "Trying to strip out notebooks"
    nbdev_clean_nbs
    echo "Check that strip out was unnecessary"
    git status -s # display the status to see which nbs need cleaning up
    if [ -n "$(git status -uno -s)" ]; then echo -e "!!! Detected unstripped out notebooks\n!!!Remember to run nbdev_install_git_hooks"; false; fi
}

function check_for_library_nb_diff () {
            if [ -n "$(nbdev_diff_nbs)" ]; then echo -e "!!! Detected difference between the notebooks and the library"; echo "$(nbdev_diff_nbs)"; false; fi
}


help() {
    echo "Run CI steps for an nbdev project"
    echo "-f Run an individual function"
    false
}

FUNC="main"
while getopts ":f:" arg; do
    case $arg in
        f) FUNC=$OPTARG;;
        *) help ;;
    esac
done

$FUNC
