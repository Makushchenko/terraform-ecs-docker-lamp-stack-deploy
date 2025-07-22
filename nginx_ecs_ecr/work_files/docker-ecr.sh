sudo apt update

sudo apt install unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111111111111.dkr.ecr.us-east-1.amazonaws.com

aws ecr create-repository \
    --repository-name petclinic \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1