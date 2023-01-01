        
## AUX PROJECT1: Onboarding of 20 users using Shell Scripting

1. Launch an EC2 t2 micro ubuntu Linux instance on AWS Cloud.

![Launch an EC2 instance](./images/ec2-instance.jpg)

2. Connect to the instance from the terminal.

![Update packages](./images/connect-2-ec2.jpg)

3. Create the project folder - Shell and move into the directory.

![create Shell directory](./images/create-Shell-directory.jpg)


4. Create files names.csv, id_rsa, and id_rsa.pub thesame directory.

![create files](./images/create-files.jpg)

5. Edit the content of id_rsa file by copying and pasting the private key into the file. Save and exit.

![Edit-id_rsa](./images/edit-id_rsa.jpg)
![Edit-id_rsa](./images/edit-id_rsa2.jpg)

6. Edit the content of id_rsa.pub file by copying and pasting the public key into the file. Save and exit.

![Edit-id_rsa.pub](./images/edit-id_rsa.pub.jpg)
![Edit-id_rsa](./images/edit-id_rsa.pub2.jpg)

7. Edit the content of names.csv file by adding the first names of the users to be onboarded to the system. Save and exit.

![Edit names.csv](./images/edit-names.csv.jpg)
![Edit names.csv](./images/edit-names.csv2.jpg)

8. Create the developers group that the users will be added unto.

![create developers group](./images/add-group.jpg)

9. Create onboard.sh file that the contain the script and paste the shell script to create the users into the file. Save and exit.

![create onboard.sh file](./images/create-script.jpg)
![add script into the file](./images/create-script2.jpg)

10. Make the file executable by runing chmod +x onboard.sh.

![make onboard.sh executable](./images/make-onboard.sh-exec.jpg)

11. One of the conditions in the script is that only an admin user can run the script. So run - sudo su to elevate to root user profile and then run the file with ./onboard.sh. 

![create onboard.sh file](./images/run-onboard.sh.jpg)

12. The 20 users are automatically created with the appropriate permission, authorised keys saved in the ssh folder in individual home directories, and password expiry information change.

![create onboard.sh file](./images/users-created.jpg)

13. Verify that the users have been created.

![verify users](./images/users-created2.jpg)

14. Check the home directory of one of the users and verify the content of the authorized key file. Exit from the terminal.

![verify users](./images/kelly-home.jpg)

15. Test using one or two user to connect to the server using the private key and the public key. Switch to a linux machine and create a id_rsa.pem file containing the private key.

![create pem file](./images/create-id_rsa.pem.jpg)
![create pem file](./images/create-id_rsa.pem2.jpg)

15. Run chmod 400 on id_rsa.pem to change the mode of the file so that the content can be private and acceptable by the AWS server. Then in thesame directory, try to connect to the server using the first names of the already created users. User connected successfully.

![chmod 400](./images/chmod-400.jpg)
![Kelly connected](./images/kelly-connected.jpg)

15. Test again with another user, using thesame id_rsa.pem file to connect to the server. User connected successfully.

![brian connected](./images/brian-connected.jpg)

Click [here](https://drive.google.com/file/d/1mFpA3QbcExKJv6KX2fYoyBhnueBYbOoN/view) to see brief demo video.