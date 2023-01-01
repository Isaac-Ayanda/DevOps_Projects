# Deploying and Configuring a LEMP Stack Application On AWS Cloud

 In this project, I learnt how to build a flexible foundation for serving PHP websites and applications to website visitors, using Nginx as web server and MySQL as database management system.  LEMP Stack makes use of Nginx as the web server for hosting the web application. NGINX is an open source software for web serving, reverse proxying, caching, load balancing, media streaming, and more.

## First step: Install Nginx webserver.
1. Create/launch a new EC2 instance for Nginx.
![New Nginx instance](./images/NewNginxintance.jpg)

2. Update the server's web package and (sudo apt update, apt install nginx) install Nginx server.
![update package](./images/update-apt-package.jpg)
![update & Intall Nginx](./images/install-nginx.jpg)

3. Verify that Nginx installation was successful.
![Nginx Intallation Verification](./images/nginx-install-verification.jpg)

4. Update inbound rule for port 80 on Nginx webserver instance so that it can receive web traffic.
![update inbound rule](./images/update-inbound-rule-80.jpg)

5. Check Access locally via DNS/public IP access in Ubuntu shell.
![check local access via DNS](./images/local-access-via-dns.jpg)
![check local access via IP](./images/local-access-via-ip.jpg)

6. Test if Nginx webserver is correctly installed as it responds to request from the internet (using public ip:80 as url).
![check local access via DNS](./images/nginx-response-2-request-from-ipurl.jpg)

## Second Step: Installing MySQL
1. run command ($ sudo apt install mysql-server
) to install MySQL.
![install mySQL](./images/installing-mysql-server.jpg)

2. Log in to the MySQL console (by typing sudo mysql).
![Log into mySQl](./images/log-in-to-mysql.jpg)

3. After login, set password for the root user (as Password.1) using mysql_native_password as default authentication method.
![set root user password](./images/set-root-password-mysql.jpg)

4. Run security script to remove default settings and lock down access to the database system (using sudo mysql_secure_installation).
![run security script](./images/set-root-password-mysql.jpg)

5. Run command ($ sudo mysql_secure_installation
) to configure the validate Security Plugin.
![VSP Setup](./images/set-validate-security-plugin.jpg)

6. Remove anonymous user access and setup other settings.
![remove anonymous user access](./images/remove-anonymous-user.jpg)
![setup other settings](./images/remove-anonymous-user2.jpg)

7. Test if log in to the MySQL console is possible (with sudo mysql -p).
![log in to the MySQL console](./images/mysql-p-after-access.jpg)

## Third Step: Install PHP
1. Run command (sudo apt install php-fpm php-mysql
) to install PHP and its dependencies.
![Install PHP & dependencies](./images/install-php-and-dependencies.jpg)
![Install PHP & dependencies](./images/install-php-and-dependencies2.jpg)

## Fourth Step: Configuring Nginx to Use PHP Processor
1. For multiple domain hosting, create the root web directory for projectLEMP.
![create new web directory](./images/create-new-root-directory.jpg)

2. Assign directory ownership with the $USER environment variable which will reference current system user.
![Assign directory ownership](./images/set-root-user.jpg)

3. Open/Create new configuration file in Nginx’s sites-available directory.
![Open new configuration file](./images/create-new-nano-directory.jpg)
![Open new configuration file](./images/create-new-nano-directory2.jpg)

4. Activate the configuration by linking to the config file from Nginx’s sites-enabled directory which will tell Nginx to use the configuration next time it is reloaded.
![Activate configuration file](./images/activate-config-file.jpg)

5. Test configuration for syntax errors (with sudo nginx -t).
![test configuration for syntax error](./images/test-config-4-error.jpg)

6. Disable default Nginx host that is currently configured to listen on port 80.
![test configuration for syntax error](./images/disable-default-Nginx-host.jpg)

7. Reload Nginx to apply the changes.
![reload to apply changes](./images/disable-default-Nginx-host.jpg)

8. Create an index.html file in web root /var/www/projectLEMP and test that the new server block works as expected.
![create index.html web root](./images/create-index-html.jpg)
Access Via IP
![test that web server is accesible](./images/create-index-html2.jpg)
Access Via DSN name
![test that web server is accesible](./images/create-index-html3.jpg)

## Fift Step: Testing PHP with Nginx
1. Test to confirm that Nginx can correctly hand .php files to the PHP processor by creating an info.php file in the document root.
![test that web server is accesible](./images/create-info.php.jpg)
![test that web server is accesible](./images/create-info.php2.jpg)

2. Access the info.php page by visiting the public domain name or IP address of the AWS instance followed by /info.php.
![access info.php via IP](./images/access-info.php.jpg)

3. After reviewing the information on the info.php file, it is best practice for security reasons to remove the file since it contains sensitive information.
![remove info.php](./images/remove-info.php.jpg)

## Sixth Step: Retrieving Data from Mysql Database with PHP
1. Connect to the MySQL console using the root account.
![connect to Msql](./images/login-2-mysql.jpg)

2. Create a new database - example_database.
![create new database](./images/create-example-database.jpg)

3. Create a new user and assign password using mysql_native_password as default authentication method.
![create new user](./images/create-new-user-database.jpg)

4. Grant the user full privileges to the new database.
![grant user permission to database](./images/grant-user-previlege.jpg)

5. Login with new user credential to test if user has proper permission to database.
![login to test permission](./images/test-database-access-newuser.jpg)

6. Run command to create a test table named -todo_list.
![create table](./images/create-table-todo.jpg)

7. Insert values into the todo_list table.
![insert values into table](./images/insert-values-into-table.jpg)

8. Run command to confirm that the data was successfully saved to todo_list table.
![confirm values are in table](./images/confirm-data-saved-in-table.jpg)

9. Create a PHP script file in custom web root directory that will connect to MySQL and query todo_list table. 
![open todo_list.php in web root](./images/todo-test-table1.jpg)
![create todo_list.php in web root](./images/todo-test-table2.jpg)
![PHP script in web root](./images/todo-test-table.jpg)