#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Ubuntu versão 20.04.2, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/blob/master/LICENSE>
## CHANGELOG:
### 		Última edição 14/05/2021. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/commits/master>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de donwload dinâmicos.
ppa_celluloid="ppa:xuzhen666/gnome-mpv"
ppa_lutris="ppa:lutris-team/lutris"
url_key_brave="https://brave-browser-apt-release.s3.brave.com/brave-core.asc"
url_ppa_brave="https://brave-browser-apt-release.s3.brave.com/"
url_ppa_vivaldi="https://repo.vivaldi.com/archive/linux_signing_key.pub"
url_key_vivaldi="https://repo.vivaldi.com/archive/deb/"
url_key_code="https://packages.microsoft.com/keys/microsoft.asc"
url_ppa_code="https://packages.microsoft.com/repos/vscode"
url_ppa_obs="ppa:obsproject/obs-studio"
url_ppa_dbox="https://linux.dropbox.com/ubuntu"
url_dck_key="https://download.docker.com/linux/ubuntu/gpg"
url_ppa_dck="https://download.docker.com/linux/ubuntu"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
# url_theme="https://github.com/Michedev/Ant-Dracula-Blue/archive/master.zip"
# url_icon="https://github.com/daniruiz/flat-remix-gtk/archive/master.zip"
# url_shell="https://github.com/Jannomag/Yaru-Colors/archive/master.zip"


### Programas para instalação e desinstalação.
apps_remover=(popularity-contest 
		snapd 
		gnome-software-plugin-snap)

apps_requerimentos=(apt-transport-https 
		ca-certificates 
		curl 
		flatpak 
		gnupg-agent 
		gnome-software-plugin-flatpak 
		software-properties-common)		

apps=(brave-browser 
		code 
		chrome-gnome-shell
		cowsay 
		default-jre 
		docker-ce
		dropbox  
		exfat-fuse 
		fastboot 
		ffmpegthumbnailer 
		figlet 
		fortune 
		gnome-mpv 
		gnome-shell-extensions 
		gnome-shell-extension-gamemode 
		gufw 
		hugo 
		hunspell-pt-br
		libvulkan1:i386 
		libgnutls30:i386 
		libldap-2.4-2:i386 
		libgpg-error0:i386 
		libxml2:i386 
		libasound2-plugins:i386 
		libsdl2-2.0-0:i386 
		libfreetype6:i386 
		lolcat 
		lutris 
		neofetch 
		obs-studio 
		qbittorrent 
		terminator 
		ubuntu-restricted-extras 
		vim-runtime
		vivaldi-stable  
		zsh)

flatpak=(com.spotify.Client 
		com.valvesoftware.Steam 
		org.libreoffice.LibreOffice 
		org.remmina.Remmina 
		org.telegram.desktop)

code_extensions=(CoenraadS.bracket-pair-colorizer-2
		dendron.dendron-markdown-shortcuts
		ms-azuretools.vscode-docker
		eamodio.gitlens
		zhuangtongfa.Material-theme
		Shan.code-settings-sync
		ban.spellright
		vscode-icons-team.vscode-icons
		snyk-security.vscode-vuln-cost
		ms-kubernetes-tools.vscode-kubernetes-tools
		HashiCorp.terraform)				

diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(lsb_release -cs) = 'focal' ]] then;
	echo -e "\e[32;1mUbuntu Focal 20.04. Prosseguindo com o script...\e[m"
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits.
sudo dpkg --add-architecture i386

### Desinstalando apps desnecessários.
for nome_do_programa in ${apps_remover[@]}; do
    sudo apt purge "$nome_do_programa" -y
done

### Instalando requerimentos.
for nome_do_appreq in ${apps_requerimentos[@]}; do
  if ! dpkg -l | grep -q $nome_do_appreq; then
    sudo apt install "$nome_do_appreq" -y
  else
    echo "[INSTALADO] - $nome_do_appreq"
  fi
done

### Adicionando repositórios de terceiros (Wine e Lutris).
sudo add-apt-repository "$ppa_celluloid"
sudo add-apt-repository "$ppa_lutris"
sudo add-apt-repository "$url_ppa_obs"
curl -fsSL "$url_dck_key" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_dck $(lsb_release -cs) stable"
curl -fsSL "$url_key_code" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_code stable main"
curl -fsSL "$url_key_brave" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_brave stable main"
curl -fsSL "$url_key_brave" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_brave stable main"
wget -qO- "$url_key_vivaldi" | sudo apt-key add -
sudo add-apt-repository "deb $url_ppa_vivaldi stable main"
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
sudo add-apt-repository "deb $url_ppa_dbox $(lsb_release -cs) main"

### Atualizando sistema após adição de novos repositórios.
sudo apt update && sudo apt upgrade -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação de programas.
for nome_do_app in ${apps[@]}; do
  if ! dpkg -l | grep -q $nome_do_app; then
    sudo apt install "$nome_do_app" -y
  else
    echo "[INSTALADO] - $nome_do_app"
  fi
done

### Instalação de pacotes Flatpak.
flatpak remote-add --if-not-exists flathub $url_flathub

for nome_do_flatpak in ${flatpak[@]}; do
  if ! flatpak list | grep -q $nome_do_flatpak; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Instalação extensões do Code.
for code_ext in ${code_extensions[@]}; do
    code --install-extension "$code_ext" -y
  fi
done

### Instalação do Jopplin
wget -O - $url_jopplin | bash

### Criação de pasta de download temporário.
mkdir "$diretorio_downloads"

### Instalação de ícones e temas.
if [ -d "$HOME/.icons" ]; then
  echo "Pasta já existe."
else
  mkdir $HOME/.icons
fi

if [ -d "$HOME/.themes" ]; then
  echo "Pasta já existe."
else
  mkdir $HOME/.themes
fi

# wget -cq --show-progress "$url_theme"	-P "$diretorio_downloads"
# unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
# mv $diretorio_downloads/Ant-Dracula-Blue-master $diretorio_downloads/Ant-Dracula-Blue
# mv $diretorio_downloads/Ant-Dracula-Blue $HOME/.themes
# sudo rm $diretorio_downloads/*.* -f

# wget -cq --show-progress "$url_icon"	-P "$diretorio_downloads"
# unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
# mv $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-GTK-Blue-Dark $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-Blue-Dark
# mv $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-Blue-Dark -C $HOME/.icons
# sudo rm $diretorio_downloads/*.* -f

# wget -cq --show-progress "$url_shell"	-P "$diretorio_downloads"
# unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
# sleep 10s
# mv $diretorio_downloads/Themes/Yaru-Deepblue-dark $HOME/.themes
# sudo rm $diretorio_downloads/*.* -f

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Ativando ZRAM.
sudo sh -c 'echo zram > /etc/modules-load.d/zram.conf'
sudo sh -c 'echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf'
sudo sh -c 'echo  > /etc/udev/rules.d/99-zram.rules'

sudo sh -c 'cat <<EOF > /etc/udev/rules.d/99-zram.rules
KERNEL=="zram0", ATTR{disksize}="2048M",TAG+="systemd"
EOF'

sudo sh -c 'cat <<EOF > /etc/systemd/system/zram.service
[Unit]
Description=Swap with zram
After=multi-user.target

[Service]
Type=oneshot 
RemainAfterExit=true
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable zram

### Procedimentos e otimizações.
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
sudo usermod -aG docker $(whoami)
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
# sudo gsettings set org.gnome.desktop.interface gtk-theme 'Ant-Dracula-Blue'
# sudo gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# sudo gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
sudo flatpak --system override org.telegram.desktop --filesystem=/home/$USER/.icons/:ro
sudo flatpak --system override com.spotify.Client --filesystem=/home/$USER/.icons/:ro
sudo flatpak --system override com.valvesoftware.Steam --filesystem=/home/$USER/.icons/:ro
sudo update-alternatives --config x-terminal-emulator

### Finalização e limpeza.
sudo apt autoremove
sudo apt autoclean
sudo rm -rf /var/cache/snapd
sudo rm -rf ~/snap

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------- PÓS-REBOOT ----------------------------------------------- #
### Linhas que deverão ser executadas após o reboot e carregamento do ambiente gráfico.

# ln -s /usr/share/hunspell/* ~/.config/VSCodium/Dictionaries