#!/bin/dash

bCorrectInput=0
VAGRANT_VERSION="2.2.7";

echo "-----Creating SSH Keys-----"
read -p "Enter your email: " strEmail
ssh-keygen -t rsa -b 4096 -C $strEmail
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo "-----Installing Git and Git GUI-----"
sudo apt install git -y
sudo apt-get install git-gui -y
git config --global user.email $strEmail

echo "-----Installing cURL-----"
sudo apt update
sudo apt upgrade -y
sudo apt install curl -y

echo "-----Installing VS Code-----"
sudo apt update
sudo apt install software-properties-common apt-transport-https wget -y
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y
code --version

echo "-----Installing Guake Terminal------"
sudo apt-get update
sudo apt-get install guake -y
guake --version

echo "-----Setting Guake to start at login-----"
sudo ln -s /usr/share/applications/guake.desktop /etc/xdg/autostart/

while [ $bCorrectInput = 0 ]
do
    bCorrectInput=1
    read -p "Are you using a separate LED keyboard (Y/N)? " strUsingLedKeyboard

    if [ $strUsingLedKeyboard = 'Y' ] || [ $strUsingLedKeyboard = 'y' ]
    then
        echo "-----Fixing rc.local issue-----"
        echo "[Unit]
         Description=/etc/rc.local Compatibility
         ConditionPathExists=/etc/rc.local

        [Service]
         Type=forking
         ExecStart=/etc/rc.local start
         TimeoutSec=0
         StandardOutput=tty
         RemainAfterExit=yes
         SysVStartPriority=99

        [Install]
         WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/rc-local.service

        echo "-----Turning the LED keyboard on at startup with 10 seconds delay-----"
        echo "#!/bin/sh -e
        #
        # rc.local
        #
        # This script is executed at the end of each multiuser runlevel.
        # Make sure that the script will "exit 0" on success or any other
        # value on error.
        #
        # In order to enable or disable this script just change the execution
        # bits.
        #
        # By default this script does nothing.

        sleep 10 && xset led on

        exit 0" | sudo tee -a /etc/rc.local
        sudo chown root /etc/rc.local
        sudo chmod 755 /etc/rc.local
        sudo systemctl enable rc-local
        sudo systemctl start rc-local.service
        sudo systemctl status rc-local.service

        echo "-----Installing xserver-xorg-input for keyboard numpad bug-----"
        sudo apt-get install xserver-xorg-input-all -y

        echo "After this, you need to toggle the Mouse Keys feature under Universal Access to Off"
    elif [ $strUsingLedKeyboard = 'N' ] || [ $strUsingLedKeyboard = 'n' ]
    then
    else
        echo "Sorry, you have entered an invalid input."
        bCorrectInput=0
    fi
done

echo "-----Installing Postman-----"
sudo snap install postman

echo "-----Installing Google Chrome-----"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y

echo "-----Installing Teamviewer-----"
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt install ./teamviewer_amd64.deb -y

echo "-----Installing TLP (Improves Battery Performance)-----"
sudo apt install tlp -y

echo "-----Disabling USB Autosuspend feature of TLP-----"
sudo sed -i 's/USB_AUTOSUSPEND=1/USB_AUTOSUSPEND=0/g' /etc/default/tlp
sudo systemctl restart tlp

bCorrectInput=0

# Loop until the user enters a correct input
while [ $bCorrectInput = 0 ]
do
    # Assume that the user has a correct input
    bCorrectInput=1
    read -p "Which do you want to install? [D]ocker, [V]agrant, or [N]one: " strToInstall

    if [ $strToInstall = 'D' ] || [ $strToInstall = 'd' ]
    then
        echo "-----Installing Docker-----"
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
        sudo apt update
        apt-cache policy docker-ce
        sudo apt install docker-ce -y
        sudo systemctl status docker
    elif [ $strToInstall = 'V' ] || [ $strToInstall = 'v' ]
    then
        echo "-----Installing Vagrant-----"
        sudo apt install virtualbox -y
        sudo apt update
        curl -O https://releases.hashicorp.com/vagrant/{$VAGRANT_VERSION}/vagrant_{$VAGRANT_VERSION}_x86_64.deb
        sudo apt install ./vagrant_${VAGRANT_VERSION}_x86_64.deb -y
        vagrant --version
        mkdir -p ~/Documents/Vagrant/php7
    elif [ $strToInstall = 'N' ] || [ $strToInstall = 'n' ]
    then
        echo "----Installing none of the above-----"
    else
        # Set the correct input flag to false to restart the loop
        bCorrectInput=0
        echo "Sorry, that input is invalid."
    fi
done

# Restart the machine to apply the changes
echo "Finished script. Rebooting...";
sleep 5
sudo reboot