#!/usr/bin/env bash 
set -e


DEPLOYKEYS="${INPUT_DEPLOYKEYS:-__deploykeys}"
nbdev_test_nbs_args="${INPUT_NBDEV_TEST_NBS_ARGS}"

function main() {
    #get_keys
    #install_library
    #nbdev_read_nbs
    #check_for_clean_nbs
    #check_for_library_nb_diff
    nbdev_test_nbs $nbdev_test_nbs_args
}

function get_keys() {
    which jq || (echo "Must have jq installed: sudo apt install -y jq" && false)
    mkdir -p $DEPLOYKEYS
    for key in $(grep '@git+ssh' settings.ini | sed -n -e 's/^.*\(@git+ssh:\/\/\)//p') ; do
        fname=__deploykeys/$( basename $key ).key && echo $fname ;
        aws secretsmanager get-secret-value --secret-id $key | jq '.SecretString' | tr -d '"' | sed 's/\\n/\n/g' > $fname
        chmod 600 $fname ;
    done
}

function install_library() {
    if ls $DEPLOYKEYS/*.key 1> /dev/null 2>&1;
        then
            mkdir -p ~/.ssh
            eval `ssh-agent`
            ssh-add $DEPLOYKEYS/*.key
            ssh -o StrictHostKeyChecking=no -T git@github.com || true
            #ssh into github with no stricthostkeychecking adds github.com to the known hosts
            #but...
            #ssh into github fails with an error code because github kicks you out
        fi
        pip install .
}

function check_for_clean_nbs() {
    echo "Check we are starting with clean git checkout"
    git status
    if [ -n "$(git status -uno -s)" ]; then echo "git status is not clean"; false; fi
    echo "Trying to strip out notebooks"
    nbdev_clean_nbs
    echo "Check that strip out was unnecessary"
    git status -s # display the status to see which nbs need cleaning up
    if [ -n "$(git status -uno -s)" ]; then echo -e "!!! Detected unstripped out notebooks\n!!!Remember to run nbdev_install_git_hooks"; false; fi
}

function check_for_library_nb_diff() {
            if [ -n "$(nbdev_diff_nbs)" ]; then echo -e "!!! Detected difference between the notebooks and the library"; echo "$(nbdev_diff_nbs)"; false; fi
}


main
