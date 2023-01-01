# Depoying a Book Register Application on AWS cloud using MERN (MongoDB, Express, Angular, and Node) Stack 

In this project I implemented a simple Book Register applicatiton using MEAN stack deployed on EC2 AWS cloud.

## First Step: Backend configuration & Install NodeJS
1. Create and launch an EC2 instance server in AWS.
![Create EC2 instance](./images/launch-ec2-instance.jpg)

2. Connect to the instance from the terminal and update ubuntu OS.
![Connect & update](./images/connect-2-ubuntu.jpg)
![Connect & update](./images/update-2-ubuntu.jpg)

3. Upgrade ubuntu OS.
![upgrade ubuntu](./images/upgrade-ubuntu.jpg)

4. Added required Certificates (with sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates and curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash  -).
![Add required certificates](./images/added-certificate1.jpg)
![Add required certificates](./images/added-certificate2.jpg)

5. Install NodeJS.
A JavaScript runtime built on Chrome’s V8 JavaScript engine. It will be used to set up the Express routes and AngularJS controllers. 
![install nodejs](./images/install-nodejs.jpg)

## Second Step: Install MongoDB

1. To install MongoDB, first add the apt key and then add sources for mongodb to sources.list.
![pre-install mongodb](./images/pre-2-install-mongodb1.jpg)
![pre-install mongodb](./images/pre-2-install-mongodb2.jpg)


2. Install the MongoDB binary (MongoDB stores data in flexible, JSON-like documents.) It will be used to hold book records that contain book name, isbn number, author, and number of pages.
![install mongodb](./images/install-mongodb.jpg)

3. Start the MongoDB server and verify that it is running.
![start MongoDB](./images/verify-mongodb-runining.jpg)

4. Install npm – Node package manager. Encountered an issue while installing npm.Install aptitude to resolve the conflict. Then install npm with aptitude.
![install npm](./images/install-npm.jpg)
![error installing npm](./images/install-npm1.jpg)
![install aptitude](./images/install-npm2.jpg)
![install npm with aptitude](./images/install-npm3.jpg)
![verify npm installed](./images/install-npm4.jpg)

5. Install body-parser package to help in processing JSON files passed in requests to the server.
![install body-parser](./images/install-body-parser-package.jpg)

6. Create a folder named ‘Books’ and in the Books directory, initialize npm project which assist in creating a package.json file.
![create books directory & json file](./images/create-init-book.jpg)

7. Create a server.js filein thesame directory and edit the required content accordingly.
![create and edit server.js file](./images/create-server.js.jpg)
![create and edit server.js file](./images/editing-server.js.jpg)

## Third Step: Install Express and set up routes to the server.

1. Install Express and Mongoose (with sudo npm install express mongoose) to have a schema for the database to store data of the book register app.
![Install Express & Mongoose](./images/install-express-mongoose.jpg)

2. Create a folder named apps in ‘Books’ folder. Move into the apps folder and create routes.js file. Edit the content of routes.js accordingly.
![create apps folder & routes.js](./images/create-apps-routes.js.jpg)
![create apps folder & routes.js](./images/create-routes.js.jpg)


3. In the ‘apps’ folder, create a folder named models and create a file named book.js in the folder. Edit the content of book.js accordingly.
![create models folder & book.js](./images/create-models-books.js.jpg)
![create models folder & book.js](./images/edit-book.js-in-models.jpg)

## Forth Step: Access the routes with AngularJS

1. Change the directory back to ‘Books’ then create a folder named public and add a file named script.js. Edit the content script.js by pasting the required code (controller configuration defined).
![create public folder & script.js](./images/create-public-script.jpg)
![edit script.js](./images/edit-script.js-in-public.jpg)

2. In public folder, create a file named index.html and edit the content by pasting the required code into the the file.
![create index.js in public](./images/create-index.js-in-public.jpg)
![edit index.js in public](./images/edit-index.js-in-public.jpg)

3. Change the directory back to Books and start the server.
![start server](./images/chang-2-book-snode.jpg)

4. Launch a separate SSH console to test what curl command returns locally.
![start server](./images/return-curl.jpg)

5. For browser access, set open TCP port 3300 in the EC2 instance in  AWS Web Console.
![set port 3300](./images/set-port-3300.jpg)

6. To obtain EC2 intance public DNS or public IP, at the terminal, run curl -s http://169.254.169.254/latest/meta-data/public-ipv4 for Public IP address or curl -s http://169.254.169.254/latest/meta-data/public-hostname for Public DNS name. Then add port 3300 and access the app via the browser.
![access via browser on 3300](./images/browser-access.jpg)