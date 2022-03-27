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
        
          
          
