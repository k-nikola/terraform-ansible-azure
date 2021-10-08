# terraform-ansible-azure
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=azure-devops&logoColor=white) ![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)

##### Overview:
This repo contains terraform files needed to provision a VM instance on Azure, and Ansible playbooks needed to set up the VM and run a web site on it.<br>
It's a rather simple static web running inside a lightweight docker container.
Ansible playbooks are executed locally, once the infrastructure is provisioned.<br>
Future goals are to edit this repo, so that the provisioning and setup are done automatically via some CI tool, or to make a completely new project with such pipeline.
