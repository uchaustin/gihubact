          #!/bin/bash
          echo Checking for CHANGELOG.md
          
          if [ ! -f "CHANGELOG.md" ]
          then
              echo "::error::CHANGELOG file not found"
              exit 1
          fi
          
           version_line=$(echo "$( git show :CHANGELOG.md)" | egrep -o '^+# [0-9].*[0-9]*.[0-9]*' | head -1 ) || true
          if [ -z "${version_line}"  ]; 
          then
              echo "::error::CHANGELOG.md must have an updated version number. Git diff didn't show changes"
              echo "::dump::Event name: $GITHUB_EVENT_NAME, and Ref: $GITHUB_REF"
              exit 1
          fi
          ls -l /usr/bin/sh
          
          
