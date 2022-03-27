          #!/bin/bash
          echo Checking for CHANGELOG.md
          
          if [ ! -f "CHANGELOG.md" ]
          then
              echo "::error::CHANGELOG file not found"
           
          fi
          
           version_line=$(echo "$( git show :CHANGELOG.md)"  | head -1 ) || true
           echo $version_line
          if [ -z "${version_line}"  ]; 
          then
              echo "::error::CHANGELOG.md must have an updated version number. Git diff didn't show changes"
              echo "::dump::Event name: $GITHUB_EVENT_NAME, and Ref: $GITHUB_REF"
            
          fi
           jira_ticket=`git log practice.. --oneline --no-merges | grep -oP '[A-Z0-9]+-\d+' | head --lines=1`

          if [[ -z "${jira_ticket}"  ]]
          then
              echo -e "\nCommit-log is missing a Jira ticket number.\n"
           exit 1
          else
              echo -e "\nJira ticket from commit-log is <${jira_ticket}>\n"
          fi

          echo -e "\nPull-Request files are excellent.\n"
        
          
          
