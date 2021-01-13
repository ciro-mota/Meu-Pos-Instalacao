#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base o Debian Testing, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/blob/master/LICENSE>
## CHANGELOG:
### 		Última edição 13/01/2021. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/commits/master>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de donwload dinâmicos. ###
url_lutris="http://download.opensuse.org/repositories/home:/strycore/Debian_10/  ./"
url_ppa_lutris="https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key"
url_vivaldi="https://downloads.vivaldi.com/stable/vivaldi-stable_3.5.2115.87-1_amd64.deb"
url_vscodium="https://github.com/VSCodium/vscodium/releases/download/1.52.1/codium_1.52.1-1608165473_amd64.deb"
url_dbox="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
url_dck_key="https://download.docker.com/linux/debian/gpg"
url_ppa_dck="https://download.docker.com/linux/debian"
url_vgrt="https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_linux_amd64.zip"
url_firefox="https://ftp.mozilla.org/pub/firefox/releases/84.0.2/linux-x86_64/pt-BR/firefox-84.0.2.tar.bz2"
url_theme="https://github.com/Michedev/Ant-Dracula-Blue/archive/master.zip"
url_icon="https://github.com/daniruiz/flat-remix-gtk/archive/master.zip"
url_shell="https://github.com/Jannomag/Yaru-Colors/archive/master.zip"

### Programas para instalação. ###	
apps=(celluloid 
		cowsay 
		default-jre 
		docker-ce 
		exfat-fuse 
		fastboot 
		figlet 
		ffmpegthumbnailer 
		flatpak 
		font-manager 
		fortune 
		gnome-tweaks 
		gufw 
		hugo 
		hunspell-pt-br 
		libgnutls30:i386 
		libldap-2.4-2:i386 
		libgpg-error0:i386 
		libxml2:i386 
		libasound2-plugins:i386 
		libsdl2-2.0-0:i386 
		libsqlite3-0:i386 
		lolcat
		lutris 
		mesa-vulkan-drivers 
		neofetch 
		network-manager-gnome 
		p7zip-full 
		plymouth 
		plymouth-themes 
		qbittorrent 
		terminator 
		vim-runtime 
		zsh)
	
flatpak=(com.spotify.Client 
			com.valvesoftware.Steam 
			org.ksnip.ksnip 
			org.onlyoffice.desktopeditors 
			org.remmina.Remmina 			
			org.telegram.desktop)			

diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(lsb_release -cs) = 'bullseye' ]] then;
	echo -e "\e[32;1mDebian Testing. Prosseguindo com o script...\e[m"
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits. ###
sudo dpkg --add-architecture i386

### Instalando requerimentos. ###
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    gnome-software-plugin-flatpak -y

### Adicionando repositórios de terceiros. ###
echo "deb $url_lutris" | sudo tee /etc/apt/sources.list.d/lutris.list
wget -q $url_ppa_lutris -O- | sudo apt-key add -
curl -fsSL "$url_dck_key" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_dck buster stable"

### Atualizando listas e sistema após adição de novos repositórios. ###
sudo apt update -y && sudo apt upgrade -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação do ambiente gráfico minimo. ###

sudo apt install gnome-core xorg gdm3 --no-install-recommends -y

### Instalação de programas. ###### Instalação de programas. ###

for nome_do_app in ${apps[@]}; do
  if ! dpkg -l | grep -q $nome_do_app; then
    sudo apt install "$nome_do_app" -y
  else
    echo "[INSTALADO] - $nome_do_app"
  fi
done

### Instalação de pacotes Flatpak. ###
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for nome_do_flatpak in ${flatpak[@]}; do
  if ! flatpak list | grep -q $nome_do_flatpak; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Download de programas .deb. ###
mkdir "$diretorio_downloads"
wget -c "$url_vivaldi"      -P "$diretorio_downloads"
wget -c "$url_vscodium"     -P "$diretorio_downloads"
wget -c "$url_dbox"	    	-P "$diretorio_downloads"
wget -c "$url_vgrt"			-P "$diretorio_downloads"

### Instalando pacotes .deb. ###
sudo apt install -y $diretorio_downloads/*.deb
unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
sudo mv $diretorio_downloads/vagrant /usr/local/bin

### Limpando pasta temporária dos downloads. ###
sudo rm $diretorio_downloads/*.* -f

### Instalação do Firefox Release. ###
wget -c "$url_firefox"      -P "$diretorio_downloads"
sudo tar xjf $diretorio_downloads/firefox*.bz2 -C /opt
sudo ln -s /opt/firefox/firefox /usr/bin/firefox
sudo chown -R $(whoami):$(whoami) /opt/firefox*

sudo sh -c 'cat <<EOF > /home/$(id -nu 1000)/.local/share/applications/firefox-stable.desktop
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/opt/firefox/firefox/firefox %u
Terminal=false
Type=Application
Icon=/opt/firefox/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF'

sudo chown $(whoami):$(whoami) $HOME/.local/share/applications/firefox-stable.desktop

### Procedimentos e otimizações. ###
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
#gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
#ln -s /usr/share/hunspell/* ~/.config/VSCodium/Dictionaries
sudo mv /etc/network/interfaces /etc/network/interfaces.old
sudo usermod -aG docker $(whoami)
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="splash"/GRUB_CMDLINE_LINUX_DEFAULT="splash quiet"/g' /etc/default/grub
sudo update-grub
sed -i 's/logo-text-version-128.png/logo-text-64.png/g' /etc/gdm3/greeter.dconf-defaults
sudo dpkg-reconfigure gdm3

### Instalação de ícones e temas. ###
mkdir $HOME/.icons
mkdir $HOME/.themes

wget -c "$url_theme"	-P "$diretorio_downloads"
unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
mv $diretorio_downloads/Ant-Dracula-Blue-master $diretorio_downloads/Ant-Dracula-Blue
mv $diretorio_downloads/Ant-Dracula-Blue $HOME/.themes
sudo rm $diretorio_downloads/*.* -f

wget -c "$url_icon"		-P "$diretorio_downloads"
unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
mv $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-GTK-Blue-Dark $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-Blue-Dark
mv $diretorio_downloads/flat-remix-gtk-master/Flat-Remix-Blue-Dark -C $HOME/.icons
sudo rm $diretorio_downloads/*.* -f

wget -c "$url_shell"	-P "$diretorio_downloads"
unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
sleep 10s
mv $diretorio_downloads/Themes/Yaru-Deepblue-dark $HOME/.themes
sudo rm $diretorio_downloads/*.* -f

gsettings set org.gnome.desktop.interface gtk-theme 'Ant-Dracula-Blue'
gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
flatpak --user override org.telegram.desktop --filesystem=/home/$USER/.icons/:ro

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #

### Ativando ZRAM ###
sudo sh -c 'echo zram > /etc/modules-load.d/zram.conf'
sudo sh -c 'echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf'
sudo sh -c 'echo  > /etc/udev/rules.d/99-zram.rules'

sudo sh -c 'cat <<EOF > /etc/udev/rules.d/99-zram.rules
KERNEL=="zram0", ATTR{disksize}="512M",TAG+="systemd"
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

### Finalização e limpeza. ###
sudo apt purge totem -y
sudo apt purge firefox-esr -y
sudo apt autoremove
sudo apt autoclean