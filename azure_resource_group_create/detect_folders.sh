changed_folders=$(git diff --name-only HEAD^ HEAD | grep -Eo 'azure_resource_group_create/[^/]+/' | sort -u)
echo $changed_folders
