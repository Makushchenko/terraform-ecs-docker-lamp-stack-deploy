aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 111111111111.dkr.ecr.us-east-1.amazonaws.com

sudo docker tag nginx:latest 111111111111.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage:latest

sudo docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage:latest