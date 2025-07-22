  702  nano Dockerfile
  703  sudo docker build -t nginx-web-server .
  728  sudo aws ecr create-repository \\n    --repository-name nginx-web-server-image \\n    --image-scanning-configuration scanOnPush=true \\n    --region us-east-1   
  729  aws ecr create-repository \\n    --repository-name nginx-web-server-image \\n    --image-scanning-configuration scanOnPush=true \\n    --region us-east-1   
  730  kill 7949
  731  aws ecr create-repository \\n    --repository-name nginx-web-server-image \\n    --image-scanning-configuration scanOnPush=true \\n    --region us-east-1
  747  sudo docker push nginx-web-server:latest 111111111111.dkr.ecr.us-east-1.amazonaws.com/nginx-web-server-image
  748  sudo docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/nginx-web-server-image

