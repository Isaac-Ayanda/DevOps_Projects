# Deploying a LAMP (Linux,Apache,Mysql,PhP) Stack application (LAMP STACK) on AWS Cloud

 In this project, I learnt how to serve PHP websites and applications to website visitors, using LAMP Stack which make use a Linux server, Apache, an open source software for serving web pages; as web server and MySQL as database management system.

## First Step: Launch EC2 instance on AWS cloud and Install Apache & update the server
1. Lauch a Linux EC2 instance on AWS Cloud.
![Launch EC2 instance](./images/NewApacheintance.jpg)

2. Update packages in package manager.
![Update packages](./images/Update-packages-pm.jpg)

3. Run command (sudo apt install apache2) for apache installation.
![install apache](./images/Command-for-installing-apache.jpg)

4. Verify successful installtion (run sudo systemctl status apache2).
![verify installation](./images/apache-install-verification.jpg)

5. run command (curl http://127.0.0.1:80 or http://localhost:80) to Check how to access the webserver locally.
![webserver Local access](./images/4.webserver-local-access-via-IP.jpg)
![webserver Local access](./images/4.webserver-local-access-via-DNS.jpg)

6. Add inbound rule for HTTP on AWS instance.
![Add inbound rule](./images/5.added-inboundrule-http.jpg)

7. Access webserver(via  public IP) via Browser.
![Access webserver](./images/6.access-webserver-via-browser.jpg)


Second Step: Installed mysql server
1. Run installation command.
![Install mysql](./images/step2-installing-myqsl-server.jpg)

2. Test login.
![Install mysql](./images/step2-login2mysql.jpg)



Thrid Step: Installing PHP
1. Run sudo apt install php libapache2-mod-php php-mysql to Install PHP, PHP-mysql and libapache2-mod-php.
![Install PHP](./images/step3.PHP-mysql-libapache2-mod-php.jpg)

2. check php version (php -v)
![check PHP version](./images/check-php-version.jpg)

Forth Step: Setup Apache Virtual Host for websites
1. Create new domaian directory -projectlamp
![create domain directory](./images/directory-projectlamp.jpg)

2. Assign directory ownership to current root user.
![assign domain ownership](./images/assign-directory-ownership-to-root-user.jpg)

3. Create and open a new configuration file (for projectlamp) in Apache’s sites-available directory.
![create config file for projectlamp](./images/config-file-apachesite-ad.jpg)

4. Show the new file in the sites-available directory.
![the new file in apachesite](./images/show-newfile-apachesites-available.jpg)

5. Enabled the new virtual host (with sudo a2ensite projectlamp
)
![the new virtual host enabled](./images/6.reload-Apache-o.jpg)

6. Disable default apache website, ensure config file is void of syntax error and reload Apache to save changes.
![default apache website disabled](./images/disable-website-void-error.jpg)

7. Create index.html file in the new active web root.
![index.html created in web root](./images/create-index.html.jpg)

8. Open index.html in a browser with IP and DNS
![using IP & DNS to access index.html in browser](./images/open-website-url.jpg)
![using IP & DNS to access index.html in browser](./images/open-website-urldns.jpg)

Fifth Step: Enable PHP on the website
1. Since Index.html takes precidence over index.php by default then change precidence.
![let index.php preceed index.html](./images/change-precidence-4php.jpg)

2. Create new file index.php in custom web root folder(with vim /var/www/projectlamp/index.php)
![create index.php](./images/creating-index.php.jpg)

3. Refresh url to check that php is installed and working.
![refresh url that php is istalled](./images/creating-index.php2.jpg)

4. Remove index.php to protect server sensitive information.
![remove index.php](./images/remove-index.php.jpg)


