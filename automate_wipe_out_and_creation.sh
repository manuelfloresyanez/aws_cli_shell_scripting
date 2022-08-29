#!/bin/bash

remove_double_quotes=$(echo 'tr -d '\"'')

get_all_repository_names(){
	json_path='.repositories[].repositoryName'
	all_repository_names=$(aws ecr describe-repositories | jq $json_path | $remove_double_quotes )
	if [[ -n "$all_repository_names" ]]
	then
		echo 'All repository names: '$all_repository_names
	else
		echo 'No repositories found'
	fi
}

get_all_images_from_repository(){
	json_path='.imageDetails[].imageTags[]'
	if [[ -n "$1" ]]
	then
		all_images_id=$(aws ecr describe-images --repository-name $1 | jq $json_path | $remove_double_quotes )
	else
		return
	fi
	if [[ -n "$all_images_id"  ]]
					then
		echo 'All images of Repository '$1': '$all_images_id
	else
		echo 'No images found in Repository: '$1
	fi
}

delete_image_from_repository(){
	if [[ -n "$2"  ]]
	then
		echo 'Repository name: '$1 'Image ID: '$2
		image_deleted=$(aws ecr batch-delete-image --repository-name $1 --image-ids imageTag=$2)
	else
		return
	fi
	
	if [[ -n "$image_deleted"  ]]
	then
		echo 'Image deleted: '$image_deleted
	else
		echo 'Error deleting image: '$2 'from Repository: '$1
	fi
}

delete_all_images_from_repository(){
	for id in $2
	do
		delete_image_from_repository $1 $id
	done
}

delete_all_images_from_all_repositories(){
	for repository_name in "$@"
	do
		get_all_images_from_repository $repository_name
		delete_all_images_from_repository $repository_name $all_images_id
	done
}

delete_repository(){
	repository_deleted=$(aws ecr delete-repository --repository-name $1)
	if [[ -n "$repository_deleted" ]]
	then
		echo 'Repository deleted: '$repository_deleted
	else
		echo 'Error deleting repository: '$1
	fi
}

delete_all_repositories(){
	for repository_name in $1
	do
		delete_repository $repository_name
	done
}

delete_everything_from_all_aws_services(){
	get_all_repository_names
	delete_all_images_from_all_repositories $all_repository_names
	delete_all_repositories $all_repository_names
}

delete_everything_from_all_aws_services