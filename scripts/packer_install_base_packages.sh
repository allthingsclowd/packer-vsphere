#!/usr/bin/env bash

# Binary versions to check for
[ -f /usr/local/bootstrap/var.env ] && {
    cat /usr/local/bootstrap/var.env
    source /usr/local/bootstrap/var.env
}
    
[ -f var.env ] && {
    cat var.env
    source var.env
}

# TODO: Add checksums to ensure integrity of binaries downloaded

install_webpagecounter_binaries () {
    # Added loop below to overcome Travis-CI/Github download issue
    RETRYDOWNLOAD="1"
    pushd /usr/local/bin
    while [ ${RETRYDOWNLOAD} -lt 10 ] && [ ! -f /usr/local/bin/webcounter ]
    do
        echo "Webpagecounter Binaries Download - Take ${RETRYDOWNLOAD}" 
        # download binaries version
        
        sudo wget -q https://github.com/allthingsclowd/web_page_counter/releases/download/${PKR_VAR_webpagecounter_version}/webcounter
        sleep 5
    done

    [  -f /usr/local/bin/webcounter  ] &>/dev/null || {
        echo "https://github.com/allthingsclowd/web_page_counter/releases/download/${PKR_VAR_webpagecounter_version}/webcounter"
        exit 1
    }

    sudo chmod +x /usr/local/bin/webcounter
    popd    
}

install_factory_secretid_binaries () {
    # Added loop below to overcome Travis-CI download issue
    RETRYDOWNLOAD="1"
    pushd /usr/local/bin
    while [ ${RETRYDOWNLOAD} -lt 10 ] && [ ! -f /usr/local/bin/VaultServiceIDFactory ]
    do
        echo "Vault SecretID Service Download - Take ${RETRYDOWNLOAD}"
        # download binary and template file from latest release
        sudo wget -q https://github.com/allthingsclowd/VaultServiceIDFactory/releases/download/${PKR_VAR_secretid_service_version}/VaultServiceIDFactory
        RETRYDOWNLOAD=$[${RETRYDOWNLOAD}+1]
        sleep 5
    done

    [  -f /usr/local/bin/VaultServiceIDFactory  ] &>/dev/null || {
        echo 'Failed to download Vault Secret ID Factory Service'
        exit 1
    }

    sudo chmod +x /usr/local/bin/VaultServiceIDFactory
    popd   
}

install_web_front_end_binaries () {
    # Added loop below to overcome Travis-CI download issue
    RETRYDOWNLOAD="1"
    sudo mkdir -p /tmp/wpc-fe
    pushd /tmp/wpc-fe
    while [ ${RETRYDOWNLOAD} -lt 10 ] && [ ! -f /var/www/wpc-fe/index.html ]
    do 
        echo "Web Front End Download - Take ${RETRYDOWNLOAD}"
        # download binary and template file from latest release
        sudo wget -q https://github.com/allthingsclowd/web_page_counter_front-end/releases/download/${PKR_VAR_webpagecounter_frontend_version}/webcounterpagefrontend.tar.gz
        [ -f webcounterpagefrontend.tar.gz ] && sudo tar -xvf webcounterpagefrontend.tar.gz -C /var/www
        RETRYDOWNLOAD=$[${RETRYDOWNLOAD}+1]
        sleep 5
    done

    popd

    [  -f /var/www/wpc-fe/index.html  ] &>/dev/null || {
        echo 'Web Front End Download Failed'
        exit 1
    } 
   
}

install_binary () {
    
    pushd /usr/local/bin
    [ -f ${1}_${2}_linux_amd64.zip ] || {
        sudo wget -q https://releases.hashicorp.com/${1}/${2}/${1}_${2}_linux_amd64.zip
    }
    sudo unzip -o ${1}_${2}_linux_amd64.zip
    sudo chmod +x ${1}
    sudo rm ${1}_${2}_linux_amd64.zip
    popd
    ${1} --version
}

install_hashicorp_binaries () {

    install_binary packer ${PKR_VAR_packer_version}
    install_binary vagrant ${PKR_VAR_vagrant_version}
    install_binary vault ${PKR_VAR_vault_version}
    install_binary terraform ${PKR_VAR_terraform_version}
    install_binary consul ${PKR_VAR_consul_version}
    install_binary nomad ${PKR_VAR_nomad_version}
    install_binary envconsul ${PKR_VAR_env_consul_version}
    install_binary consul-template ${PKR_VAR_consul_template_version}
    install_binary nomad-autoscaler ${PKR_VAR_nomad_autoscaler_version}
    install_binary waypoint ${PKR_VAR_waypoint_version}
    install_binary waypoint-entrypoint ${PKR_VAR_waypoint_entrypoint_version}
    install_binary boundary ${PKR_VAR_boundary_version}
    install_binary tfc-agent ${PKR_VAR_tfc_agent_version}
    # install_binary boundary-desktop ${PKR_VAR_boundary_desktop_version}

}

install_chef_inspec () {
    
    [ -f /usr/bin/inspec ] &>/dev/null || {
        pushd /tmp
        curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec   
        popd
        inspec version
    }    

}

install_envoy () {

    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -sL 'https://getenvoy.io/gpg' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
    echo 1a2f6152efc6cc39e384fb869cdf3cc3e4e1ac68f4ad8f8f114a7c58bb0bea01 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://dl.bintray.com/tetrate/getenvoy-deb $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/getenvoy.list
    sudo apt update
    sudo apt install -y getenvoy-envoy
    getenvoy --home-dir "/usr/local/bin" run standard:${PKR_VAR_envoy_version} -- --version
    sudo cp /usr/local/bin/builds/standard/${PKR_VAR_envoy_version}/linux_glibc/bin/envoy /usr/local/bin/.
    sudo chmod +x /usr/local/bin/envoy
    /usr/local/bin/envoy --version
    

}

sudo apt-get clean
sudo apt-get update
sudo apt-get upgrade -y

# Update to the latest kernel
sudo apt-get install -y linux-generic linux-image-generic dialog apt-utils

# Hide Ubuntu splash screen during OS Boot, so you can see if the boot hangs
sudo apt-get remove -y plymouth-theme-ubuntu-text
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
sudo update-grub

sudo apt-get install -y -q wget tmux unzip git redis-server nginx lynx jq curl net-tools open-vm-tools

# disable services that are not used by all hosts
sudo systemctl stop redis-server
sudo systemctl disable redis-server
sudo systemctl stop nginx
sudo systemctl disable nginx

echo "Start Golang installation"
which /usr/local/go &>/dev/null || {
    echo "Create a temporary directory"
    sudo mkdir -p /tmp/go_src
    pushd /tmp/go_src
    [ -f go${PKR_VAR_golang_version}.linux-amd64.tar.gz ] || {
        echo "Download Golang source"
        sudo wget -qnv https://dl.google.com/go/go${PKR_VAR_golang_version}.linux-amd64.tar.gz
    }
    
    echo "Extract Golang source"
    sudo tar -C /usr/local -xzf go${PKR_VAR_golang_version}.linux-amd64.tar.gz
    popd
    echo "Remove temporary directory"
    sudo rm -rf /tmp/go_src
    echo "Edit profile to include path for Go"
    echo "export PATH=$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile
    echo "Ensure others can execute the binaries"
    sudo chmod -R +x /usr/local/go/bin/

    source /etc/profile

    go version

}

install_hashicorp_binaries
install_webpagecounter_binaries
install_factory_secretid_binaries
install_web_front_end_binaries
install_chef_inspec
install_envoy

# Reboot with the new kernel
shutdown -r now
sleep 60

exit 0

