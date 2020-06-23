# Bash scripts
List of my custom-made bash scripts. I use tham on a dialy basis

# create-vhost

A shell script that creates a new virtual host entry for you based on the url and project path you specify in the arguments.

To run the script simple execute the script like this:

```shell script
create-vhost example.local /path/to/project
```

**Note:**
You might need to edit the script before running it to setup your own paths.
Here is a list of stuff you should edit before using the script:

```shell script
VIRTUAL_HOST_PATH="" # this variable is set to use my machines path for virtual host files
SERVER_ADMIN_EMAIL="" # this is set to use admin@example.com by default
```

On line 139: you should alter the command that gets run to restart your webserver service. In my case it is ```httpd``` and ```systemctl``` and on your system it might be something else.


# stop-services

A shell script that will loop trough a list of defined services and try to stop them. It will also output the result of ```service status``` command.

On line 19: change the list of services you wish to be stopped by running the script. 

**Example output of the script:**

```shell script
Service mssql-server status: inactive
``` 


# NOTE 

**All scripts are provided as is and without any warranty. By running these scripts you acknowledge that you know what you are doing and that you understand any possible risks involved with running these scripts and will not hold the author accountable for any possible damages and/or loss of data that my happen.
By using it, you acknowledge that you understand what these scripts do and how it may affect you in any way and take full responsibility for it.**