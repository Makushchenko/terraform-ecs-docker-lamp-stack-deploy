apt-get -y install apache2

# Install apache and write hello world message
RUN echo 'Hello kube!' > /var/www/html/index.html

# Configure apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
 echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
 echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \ 
 echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \ 
 chmod 755 /root/run_apache.sh

EXPOSE 80

CMD /root/run_apache.sh
EOF

sudo docker build -t hello-kube .

sudo aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111111111111.dkr.ecr.us-east-1.amazonaws.com

sudo aws ecr create-repository \
    --repository-name hello-kube \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1   

sudo docker tag hello-kube:latest 111111111111.dkr.ecr.us-east-1.amazonaws.com/hello-kube:latest

sudo docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/hello-kube:latest

