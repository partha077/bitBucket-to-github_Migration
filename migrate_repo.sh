#!/bin/bash

# Input file containing repository names
input_file="repos.txt"

# # Get the list of repositories from the workspace using the Bitbucket API
# echo "Fetching repositories from Bitbucket workspace: $workspace..."

# curl -u $bitbucket_username:$bitbucket_token "https://api.bitbucket.org/2.0/repositories/$workspace?pagelen=100" > repos.json

# # Extract the repository names from the repos.json file
# repo_names=$(jq -r '.values[] | .name' repos.json)

# Set your Bitbucket and GitHub usernames
workspace="visapoc"
bitbucket_username="parthasaradhi.muddula"
#bitbucket_token="########################"
github_username="VisaPoc"
github_token="###################"

# Loop over each repository name in the text file
while IFS= read -r repo; do
  echo "Migrating $repo..."

  # Clone the private Bitbucket repo using your username and access token
  git clone --mirror https://$bitbucket_username@bitbucket.org/$workspace/$repo.git
  #git clone --mirror https://$bitbucket_username:$bitbucket_token@bitbucket.org/$bitbucket_username/$repo.git
  
  # Change into the repo directory
  cd $repo.git
  

  # Create a new repository on GitHub using the GitHub API
  echo "Creating new GitHub repository: $repo..."
  
  curl -H "Authorization: token $github_token" https://api.github.com/user/repos -d "{\"name\":\"$repo\"}"

  # Set the new GitHub remote using your username and access token
  git remote set-url origin https://$github_username:$github_token@github.com/$github_username/$repo.git
  
  # Push the entire history to GitHub
  git push --mirror
  
  # Move back to the previous directory
  cd ..
  
  echo "$repo migrated!"
done < "$input_file"
