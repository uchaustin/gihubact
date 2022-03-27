
          if [[ ! -f "CHANGELOG.md" ]]
          then
              echo ::error::CHANGELOG file not found
              exit 1
          fi
