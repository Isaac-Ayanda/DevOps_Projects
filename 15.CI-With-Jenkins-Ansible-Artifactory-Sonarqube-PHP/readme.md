# Continuous Integration With Jenkins, Ansible, Artifactory, Sonarqube and PHP

## First Step: Setting up Blue ocean and Jenkinsfile.


1. Install Blue Ocean plugin on Jenkins server.

![Install blue ocean plugin](./images/install-blue-ocean.jpg)

2. Using the blue ocean plugin, created a new pipeline. Choose Github, add Github token and select the corresponding repository.

![create new pipeline in blue ocean](./images/create-new-pipeline.jpg)
![create new pipeline](./images/create-new-pipeline2.jpg)
![create new pipeline](./images/create-new-pipeline3.jpg)

3. Create deploy/jenkinsfile in ansible-config directory on the Jenkins server.

![created jenkinsfile](./images/created-jenkinsfile.jpg)

4. Add a build stage pipeline code snippet into the jenkinsfile to start building it gradually. It uses the shell script module to echo the "Building Stage".

![build stage](./images/create-build-stage.jpg)

5. Push the update to Gihub account.

![push to github](./images/update-git1.jpg)
![push to github](./images/update-git2.jpg)

6. Configure ansible project on jenkins console to run pipline job from Jenkinsfile automatically.

![configure ansible-project](./images/build-config.jpg)

![configure ansible-project](./images/automatic-build.jpg)
![display in blueOcean](./images/automatic-build2.jpg)

7. Create a new git branch and name it feature/jenkinspipeline-stages.

![git feature branch](./images/feature-jp.jpg)

8. Add another code snippet pipeline stage called Test in the Jenkinsfile. Push changes to github and then click on "Scan the repository now" in the ansible project in Jenkins to see feature/jenkinspipeline-stages build.

![test stage](./images/added-test-stage.jpg)
![feature branch in jenkins](./images/feature-jp2.jpg)

9. Check in Blue Ocean to see how the Jenkinsfile has caused a new step in the pipeline launch build for the new branch.

![check new stage in blue ocean](./images/check-blueocean1.jpg)
![check new stage in blue ocean](./images/check-blueocean2.jpg)

10. Quick Task
- Create a pull request to merge the latest code into the main branch.

![pull and merge request](./images/merge-request.jpg)

- After merging the PR, go back into your terminal and switch into the main branch. Pull the latest change.

![main branch pull](./images/git-main-branch-pull.jpg)

- Create a new branch, add more stages into the Jenkins file to simulate below phases. (Just add an echo command like we have in build and test stages)
   - Package 
   - Deploy 
   - Clean up

![new branch](./images/more-stages.jpg)
![more stages](./images/more-stages2.jpg)
![more stages](./images/more-stages3.jpg)
![more stages](./images/more-stages4.jpg)
   
- Verify in Blue Ocean that all the stages are working, then merge your feature branch to the main branch

![verify more stages](./images/more-stages5.jpg)
![merge features branch](./images/more-stages6.jpg)


## Second Step - Running  Ansible Playbook From Jenkins

1. Ensure that Ansible and dependencies are installed.
- Run `yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`
- `yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm`
- `yum install python3 python3-pip wget unzip git -y`
- `python3 -m pip install --upgrade setuptools`
- `python3 -m pip install --upgrade pip`
- `python3 -m pip install PyMySQL`
- `python3 -m pip install mysql-connector-python`
- `python3 -m pip install psycopg2==2.7.5 --ignore-installed`
 

![confirm ansible installed](./images/install-ansible.jpg)
![install ansible dependecies](./images/ansible-dep1.jpg)
![install ansible dependecies](./images/ansible-dep2.jpg)
![install ansible dependecies](./images/ansible-dep3.jpg)
![install ansible dependecies](./images/ansible-dep4.jpg)

2. Install postgresql community.
![install postgresql community](./images/postgres-com-installed.jpg)

3. Install ansible plugin on jenkins console.

![install ansible plugin](./images/ansible-on-jenkins.jpg)
![install ansible plugin](./images/ansible-on-jenkins2.jpg)

 ## Third Step: Run ansible from Jenkins (against the Dev environment successfully).

1. Launch two EC2 server instances (one RedHat for Nginx and Ubuntu for DB) and update dev file.

![spin two servers](./images/two-servers.jpg)
![dev file](./images/dev-file.jpg)

2. Update the content of deploy/jenkinsfile to export environment variables, export ansible.cfg file, specify neccessary stages in the file, and generate and add private key to Jenkins via UI.

![add privatekey](./images/add-private-key.jpg)
![update jenkinsfile](./images/update-jenkinsfile1.jpg)
![update jenkinsfile](./images/update-jenkinsfile2.jpg)


3. Configure ansible on Jenkins via UI and update site.yml file with required changes including generating pipeline script for runing ansible.

![Configure ansible on Jenkins](./images/ansible-config-jenkins.jpg)
![Configure ansible on Jenkins](./images/configure-ansible1.jpg)
![Configure ansible on Jenkins](./images/configure-ansible2.jpg)
![update site.yml file](./images/site-yml1.jpg)

4. Scan Repository and the build process in blue ocean.

![scan features branch repo](./images/run-features-branch.jpg)
![scan features branch repo](./images/run-features-branch2.jpg)
![scan features branch repo](./images/run-features-branch3.jpg)
![scan features branch repo](./images/run-features-branch4.jpg)
![scan features branch repo](./images/run-features-branch5.jpg)
![scan features branch repo](./images/run-features-branch6.jpg)
![scan features branch repo](./images/run-features-branch7.jpg)
![scan features branch repo](./images/run-features-branch8.jpg)
![scan features branch repo](./images/run-features-branch9.jpg)
![scan features branch repo](./images/run-features-branch10.jpg)
![scan features branch repo](./images/run-features-branch11.jpg)
![scan features branch repo](./images/run-features-branch12.jpg)

5. Update Jenkinsfile to introduce parameterization. Reference inventory as a parameter (So that Jenkins can run ansible against any selected environment in the inventory file).

![inventory parameter](./images/inventory-parameter1.jpg)

6. In the Ansible execution section, remove the hardcoded inventory/dev and replace with `inventory/${inventory}`. Now, playbooks can run against the specified inventory environment.

![inventory parameter](./images/inventory-parameter2.jpg)
![scan features branch repo](./images/build-with-param.jpg)
![scan features branch repo](./images/build-with-param2.jpg)
![scan features branch repo](./images/build-with-param3.jpg)

7. Merge features branch to main branch in Github.

![merge features to main branch](./images/merge-features-main.jpg)

## Forth Step: CI/CD Pipeline for TODO Application
1. Fork given [repo](https://github.com/darey-devops/php-todo.git) and clone the repo unto Jenkins-ansible server.

![fork repo](./images/forked-repo.jpg)
![clone repo](./images/clone-todo.jpg)

2. Install PHP, its dependencies and composer (Ref..README.md).

![install php and dependencies](./images/install-php-dependencies1.jpg)
![install php and dependencies](./images/install-php-dependencies2.jpg)
![install php and dependencies](./images/install-php-dependencies3.jpg)
![install php and dependencies](./images/install-php-dependencies4.jpg)
![install php and dependencies](./images/install-php-dependencies5.jpg)
![install composer](./images/install-composer.jpg)

3. Install 'plot plugin' on jenkins console.

![install plot](./images/install-plot1.jpg)
![install plot](./images/install-plot2.jpg)

4. Install 'artifactory plugin' on jenkins console then configure artifactory. Launch another EC2 instance as artifactory server, add its private IP details to ci environment, and configure role that can install artifactory from jenkins server.

![install artifactory](./images/install-artifactory1.jpg)
![install artifactory](./images/install-artifactory2.jpg)
![launch artifactory server](./images/launch-artifactory-server.jpg)
![artifactory Role on Jenkins](./images/add-artifactory-2-ci.jpg)

- Update site.yml file with necessary ansible configuration for artifactory and update static assignment directory.

![update site.yml](./images/update-site-yml-artifactory.jpg)
![update static assignment](./images/static-assignment-artifactory.jpg)

5. Comment out all except artricatory configuration in site.yml, commit to git and then run the playbook in Jenkins by changing the  build with parameter option of the inventory file to ci  to install artifactory.

![site.yml for artifactory](./images/comment-others-in-site.yml.jpg)
![push to git](./images/push-to-git.jpg)
![build with ci](./images/run-playbooks-ci1.jpg)
![run playbook](./images/run-playbooks-ci2.jpg)
![run playbook](./images/run-playbooks-ci3.jpg)
![run playbook](./images/run-playbooks-ci4.jpg)
![run playbook](./images/run-playbooks-ci5.jpg)

6. Access the artifactory server. private-ip:8081 or 8082 to login, create repository and configure artifactory server by adding instance id, url, username and password. Then apply and save.

![confirm installation](./images/login-to-artifactory.jpg)
![create repository](./images/create-repo.jpg)
![configure artifactory](./images/config-artifactory.jpg)


## Fifth Step: Integrate Artifactory and Install Sounarcube.

1. Update the mysql roles to create database homestead, user - homestead and grant permissions.to create the database on the db instance. The user must be at the private ip address of the jenkins server.

![create database on db instance](./images/mysqlrole-2-create-db-and-user.jpg)
![confirm db and user creation](./images/db-and-user-creation1.jpg)
![confirm db and user creation](./images/db-and-user-creation1.jpg)

2. Create another jenkins file in php-todo directory then push to update repo.

![create another jenkinsfile](./images/another-jenkinsfile.jpg)
![push to github](./images/added-jenkinsfile-todo-php.jpg)

3. Ensure mysql client is installed on Jenkins server. Also set bind address on the db server to 0.0.0.0 by editing the mysqld.cnf file - `sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf` and restart mysql server. Update DB connection inside the .env.sample file - DB_HOST= Private IP of the db server, DB_CONNECTION=mysql, DB_PORT=3306. Then test connection to db server from Jenkins server. Afterwards, update repo at github with latest changes.

![install mysql client](./images/install-mysql.jpg)
![set bind address mysql server](./images/set-bind-address.jpg)
![restart mysql ](./images/restart-mysql.jpg)
![test connectiont to db server ](./images/test-connection-2-db-server.jpg)
![updated repo at github ](./images/upate-repo-git.jpg)

4. Create a new pipeline in blueocean for the php-todo app and then build now.

![new pipeline](./images/new-pipeline-todo.jpg)
![scan repo](./images/successful-phptodo.jpg)
![scan repo](./images/successful-phptodo2.jpg)

5. Update the Jenkinsfile to include Unit tests step. Then push to github and build on Jenkins console.

![update Jenkinsfile with unit tests step](./images/unit-test-step.jpg)
![Build in Jenkins](./images/unit-test-step1.jpg)
![Build in Jenkins](./images/unit-test-step2.jpg)

## Sixth Step: Code Quality Analysis

1. Add the code analysis step in Jenkinsfile. The output of the data will be saved in build/logs/phploc.csv file.

![Add code analysis stage](./images/code-analysis-stage.jpg)

2. Ensure phpunit and phploc are installed on Jenkins server. Then add a plot code coverage report stage to the Jenkinsfile. Push to Github then build now to see the update.

![install phploc](./images/phploc1.jpg)
![install phploc](./images/phploc2.jpg)
![install phploc](./images/phploc3.jpg)
![install phploc](./images/phploc4.jpg)
![plot stage](./images/plot-code-stage.jpg)
![Build now](./images/build-code-w-p.jpg)
![plot report shows](./images/plotreport.jpg)

3. Package the artifact and deploy to the artifactory server. First, install zip. Add stages to Jenkinsfile and commit changes to github. Then build now. Upload artifactory successfully.

![install zip](./images/install-zip.jpg)
![zip and package artifact stage](./images/artifact-stage.jpg)
![upload artifactory](./images/upload-to-artifactory1.jpg)
![Package artifactory](./images/upload-to-artifactory2.jpg)
![upload artifactory](./images/upload-to-artifactory3.jpg)
![upload artifactory](./images/upload-to-artifactory4.jpg)

4. Deploy the application to the dev environment by launching Ansible pipeline. Add Deploy stage to Jenkinsfile and uncomment only todo config in site.yml file. Lauch a Todo Server and add private Ip to the dev environment, update static-assignments/deployment.yml with artifactory path with password then commit changes to Github.

![Launch Todo server](./images/todo-server.jpg)
![add Todo ip address](./images/add-ip-todo.jpg)
![update static-assignments/deployment.yml](./images/artifaactory-details.jpg)
[update static-assignments/deployment.yml](./images/artifaactory-details2.jpg)
![uncomment todo in playbooks](./images/uncomment-todo.jpg)

5. Execute build now on the todo app in Jenkins console. This begins and later calls ansible-project to run its playbook before ending.

![Deploy to dev environment](./images/deploy-todo1.jpg)
![Deploy to dev environment](./images/deploy-todo2.jpg)
![Deploy to dev environment](./images/deploy-todo3.jpg)
![Deploy to dev environment](./images/deploy-todo4.jpg)
![Deploy to dev environment](./images/deploy-todo5.jpg)
![Deploy to dev environment](./images/deploy-todo6.jpg)


## Seventh Step: Introduce quality gate by using Sonarqube.

1. Introduce quality gate so that app does not deploy to production environment if unit test and code coverage may not be enough. Launch an Ubuntu EC2 intance (t2.medium) as sonarqube server and comeup with a role that can install sonarqube on the server. Add private ip to ci environment and update site.yml file and install community postgresql is installed for ansible to work properly. Commit to Github.

![sonarqube role](./images/sonarqube-role.jpg)
![update private ip for sonarqube](./images/ip-sonar.jpg)
![update site.yml file](./images/sonar-play.jpg)
![install postgresql](./images/postgresql-installed.jpg)


2. In the ansible project at Jenkins console and run the inventory build parameter with the ci environment to install sonarqube successfully.

![run build with inventory/ci](./images/run-build-with-ci1.jpg)
![run build with inventory/ci](./images/run-build-with-ci2.jpg)
![run build with inventory/ci](./images/run-build-with-ci3.jpg)
![run build with inventory/ci](./images/run-build-with-ci4.jpg)
![run build with inventory/ci](./images/run-build-with-ci5.jpg)
![run build with inventory/ci](./images/run-build-with-ci6.jpg)
![run build with inventory/ci](./images/run-build-with-ci7.jpg)

## Eight Step: Acess and Integrate Sonarqube into the Jenkins Pipeline.

1. Access sonarqube via url:9000 with login details admin.

![access sonarqube url](./images/access-sonarqube1.jpg)

2. Install the sonar scanner plugin In Jenkins.

![install sonarqube plugin](./images/access-sonarqube2.jpg)
![install sonarqube plugin](./images/access-sonarqube3.jpg)

3. Configure the plugin in Jenkins console. Navigate to configure system in Jenkins. Add SonarQube server url and generate authentication token from Sonarqube console (Admin>my account>security).

![Run the playbooks](./images/sonar-settings.jpg)
![Run the playbooks](./images/gen-token.jpg)

4. Configure Quality Gate Jenkins Webhook in SonarQube – The URL should point to the Jenkins server http://{JENKINS_HOST}/sonarqube-webhook/ (Administration > Configuration > Webhooks > Create). Then Setup SonarQube scanner from Jenkins – Global Tool Configuration.

![configure webhook](./images/web-hook.jpg)
![configure webhook](./images/web-hook2.jpg)
![setup sonarqube scanner](./images/setup-sonar.jpg)


5. Update Jenkins Pipeline in Todo directory to include SonarQube scanning and Quality Gate, commit changes then scan Todo repo. 

![update Jekins pipeline](./images/include-sonarqube-in-todo.jpg)
![sonar pipeline failed](./images/sonar-failed.jpg)
![sonarQube gate deployed](./images/sonar-gate-deployed.jpg)

- Update the SonarQube Quality Gate stage in the Php/Jenkinsfile to ensure that the quality gate does not deploy applications to the production environment if there are bugs or issues with the code then commit to update changes. Ensure npm is installed and xdebug.mode=develop,debug,coverage on the jenkins server. Build aborted since the code did not pass quality check.

![update Jenkins file](./images/update-Jenkinsfile-todo1.jpg)
![install npm](./images/install-npm.jpg)
![Build again](./images/quality-no1.jpg)
![Build again](./images/quality-no2.jpg)

6. The sonarqube quality gate failed then the need to Configure sonar-scanner.properties by accessing the tools directory on the sunarqube server to configure the properties file in which SonarQube will require to function during pipeline execution. Then "Restart SonarQube Quality Gate" for it to run successfully

- Run `cd /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQubeScanner/conf/`
- Open sonar-scanner.properties file. Run `sudo vi sonar-scanner.properties` then add configuration related to php-todo project.

![edit sonorqube properties](./images/edit-sonar-properties.jpg)
![add sonarqube properties](./images/add-sonar-properties.jpg)
![restart sonarQube gate](./images/sonar-gate-run.jpg)
![restart sonarQube gate](./images/sonar-gate-run2.jpg)


## Ninth Step: Introducing Jenkins Agent.

- Configured webhook between jenkins server and github to automatically run a build job when there is a push by setting up webhook at Github with Jenkins server public ip details. Launch a new server -agent1 as Jenkins-slave and install Java on it. Then configure it on Jenkins as agent.

![Jenkins agent](./images/jenkins-slave4.jpg)
![Jenkins agent](./images/jenkins-slave.jpg)
![Jenkins agent](./images/jenkins-slave1.jpg)
![Jenkins agent](./images/jenkins-slave2.jpg)










