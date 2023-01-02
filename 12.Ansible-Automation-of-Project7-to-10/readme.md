<<<<<<< HEAD
# Ansible Automation of Project7 to Project10
In this project, I configured an Ansible client server as a Bastion Host and and create an Ansible playbook to automate servers configurations for 5 Servers (RedHat and Ubuntu).

## First Step: Install and configure Ansible client to act as a Jump Server/Bastion Host.

1. Update the Name tag of Jenkins EC2 Instance to Jenkins-Ansible which will be used to run the playbooks.

![update name tag on Jenkins instance](./images/Jenkins-Ansible.png)

2. Create a new repository and name it ansible-config-mgt in GitHub account.

![ repo ansible-config-mgt](./images/ansible-config-repo.png)

3. Install Ansible on the Jenkins-Ansible instance.
- Run `sudo apt update`
- Run `sudo apt install ansible -y`

![ install ansible](./images/install-ansible.png)

- Check your Ansible version:
- Run `ansible --version`

![ansible version](./images/ansible-version.png)

4. Configure Jenkins build job to save repository content every time there is changed.

- Create a new Freestyle project - ansible, in Jenkins and point it to your ‘ansible-config-mgt’ repository.
Configure Webhook in GitHub and set webhook to trigger ansible build.
![create free style project ansible ](./images/new-free-style-ansible.png) 
![configure webhook](./images/web-hook-git.png) 
![git-source-mgt](./images/scmgt.png)
![build-trigger](./images/build-trigger.png)
![archive artifacts](./images/archive-artifacts.png)


5. Test your setup by making some change in README.MD file in master/main branch and make sure that builds starts automatically and Jenkins saves the files (build artifacts) in archives folder. Forth build triggered automatically in Jenkins.
![test setup](./images/update-git-test.png)
![test setup](./images/automatic-build-by-git.png)

Run `cat /var/lib/jenkins/jobs/ansible/builds/<build_number>/archive/README.md`

![check setup](./images/check-artifacts-onansible-server.png)



## Second Step – Prepare your development environment using Visual Studio Code
1. Install VScode and configure it to connect to the newly created GitHub repository.

![clone ansile-config-mgt](./images/cloned-ansible-config.png)
![clone ansile-config-mgt](./images/cloned-ansible-config2.png)

2. Clone down your ansible-config-mgt repo to your Jenkins-Ansible instance.
- Run `git clone nsible-config-mgt repo link`

![clone ansile-config-mgt](./images/clone-git-repo.png)



## Third Step - Begin Ansible Development
1. Create a new branch that will be used for development of a new feature, in your ansible-config-mgt GitHub repository. Add a discriptive name.

![create new branch](./images/new-branch.png)

2. Checkout the newly created feature branch to your local machine and start building your code and directory structure.

- Create a directory and name it playbooks – it will be used to store all your playbook files.

![new playbooks](./images/directories.png)

- Create a directory and name it inventory – it will be used to keep your hosts organised.

![new inventory](./images/directories2.png)

3. Within the playbooks folder, create your first playbook, and name it common.yml.

![common.yml](./images/common-yaml.png)

4. Within the inventory folder, create an inventory file (.yml) for each environment (Development, Staging Testing and Production) dev, staging, uat, and prod respectively.

![inventory file](./images/inventory-environments.png)
![inventory file](./images/gitcommit.png)



## Forth Step – Set up an Ansible Inventory

1. Launch the 4 EC2 server instances to start configuring the development servers.

![Spin 4 additional servers](./images/servers.png)



- Setup ssh agent on bastian node for easy access to other nodes. For ssh-agent on linux:
- Run `eval `ssh-agent -s`
- `ssh-add <path-to-private-key>`

![ssh agent](./images/add-key-agent.png)

- connect via ssh into your Jenkins-Ansible server using ssh-agent.

- Run `ssh -A ubuntu@public-ip of Jenkins-Ansible server`

![ssh into server](./images/ssh-into-server.png)
- Confirm the key has been added with the command below and test ssh connection to another server.

- Run `ssh-add -l`

![confirm key](./images/key-persist.png)



- Update your inventory/dev.yml file with server IP addresses.

![inventory file](./images/dev-yml.png)

## Fifth Step - Create a Common Playbook

1. Update your playbooks/common.yml file with following code:


![update common.yml agent](./images/update-common-yml.png)

## Sixth Step – Update GIT with the latest code

1. Push changes made locally to GitHub (especially after review by an extra pair of eyes – it is also called "Four eyes principle".). Commit your code into GitHub. Using `git add ., git commit -m 'message', git push` in the github features branch.


![inventory file](./images/gitcommit.png)

2. Create a Pull Request (PR) as another developer / reviewer of a new feature development and merge the code to the master branch. This triggers an updated build on Jenkins-Ansible server. 

![inventory file](./images/merge-request.png)
![jenkins build](./images/ansible-7.png)
![jenkins build](./images/check-file-jen-ansi.png)

4. checkout from the feature branch into the master, and pull down the latest changes.

![latest changes](./images/git-check-out.png)

## Seventh Step – Run first Ansible test

1. Install wireshark utility (or make sure it is updated to the latest version) on your RHEL 8 and Ubuntu servers using root user, yum for RHEL 8 and apt for Ubuntu.Execute ansible-playbook command and verify if your playbook actually works:



Run `ansible-playbook -i /var/lib/jenkins/jobs/ansible/builds/(latest build number)/archive/inventory/dev.yml /var/lib/jenkins/jobs/ansible/builds/(latest build number)/archive/playbooks/common.yml`

![run playbooks](./images/wireshark-installed.png)


2. check if wireshark has been installed on each of servers.
- Run `which wireshark` or `wireshark --version`

![check that wireshark has been installed](./images/confirm-wireshark1.png)
![confirm wireshark](./images/confirm-wireshark2.png)
![confirm wireshark](./images/confirm-wireshark2.png)

3. Update the ansible playbook with some new Ansible tasks then go through the full checkout -> change codes -> commit -> PR -> merge -> build -> ansible-playbook cycle again.

- Task is to create a directory, file and set timezome on all ther server.

![cycle re-run](./images/common-yml2.png)
![cycle re-run](./images/git-commit2.png)
![update Git](./images/git-update2.png)
![update Git](./images/github-new-pull.png)
![update Git](./images/github-new-pull2.png)
![update Git](./images/github-new-pull3.png)
![update Git](./images/github-new-pull4.png)

- Task created successfully.

![task succcefully executed](./images/task-successful1.png)
![task succcefully executed](./images/task-successful2.png)
![task succcefully executed](./images/confirm1.png)
![task succcefully executed](./images/confirm2.png)
![task succcefully executed](./images/confirm3.png)
=======

>>>>>>> f5163cd129aac7ff07fcc1fc5374efb77e242a09
