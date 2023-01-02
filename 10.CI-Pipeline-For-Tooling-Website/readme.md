# Continous Integration Pipeline For Tooling Website Solution

In this project, I implemented a Continous Integration solution using Jenkins CI. By using AWS infrastructure to setup a Jenkins server and connect it to a NFS server and Github via webhooks.

## First Step: Install and Configure Jenkins Server.
1. Create an AWS EC2 instance based on Ubuntu Server 20.04 LTS and name it "Jenkins" and open port TCP:8080, SSH:22 and source 0.0.0.0/0 in the inbound rule of the security group. 

    ![Launch Jenkins server](./images/jenkins-server.png)
   ![Launch Jenkins server](./images/port-22.png)
    ![Launch Jenkins server](./images/port-8080.png)
    

2. Connect to Jenkins server via terminal and Install JDK (since Jenkins is a Java-based application).
   - Run `sudo apt update -y`
   - Run `sudo apt install default-jdk-headless`

     ![install jdk](./images/install-jdk.png)

3. Install Jenkins;
   - Run `wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt-get install jenkins`

     ![install Jenkins](./images/install-jenkins.png)

- Make sure Jenkins is up and running.
   - Run `sudo systemctl status jenkins`

     ![status of Jenkins](./images/started-jenkins.png)
 
4. Perform initial Jenkins setup. From the browser access the Jenkins UI 
   - via http://(Jenkins-Server-Public-IP-Address-or-Public-DNS-Name):8080

     ![status of Jenkins](./images/Jenkins-ui.png)

- Unlock Jenkins by retrieving and providing the default admin password. 
  - Retrieve it from your server via the terminal and past it on the browser UI page:
    - Run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`.

    ![retrive admin password](./images/admin-password.png)

- Then install required plugings 
by – choosing the "install suggested plugins." option.

   ![install plugins](./images/installing-plugins.png)

- After plugins installation – create an admin user and obtain Jenkins server address and login.

   ![Jenkins starts](./images/start-jenkins.png)
![Jenkins server address](./images/welcome-2-jenkins.png)

## Second Step: Configure Jenkins job/project to retrieve source codes from GitHub using Webhooks.

1. Enable webhooks on the tooling repo in GitHub repository settings.

  ![get tooling from darey.io](./images/fork-tooling.png)

   
- then  add the following url to webhook setting of the forked repo. URL: http://(Jenkins-Server-Public-IP-Address-or-Public-DNS-Name):8080/github-webhook

 

 

- Create freestyle project in Jenkins web console:
  - click `"New Item" on the left pan and create a "Freestyle project"`
  - `name: project9, click on free style project then okay.
 ![create freestyle project](./images/freestyle-project.png)

 - In configuration of your Jenkins freestyle project choose Git repository. 
- under source code management: Select Git

- connect personal GitHub repository, by providing the URL to the tooling solution.
then copy and past it into the "Repository URL" then "Add Credentials" and save.

![Config Github](./images/git-source-mgt.png)


- Add `credentials of gitub.username and password then click add~ select the 
created credential and save the configuration.

- Click on the Build link and check Console output to see if the build is successfully.

    ![console putput](./images/buld-success.png)

3. Click "Configure" your job/project and add these two configurations:
- `Configure triggering the job from GitHub webhook:

![conf. triggering webhook](./images/githook-config.png)

- Under build environment,configure "Post-build Actions" to Archive the artifacts then files to archive: add ** then click save.

   ![configure triggering](./images/post-build.png)


- To check if the configuration works successfully by editing the readme.md file and adding a line at the ending then commit changes.

![build by webhook](./images/check-config-git.png)

The fifth build is triggered by the recent push event. A new build has been launched automatically (by webhook) – artifacts, saved on Jenkins server. status>view artifacts!

   ![view artifacts](./images/webhook-trigger.png)

![view artifacts](./images/check-config-git2.png)
- By default, the artifacts are stored on Jenkins server locally.
   ls /var/lib/jenkins/jobs/tooling_github/builds/<build_number>/archive/

   ![jenkins artifacts](./images/artifacts.png)
     ![jenkins artifacts](./images/check-config-git-artifacts.png)


## Third Step: Configure Jenkins To Copy Files To NFS Server VIA SSH

1. Copy artifacts from Jenkins server to /mnt/apps directory on NFS server.
- Install "Publish Over SSH" plugin, to Configure Jenkins to copy files to NFS server via SSH. On "Available" tab search for "Publish Over SSH" plugin and install it by ticking the box and hit install without restart.


   ![install plugins](./images/open-ssh1.png)
   ![install plugins](./images/open-ssh2.png)


2. Configure the job/project to copy artifacts over to NFS server.
   - On main dashboard select "Manage Jenkins" and choose "Configure System" menu item.
   - Scroll down to "Publish over SSH" plugin configuration section and configure it to be able to connect to your NFS server.

     ![publish over SSH](./images/oppen-ssh-setup.png)
  
- Provide the content of private key (content of .pem file that you use to connect to NFS 
server via SSH/Putty). Test the configuration and make sure the connection returns Success.




- To copy files to NFS server, open your Jenkins job/project configuration page and add 
another one "Post-build Action", select Send buld artifacts over SSH and in the source file option add ** then save.

 ![setting post-build](./images/send-over-ssh.png)


- Check permission of /mnt/apps and change its permission on the NFS server
sudo chmod 777 /mnt/apps
sudo chmod -R 777 /mnt
sudo chown nobody:nobody /mnt/apps
sudo chown -R nobody:nobody /mnt

 ![check permission](./images/check-permission-onapps.png).


-  Then make changes in README.MD file in your GitHub. Like deleting the comment on line 75 earlier added to the README.md file of the Tooling repository then commit changes.

 ![changes to readme file](./images/comment-removed.png)


- Webhook will trigger the new #6 new job and in the "Console Output" of the job you will find something like this:
 ![changes to readme file](./images/6th-job.png)

- To make sure that the files in /mnt/apps have been udated – connect via SSH/Putty to your NFS server and check README.MD file.

 ![new trigger by webhook](./images/file-copied-2-nfs.png)
![content of readme file](./images/file-copied-2-nfs.png)
- Check the content of the artifacts just collected on the NFS server:
cd /mnt/apps
ll
then cat /mnt/apps/README.md
If you see the changes you had previously made in your GitHub – the job works as expected.

 ![new content of artifacts](./images/content-of-readme.png)

 ![new content of artifacts](./images/content-of-readme2.png)
