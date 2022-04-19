#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Ubuntu versão 22.04. 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 18/04/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de download dinâmicos.
ppa_celluloid="ppa:xuzhen666/gnome-mpv"
ppa_lutris="ppa:lutris-team/lutris"
url_ppa_obs="ppa:obsproject/obs-studio"
url_ppa_ulauncher="ppa:agornostal/ulauncher"
url_key_brave="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
url_ppa_brave="https://brave-browser-apt-release.s3.brave.com/"
url_dck_key="https://download.docker.com/linux/ubuntu/gpg"
url_ppa_dck="https://download.docker.com/linux/ubuntu"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
url_code="https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs"
url_key_code="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
url_firefox="https://ftp.mozilla.org/pub/firefox/releases/99.0/linux-x86_64/pt-BR/firefox-99.0.tar.bz2"
# url_backup="https://github.com/ciro-mota/conf-backup.git"

### Programas para instalação e desinstalação.
apps_remover=(popularity-contest 
	snapd)		

apps=(brave-browser 
	chrome-gnome-shell
	cowsay 
	docker-ce 
	exfat-fuse 
	fastboot 
	ffmpegthumbnailer 
	fonts-fantasque-sans 
	fortune 
	gir1.2-gtop-2.0 
	gnome-mpv 
	gnome-shell-extensions 
	gufw 
	hugo 
	libavcodec-extra 
	libvulkan1:i386 
	libgnutls30:i386 
	libgpg-error0:i386 
	libasound2-plugins:i386 
	libfreetype6:i386 
	lolcat 
	lutris 
	neofetch 
	obs-studio 
	terminator 
	ubuntu-restricted-addons 
	ulauncher 
	vim-runtime  
	zsh)

flatpak=(com.valvesoftware.Steam 	
	nl.hjdskes.gcolor3 
	org.freedesktop.Platform.VulkanLayer.MangoHud 
	org.gimp.GIMP 
	org.ksnip.ksnip 
	org.libreoffice.LibreOffice 
	org.qbittorrent.qBittorrent 
	org.remmina.Remmina 
	org.telegram.desktop)

code_extensions=(dendron.dendron-markdown-shortcuts 
	eamodio.gitlens
	foxundermoon.shell-format
	HashiCorp.terraform
	ritwickdey.LiveServer
	ms-azuretools.vscode-docker 
	MS-CEINTL.vscode-language-pack-pt-BR
	ms-kubernetes-tools.vscode-kubernetes-tools
	Shan.code-settings-sync 
	snyk-security.vscode-vuln-cost 
	streetsidesoftware.code-spell-checker 
	streetsidesoftware.code-spell-checker-portuguese-brazilian 
	timonwong.shellcheck 
	zhuangtongfa.Material-theme)	

diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(lsb_release -cs) = 'jammy' ]] 
then
	echo ""
	echo ""
	echo -e "\e[32;1mUbuntu Jammy 22.04. Prosseguindo com o script...\e[m"
	echo ""
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Mudança para o mirror global
sudo sed -i 's/http:\/\/br./http:\/\//g' /etc/apt/sources.list

### Desinstalando apps desnecessários.
for nome_do_programa in "${apps_remover[@]}"; do
    sudo apt purge "$nome_do_programa" -y
done

### Adicionando/Confirmando arquitetura de 32 bits.
sudo dpkg --add-architecture i386

### Instalando requerimentos. ###
sudo apt install \
    apt-transport-https \
    curl \
	git \
	flatpak -y

### Adicionando repositórios de terceiros.
sudo add-apt-repository "$ppa_celluloid" -y
sudo add-apt-repository "$ppa_lutris" -y
sudo add-apt-repository "$url_ppa_obs" -y
sudo add-apt-repository "$url_ppa_ulauncher" -y

curl -fsSL "$url_dck_key" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $url_ppa_dck \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg "$url_key_brave"
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] \
	$url_ppa_brave stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null  

wget -qO - $url_key_code | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] '$url_code' vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

### Atualizando sistema após adição de novos repositórios.
sudo apt update && sudo apt upgrade -y

### Instalação do repo Flatpak.
flatpak remote-add --if-not-exists flathub $url_flathub

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação da lista de apps.
for nome_do_app in "${apps[@]}"; do
  if ! dpkg -l | grep -q "$nome_do_app"; then
    sudo apt install "$nome_do_app" -y
  else
    echo "$nome_do_app ==> [JÁ INSTALADO]"
  fi
done

for nome_do_flatpak in "${flatpak[@]}"; do
  if ! flatpak list | grep -q "$nome_do_flatpak"; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Download de programas .deb.
mkdir -p "$diretorio_downloads"
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .deb.
sudo apt install -y "$diretorio_downloads"/*.deb

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    codium --install-extension "$code_ext" 2> /dev/null
done

### Instalação do Firefox Release não Snap.
wget -cq --show-progress "$url_firefox"   -P "$diretorio_downloads"
sudo tar xjf "$diretorio_downloads"/firefox*.bz2 -C /opt
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
sudo chown -R "$(whoami)":"$(whoami)" /opt/firefox*

sudo sh -c 'cat <<EOF > /home/$(id -nu 1000)/.local/share/applications/firefox-stable.desktop
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF'

sudo chown "$(whoami)":"$(whoami)" "$HOME"/.local/share/applications/firefox-stable.desktop

### Instalação de ícones, temas e configurações.
# if [ -d "$HOME"/.icons ]
# then
#   echo "Pasta já existe."
# else
#   mkdir -p "$HOME"/.icons
# fi

# if [ -d "$HOME"/.themes ]
# then
#   echo "Pasta já existe."
# else
#   mkdir -p "$HOME"/.themes
# fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Ativando ZRAM.
sudo echo -e "zram" | sudo tee -a /etc/modules-load.d/zram.conf
sudo echo -e "options zram num_devices=1" | sudo tee -a  /etc/modprobe.d/zram.conf
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
sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
echo -e "gtk-hint-font-metrics=1" | sudo tee -a /home/"$(whoami)"/.config/gtk-4.0/settings.ini
sudo usermod -aG docker "$(whoami)"
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
sudo flatpak --system override org.telegram.desktop --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.valvesoftware.Steam --filesystem="$HOME"/.icons/:ro
sudo systemctl stop packagekit
sudo systemctl disable packagekit
sudo systemctl mask packagekit

### Bloco de personalizações pessoais.
# wget -cq --show-progress "$url_fantasque" -P "$diretorio_downloads"
# mkdir -p .local/share/fonts
# mv *.ttf ~/.local/share/fonts/
# fc-cache -f -v >/dev/null

# git clone "$url_backup"

# cp -r $HOME/conf-backup/Dracula-Blue $HOME/.themes
# cp -r $HOME/conf-backup/Yaru-Deepblue-dark $HOME/.themes
# cp -r $HOME/conf-backup/Flat-Remix-Blue-Dark $HOME/.icons
# cp -r $HOME/conf-backup/volantes_cursors $HOME/.icons
# cp -r $HOME/conf-backup/neofetch $HOME/.config/neofetch
# cp -r $HOME/conf-backup/terminator $HOME/.config/terminator
# cp -r $HOME/conf-backup/.zsh_aliases $HOME
# cp -r $HOME/conf-backup/.zshrc $HOME
# cp -r $HOME/conf-backup/.vim $HOME

# gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-Blue'
# gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
# gsettings set org.gnome.desktop.interface cursor-theme 'volantes_cursors'

### Finalização e limpeza.
sudo apt autoremove
sudo apt autoclean
sudo rm -rf /var/cache/snapd
sudo rm -rf ~/snap

### Limpando pasta temporária dos downloads.
sudo rm "$diretorio_downloads"/ -rf