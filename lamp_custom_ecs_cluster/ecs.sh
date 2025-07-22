cat <<EOF > Dockerfile
FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./dedicatted.jpeg /usr/share/nginx/html/dedicatted.jpeg
EOF

docker build -t custom-nginx-web-server:latest .

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 346832455654.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage

docker tag custom-nginx-web-server:latest 346832455654.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage:latest

docker push 346832455654.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage:latest

docker rmi 346832455654.dkr.ecr.us-east-1.amazonaws.com/nginx-image-storage:latest
