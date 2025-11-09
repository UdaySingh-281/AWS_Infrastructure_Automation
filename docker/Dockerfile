FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl gnupg software-properties-common \
    unzip git python3 python3-pip sudo \
    openjdk-17-jdk

RUN curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list && \
    apt-get update && apt-get install -y jenkins

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform

RUN apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get update && apt-get install -y ansible

EXPOSE 8080

CMD ["bash", "-c", "service jenkins start && tail -f /var/log/jenkins/jenkins.log"]