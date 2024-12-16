
#!/bin/bash

# Set the parent directory (or use the current directory if not specified)
PARENT_DIR="${1:-.}"

# Iterate over each item in the parent directory
for dir in "$PARENT_DIR"/*; do
    # Check if the item is a directory and contains a .git folder
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo "Processing Git repository in directory: $dir"
        cd "$dir" || { echo "Failed to enter directory: $dir"; continue; }

        # Check the current branch
        CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)

        if [ "$CURRENT_BRANCH" != "main" ]; then
            echo "Switching to 'main' branch in $dir"
            git checkout main || { 
                echo "Failed to switch to 'main' in $dir. Attempting to create and track 'main'."; 
                git checkout -b main origin/main || { 
                    echo "Failed to create or track 'main' in $dir."; 
                    cd "$PARENT_DIR"; 
                    continue; 
                }
            }
        fi

        # Ensure 'main' is tracking 'origin/main'
        git branch --set-upstream-to=origin/main main 2>/dev/null || echo "Failed to set upstream for 'main' in $dir"

        # Pull the latest changes
        git pull || echo "Failed to pull latest changes in $dir"

        # Return to the parent directory
        cd "$PARENT_DIR" || { echo "Failed to return to parent directory"; exit 1; }
    fi
done

echo "Script execution complete."
