# Ansible Dynamic Assignments (Include) and Community Roles

In this project, I used Ansible configuration management tool to prepare UAT environment for a Tooling web solution. I installed and configured roles for mgsql and load balancers (Apache and Nginx) using ansible galaxy afterwhich I automated the deployment of a tooling web solution.


## First Step: Introducing Dynamic Assignment Into the structure

1. In the ansible-config-mgt GitHub repository start a new branch and call it - dynamic-assignments. Then inside this folder, create a new file and name it env-vars.yml.

![create new branch](./images/dynamic-assignment.png)


3. Create a new folder - env-vars to keep each environment’s variables file. Then Create new YAML files which will used to set the variables.

![updated folder structure](./images/update-folder-structure.png)
    
4. Now edit the instruction in the env-vars.yml file like in the snapshot.

![edit env-vars.yml](./images/env-vars-dynamic-assignments.png)


## Second Step: Update site.yml with dynamic assignments

1. Update site.yml file to make use of the dynamic assignment and merge branch.

![update site.yml](./images/site-yml-updated.png)

![update site.yml](./images/merged-main_dynamic.png)

pushed-git.png
![update site.yml](./images/pushed-git.png)

2. Create a role for MySQL database – it should install the MySQL package, create a database and configure users. Download Mysql Ansible Role from the community. Here, a MySQL role developed by geerlingguy is used. To preserve the GitHub in actual state after installing the new role – make a commit and push to master directory - ‘ansible-config-mgt’. 
- On Jenkins-Ansible server make sure that git is installed and check the version with git --version, then go to ‘ansible-config-mgt’ directory - 

- Run `git init`
- Run `git pull https://github.com/<(your-name)>/ansible-config-mgt.git`
- Run `git remote add origin https://github.com/<(your-name)>/ansible-config-mgt.git`
- Run `git branch roles-feature`
- Run `git switch roles-feature`

![roles feature](./images/roles-feature.png)

3. Inside roles directory create your new MySQL, nginx and apache roles: 
  - Run `ansible-galaxy install geerlingguy.mysql` and rename the folder to mysql: Run `mv geerlingguy.mysql/ mysql`.
  
  - Run `ansible-galaxy install geerlingguy.nginx` and rename the folder to mysql: Run `mv geerlingguy.nginx/ nginx`.

  - Run `ansible-galaxy install geerlingguy.apache` and rename the folder to mysql: Run `mv geerlingguy.apache/ apache`.

![new MysQL role](./images/install-mysql.png)
![new apache and nginx](./images/installed-nginx-apache.png)


4. Read README.md files in the roles to edit the configuration to use correct credentials for MySQL required for the tooling website.

![configure mysql roles](./images/mysqlRole.png)

5. Upload the changes into your GitHub:

- Run `git add`.
- Run `git commit -m "Commit new role files into GitHub"`
- Run `git push --set-upstream origin roles-feature`
- then create a Pull Request and merge it to main branch on GitHub.

![update changes to Github](./images/roles-installed.png)


## Third Step: Load Balancer roles

1. In nginxRole/defaults/main.yml declare variables - enable_nginx_lb: false same in apacheRole/detaults/main.yml

![declare nginx role](./images/default-nginx.png)
![declare apache role](./images/default-apache.png)

- Declare another variable in apacheroles/defaults/main.yml. Load_balancer_is_required and set its value to false as well.

![load_balancer variable](./images/apache-main.yml.png)


2. Update static-assignments/loadbalancers.yml and playbooks/site.yml files respectively.


![updated loadbalancers.yml file](./images/load-balancer-assignments.png)


![updated site.yml file](./images/site-yml.png)


3. Use the  define which loadbalancer to use in dev and uat environment by setting respective environmental variable to true. To enable nginx, in the env-vars\uat.yml file set `enable_apache_lb` to `true`, `load_balancer_is_required` to `true` and in env-vars\dev.yml file set `enable_nginx_lb` to true and `load_balancer_is_required` to `true`
- The reverse will be the case if apache is to be enabled.

![define loadbalancer](./images/env.yml-dev.yml.png)
![define loadbalancer](./images/env.yml-uat.yml.png)

4. Udated inventory for each environment and run Ansible against each environment.

- Run `ansible-playbook -i inventory/uat.yml playbooks/site.yml`

![run ansible playbook](./images/playbook1.png)
![run ansible playbook](./images/playbook1b.png)
![run ansible playbook](./images/playbook2.png)
![run ansible playbook](./images/playbook3a.png)
![run ansible playbook](./images/playbook3b.png)
![run ansible playbook](./images/playbook4a.png)
![run ansible playbook](./images/playbook4b.png)


