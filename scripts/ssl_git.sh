#!/bin/bash
#Configure SSL from Git

#vars
repo=$GIT_URL
server=${repo%:*}
root=${PWD}

#functions
waiting(){
    for((j=0;j<$1;j++))
    do
        if read -p "." -n1 -t1 -s input
        then
            break
        fi
    done
}

#Install dependencies
echo "Clone SSL from Git repo"
echo "Prepare to Install..."
apt update -qq > /dev/null
apt install git crontab -y -qq --no-install-recommends > /dev/null
echo "Done."

#generate key
echo "Generate SSH key..."
rm -rf ./{id_rsa*}  
ssh-keygen -t rsa -q -N "" -f ./id_rsa
echo "Done."
export GIT_SSH_COMMAND="ssh -i ${root}/id_rsa -F /dev/null"
echo -e "Please add this public key to the Repository: $repo\n"
cat ./id_rsa.pub
printf "\n"

#test connection
ssh -o StrictHostKeyChecking=no ${server}
echo "Wait five minutes,then try to connect to ${server}..."
echo "Press any key to skip."
waiting 300
for ((i=1;i<=5;i++))
do
    ssh -T ${server}
    if [ $? -le 1 ]
    then
        echo "Success!"
        break
    elif [ i -lt 5 ]
        echo -e "\033[31m [ERROR]Connection failed! \033[0m"
        echo "Wait 3 minutes to try again.Press any key to skip!"
        waiting 180
    else
        echo -e "\033[31m [ERROR]Connection failed!Are you sure you added the public key correctly? \033[0m"
        echo "Quit!"
        exit 1
    fi
done

#clone the repo
echo "Clone from ${repo}..."
if [ -e '/etc/nginx/cert' ]
then
    rm -r /etc/nginx/cert
fi
if git clone ${repo} --depth 1 /etc/nginx/cert
then
    echo "Done."
else
    echo -e "\033[31m [ERROR]Cloning failed!Please check the network. \033[0m"
    exit 1
fi
echo "Set repository default SSH key..."
cd /etc/nginx/cert
git config core.sshCommand "ssh -i ${root}/id_rsa"
export -n GIT_SSH_COMMAND
echo "Done."
echo "Add crontab task..."
crontab_job="0 0 * * * ${root}/ssl_git_update.sh"
( crontab -l | grep -v "$cron_job"; echo "$cron_job" ) | crontab -
echo "Done."
echo "Reload nginx..."
service nginx force-reload
echo "Done."
echo -e "\033[36m Successful configune SSL! \033[0m"
exit 0
