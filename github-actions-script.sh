          echo what is in this directory?
          ls -a
          echo Is java installed?
          java -version
          echo Is Git installed?
          git --version
          echo what about build tools?
          mvn --version
          gradle --version
          ant -version
          echo
          echo 5 where is the Android SDK Root
          echo $ANDROID_SDK_ROOT
          echo
          echo 6. where are the selenium jars?
          echo $SELENIUM_JAR_PATH
          echo
          echo 7. what is the workspace location
          echo $RUNNER_WORKSPACE
          echo
          echo who is running the script
          whoami
          echo 9. How is the disc laid out?
          df
          echo 10. what is environment variables available?
          env
          echo Checking for CHANGELOG.md
          
          if [[ ! -f "CHANGELOG.md" ]]
          then
              echo "::error::CHANGELOG file not found"
              exit 1
          fi
          
           version_line=$(echo "$( git show :CHANGELOG.md)" | egrep -o '^+# [0-9].*[0-9]*.[0-9]*' | head -1 ) || true
  if [[ -z "${version_line}"  ]]; then
      echo "::error::CHANGELOG.md must have an updated version number. Git diff didn't show changes"
      echo "::dump::Event name: $GITHUB_EVENT_NAME, and Ref: $GITHUB_REF"
      exit 1
  fi
          
          
