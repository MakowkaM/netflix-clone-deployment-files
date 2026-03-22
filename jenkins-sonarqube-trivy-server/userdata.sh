#!/bin/bash

set -e

echo "=== UPDATE SYSTEM ==="
sudo yum update -y

echo "=== INSTALL GIT ==="
sudo yum install git -y

echo "=== INSTALL JAVA (required for Jenkins) ==="
sudo yum install java-21-amazon-corretto -y

echo "=== INSTALL JENKINS ==="
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key

sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo yum install jenkins -y

sudo systemctl daemon-reexec
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=== INSTALL DOCKER ==="
sudo yum install docker -y

sudo systemctl enable docker
sudo systemctl start docker

# Add users to docker group
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

echo "=== INSTALL TRIVY ==="
wget https://github.com/aquasecurity/trivy/releases/download/v0.69.3/trivy_0.69.3_Linux-64bit.rpm
sudo rpm -ivh trivy_0.69.3_Linux-64bit.rpm

echo "=== CONFIGURE SONARQUBE REQUIREMENTS ==="
sudo sysctl -w vm.max_map_count=262144

echo "=== RUN SONARQUBE ==="
sudo docker run -d \
  --name sonar \
  -p 9000:9000 \
  sonarqube:lts-community

echo "=== RESTART JENKINS (important for docker group) ==="
sudo systemctl restart jenkins

echo "=== DONE ==="
echo "Jenkins: http://<YOUR_EC2_IP>:8080"
echo "SonarQube: http://<YOUR_EC2_IP>:9000"
echo "Initial Jenkins password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword


