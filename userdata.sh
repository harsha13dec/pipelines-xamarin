Content-Type: multipart/mixed; boundary="=+"
MIME-Version: 1.0

--=+
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

cloud_final_modules:
- [scripts-user, always]

--=+
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="replace-ssh-key.bash"

#!/bin/bash

sudo echo "ASPNETCORE_ENVIRONMENT=PreProd" >> /etc/environment

sudo mkdir /mnt/algbbonsaleapipreprod
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/algbbsapreprod.cred" ]; then
    sudo bash -c 'echo "username=algbbsapreprod" >> /etc/smbcredentials/algbbsapreprod.cred'
    sudo bash -c 'echo "password=7t6gufSHZu4Y6J2blw67Dru+0+DNTCMW9Nx/qWI+m09uUFwvjB7gdX49fUZ3TflwISjYocKig1do+AStV+uplg==" >> /etc/smbcredentials/algbbsapreprod.cred'
fi
sudo chmod 600 /etc/smbcredentials/algbbsapreprod.cred

sudo bash -c 'echo "//algbbsapreprod.file.core.windows.net/algbbonsaleapipreprod /mnt/algbbonsaleapipreprod cifs nofail,credentials=/etc/smbcredentials/algbbsapreprod.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //algbbsapreprod.file.core.windows.net/algbbonsaleapipreprod /mnt/algbbonsaleapipreprod -o credentials=/etc/smbcredentials/algbbsapreprod.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30

sudo cat  > /etc/nginx/sites-available/default <<EOL
server {
    ssl on;
    ssl_certificate /mnt/algbbonsaleapipreprod/algbbsslcerts/adminportalpreprod_beachbound_com.chained.crt;
    ssl_certificate_key /mnt/algbbonsaleapipreprod/algbbsslcerts/adminportalpreprod_beachbound_com.key; 
    listen        80;
    server_name   20.231.239.177 onsaleapipreprod.beachbound.com; 
    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo systemctl restart nginx

cd /mnt/algbbonsaleapipreprod/onsaleapi/

dotnet OnSale.BeachBound.API.dll
