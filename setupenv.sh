#!/usr/bin/bash

# ## Verify user is running as root
# if [ "$EUID" -ne 0 ]; then 
# echo "Failed to execute. Please run the following:"
# echo "sudo ./$0"
#   exit 1
# fi

# ## Store user's name
# local_user=$SUDO_USER

# ## If local_user is "root", exit and ask user to run as sudo
# if [ "$local_user" == "root" ]; then
#   echo "Failed to execute. Please run the following:"
#   echo "sudo ./$0"
#   exit 1
# fi

# local_user=$USER

# ## Remove unofficial docker versions from system
# for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
#     sudo apt remove $pkg; 
# done

# ## Update apt repos and download relevant packages
# sudo apt update -y
# sudo apt install -y ca-certificates curl gnupg certbot git

# ## Reference the backup setupenv; need to follow same instruction they did for moving dirs
# ## Clone CTFd repo
# git clone --single-branch https://github.com/CTFd/CTFd.git

# ## Add Docker's official GPG key
# sudo install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg

# ## Add Docker's official apt repo
# echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ## Update apt repos and download docker
# sudo apt update -y
# sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ## Check that group docker was added, else add it
# if [ $(getent group docker) ]; then
#   echo "Group docker already exists"
# else
#   sudo groupadd docker
# fi

# ## Allow user to run docker
# sudo usermod -aG docker $local_user
# newgrp docker

## Implement HTTPS 
read -p "Use HTTPS? (y/n): " https

if [[ $https == "y" ]]; then
  ## Get domain name
  read -p "Enter domain name: " domain

  ## Execute certbot
  echo "*********************************************************"
  echo "YOU MAY NEED TO RERUN THE FOLLOWING COMMAND MANUALLY"
  echo "sudo certbot certonly --standalone -d $domain"
  echo "Sometimes this will error out, rerunning should solve it"
  echo "*********************************************************"
  read -p "Press enter to continue to certbot setup"
  sudo certbot certonly --standalone -d $domain
  
  ## Find new key and copy to ssl directory
  sudo find /etc/letsencrypt/live/$domain -name privkey.pem -exec cp {} ./ssl/ \;
  sudo find /etc/letsencrypt/live/$domain -name fullchain.pem -exec cp {} ./ssl/ \;
  sudo mv ./ssl/privkey.pem  ./ssl/ctfd.key
  sudo mv ./ssl/fullchain.pem ./ssl/ctfd.crt

  ## Replace hostname in docker-compose-production.yml
  sed -i "s/localhost/$domain/g" docker-compose-production.yml
  
  exit 0
fi
exit 0

