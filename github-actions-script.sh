#!/bin/bash

# Checks whether a repository has CHANGELOG.md.
# Checks that each commit to the repository is updated in the CHANGELOG.md.
# The CHANGELOG version number is updated in the format # 1.0.2, # 12.3.10, # 1.10.1
#Checks that there is jira ticket number associated with the commit.

#Checking if CHANGELOG.md exists
#echo "Checking for CHANGELOG.md"

if [ ! -f "CHANGELOG.md" ]
then
    echo "::error::CHANGELOG file NOT FOUND"
    exit 1
else
    echo "CHANGELOG.md  found"
fi

## Checks if there is version number.
## The version here could be any number of digits provided defined in the following order:
## 1.0.0, # 20.5.1, # 1.203.4

version=$(egrep -o "# [0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" CHANGELOG.md)

if [[ -z "${version}" ]];
then
    echo -e "\CHANGELOG.md must have a version number.\n"
    exit
    else
    echo -e "\Available Version numbers listed below.\n"
    echo "$version"
fi

## Check if jira ticket number is documented.
## This will identify the most recent jira ticket.
 jira_ticket=$(git log --oneline --no-merges | egrep -o [A-Z]*-[0-9]* CHANGELOG.md)

    if [[ -z "${jira_ticket}"  ]]
    then
        echo -e "\nCommit-log is missing a Jira ticket number.\n"
        exit 1
    else
        echo -e "\nJira ticket from commit-log is <${jira_ticket}>\n"
    fi

#echo -e "\nPull-Request files are excellent.\n"


# egrep -o "# [0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}"
#git diff main..PENG-20792 CHANGELOG | egrep '+version'
#This checks if the most recent version is updated
#It works by comparing the newer version to the older one.
#Hence, it will not work if the commit is an initial one.
#It compares the version in the main to that of the branch being pushed/PR.

NEW_COMMIT=$(git diff main..GOVT-20792 -- CHANGELOG.md | egrep -o "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" | head -n 1)
echo $NEW_COMMIT
OLD_COMMIT=$(git diff main..GOVT-20792 -- CHANGELOG.md | egrep -o "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}" | head -2 | tail -1)
echo $OLD_COMMIT

nv1=$NEW_COMMIT
nv2=$OLD_COMMIT

echo ${nv1//./}
echo ${nv2//./}


if [[ ${nv1//./} -gt ${nv2//./} ]]; then
 echo "version is updated"
else
 echo "please update version"
fi
