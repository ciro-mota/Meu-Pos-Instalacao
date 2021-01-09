#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Ubuntu versão 20.04.1, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/blob/master/LICENSE>
## CHANGELOG:
### 		Última edição 09/01/2021. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/commits/master>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de donwload dinâmicos.
ppa_celluloid="ppa:xuzhen666/gnome-mpv"
ppa_lutris="ppa:lutris-team/lutris"
url_vivaldi="https://downloads.vivaldi.com/stable/vivaldi-stable_3.5.2115.87-1_amd64.deb"
url_vscodium="https://github.com/VSCodium/vscodium/releases/download/1.52.1/codium_1.52.1-1608165473_amd64.deb"
url_dbox="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
url_dck_key="https://download.docker.com/linux/ubuntu/gpg"
url_ppa_dck="https://download.docker.com/linux/ubuntu"
url_vgrt="https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_linux_amd64.zip"
url_theme="https://github.com/Michedev/Ant-Dracula-Blue/archive/master.zip"
url_icon="https://github.com/daniruiz/flat-remix-gtk/archive/master.zip"
url_shell="https://github.com/Jannomag/Yaru-Colors/archive/master.zip"

### Programas para instalação e desinstalação.
apps_remover=(popularity-contest 
				snapd 
				gnome-software-plugin-snap)	

apps=(chrome-gnome-shell
		cowsay 
		default-jre 
		docker-ce 
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
		qbittorrent 
		terminator 
		ubuntu-restricted-extras 
		vim-runtime 
		zsh)

flatpak=(com.spotify.Client 
		com.valvesoftware.Steam 
		org.libreoffice.LibreOffice 
		org.remmina.Remmina 
		org.telegram.desktop)		

diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #

### Checka se a distribuição é a correta.
if [[ `lsb_release -cs` = 'focal' ]] then;
	echo "Ubuntu Focal 20.04. Prosseguindo o script..."
	echo ""
else
	echo "Distribuição não homologada para uso com este script."
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits.
sudo dpkg --add-architecture i386

### Desinstalando apps desnecessários.
for nome_do_programa in ${apps_remover[@]}; do
  if dpkg -l | grep -q $nome_do_programa; then
    sudo apt purge "$nome_do_programa" -y
  fi
done

### Instalando requerimentos.
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
	flatpak \
    gnupg-agent \
	gnome-software-plugin-flatpak \
    software-properties-common -y

### Adicionando repositórios de terceiros (Wine e Lutris).
sudo add-apt-repository "$ppa_celluloid"
sudo add-apt-repository "$ppa_lutris"
curl -fsSL "$url_dck_key" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_dck $(lsb_release -cs) stable"

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
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for nome_do_flatpak in ${flatpak[@]}; do
  if ! flatpak list | grep -q $nome_do_flatpak; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Download e instalação de programas .deb.
mkdir "$diretorio_downloads"
wget -c "$url_vivaldi"  -P "$diretorio_downloads"
wget -c "$url_vscodium" -P "$diretorio_downloads"
wget -c "$url_dbox"		-P "$diretorio_downloads"
wget -c "$url_vgrt"		-P "$diretorio_downloads"

### Instalando pacotes.
sudo apt install -y $diretorio_downloads/*.deb
unzip $diretorio_downloads/*.zip -d "$diretorio_downloads"
sudo mv $diretorio_downloads/vagrant /usr/local/bin
sudo rm $diretorio_downloads/*.* -f

### Procedimentos e otimizações.
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
#gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
#sudo ln -s /usr/share/hunspell/* ~/.config/VSCodium/Dictionaries
sudo usermod -aG docker $(whoami)

### Instalação de ícones e temas.
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
flatpak --user override com.spotify.Client --filesystem=/home/$USER/.icons/:ro

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

### Finalização e limpeza.
sudo apt autoremove
sudo apt autoclean
sudo rm -rf /var/cache/snapd
sudo rm -rf ~/snap