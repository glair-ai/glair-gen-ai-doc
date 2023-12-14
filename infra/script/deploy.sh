#!/bin/bash

set -e

ssh -o StrictHostKeyChecking=no deployer@"$IP" "mkdir -p ~/glair-gen-ai-external; cd ~/glair-gen-ai/; rm -rf docker-compose.yml"
scp -o StrictHostKeyChecking=no ../../$SERVICE/scripts/docker/docker-compose.yml deployer@"$IP":~/glair-gen-ai-external/docker-compose.yml
ssh -o StrictHostKeyChecking=no deployer@"$IP" "cd ~/glair-gen-ai-external; aws ecr get-login-password --region $AWS_ECR_REGION | docker login --username AWS --password-stdin $DOCKER_REPO; docker compose pull; docker compose up -d --wait" || EXIT=$?
ssh -o StrictHostKeyChecking=no deployer@"$IP" "cd ~/glair-gen-ai-external/; docker compose logs $DOCKER_SERVICE"
if [[ $EXIT != 0 ]]; then
  echo "$POST_MESSAGE"
  exit $EXIT
fi
