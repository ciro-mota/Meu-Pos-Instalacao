#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Debian.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Debian Testing, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 28/02/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Debian.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de download dinâmicos.
url_lutris="http://download.opensuse.org/repositories/home:/strycore/Debian_10/"
url_ppa_lutris="https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key"
url_key_brave="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
url_ppa_brave="https://brave-browser-apt-release.s3.brave.com/"
url_dck_key="https://download.docker.com/linux/debian/gpg"
url_ppa_dck="https://download.docker.com/linux/debian"
url_key_only="hkp://keyserver.ubuntu.com:80"
url_ppa_only="https://download.onlyoffice.com/repo/debian"
url_ppa_ulauncher="ppa:agornostal/ulauncher"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_dbox="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
url_code="https://az764295.vo.msecnd.net/stable/d6ee99e4c045a6716e5c653d7da8e9ae6f5a8b03/code_1.64.1-1644255817_amd64.deb"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
url_firefox="https://ftp.mozilla.org/pub/firefox/releases/97.0/linux-x86_64/pt-BR/firefox-97.0.tar.bz2"

### Programas para instalação.
apps=(brave-browser 
	celluloid 
	containerd.io 
	cowsay 
	cups-pk-helper 
	default-jre 
	docker-ce 
	exfat-fuse 
	fastboot 
	ffmpegthumbnailer 
	file-roller 	
	firmware-linux-nonfree 
	font-manager 
	fortune 
	gir1.2-gtop-2.0 
	gnome-tweaks 
	gstreamer1.0-libav 
	gstreamer1.0-plugins-ugly 
	gstreamer1.0-vaapi 
	gufw 
	hplip 
	hugo 
	libavcodec-extra 
	libgnutls30:i386 
	libldap-2.4-2:i386 
	libgpg-error0:i386 
	libxml2:i386 
	libasound2-plugins:i386 
	libsdl2-2.0-0:i386 
	libsqlite3-0:i386 
	lolcat
	lutris 
	neofetch 
	neovim 
	network-manager-gnome 
	plymouth 
	plymouth-themes 
	obs-studio 
	onlyoffice-desktopeditors 
	openprinting-ppds 
	pass 
	printer-driver-hpcups 
	printer-driver-pxljr 
	seahorse  
	terminator 
	ulauncher 
	zsh)
	
flatpak=(com.spotify.Client 
	com.valvesoftware.Steam  
	nl.hjdskes.gcolor3 
	org.freedesktop.Platform.VulkanLayer.MangoHud 
	org.gimp.GIMP 
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
if [[ $(lsb_release -cs) = "bookworm" ]]
then
	echo ""
	echo ""
	echo -e "\e[32;1mDistribuição Debian Testing. Prosseguindo com o script...\e[m"
	echo ""
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

### Check se há conexão com à internet.
if ping -q -c 1 -W 1 1.1.1.1 >/dev/null;
then
  	echo ""
	echo ""
	echo -e "\e[32;1mConexão com à internet OK. Prosseguindo com o script...\e[m"
	echo ""
	echo ""
else
  	echo -e "\e[31;1mVocê não está conectado à internet. Verifique sua conexão de rede ou wi-fi antes de prosseguir.\e[m"
	exit 1
fi


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------- ATIVANDO CONTRIB E NON-FREE ------------------------------------------ #
sudo sed -i 's/#.*$//;/^$/d' /etc/apt/sources.list
sudo sed -i '/deb-src/d' /etc/apt/sources.list
sudo sed -i 's/bullseye/testing/g' /etc/apt/sources.list
sudo sed -i 's/main/main non-free contrib/g' /etc/apt/sources.list
sudo apt update -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits.
sudo dpkg --add-architecture i386

### Instalando requerimentos. ###
sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
	git \
    gnupg-agent \
    software-properties-common -y

### Adicionando repositórios de terceiros.
echo "deb $url_lutris ./" | sudo tee /etc/apt/sources.list.d/lutris.list
wget -qc "$url_ppa_lutris" -O- | sudo apt-key add -

curl -fsSL "$url_dck_key" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $url_ppa_dck \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg "$url_key_brave"
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] \
	$url_ppa_brave stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

sudo apt-key adv --keyserver $url_key_only --recv-keys CB2DE8E5
echo "deb $url_ppa_only squeeze main" | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list

sudo add-apt-repository "$url_ppa_ulauncher" -y

### Atualizando listas e sistema após adição de novos repositórios.
sudo apt update -y && sudo apt upgrade -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação do ambiente gráfico minimo.
sudo apt install gnome-core \
		xorg \
		gdm3 \
		gnome-software-plugin-flatpak --no-install-recommends -y

### Instalação de programas.
for nome_do_app in "${apps[@]}"; do
  if ! dpkg -l | grep -q "$nome_do_app"; then
    sudo apt install "$nome_do_app" -y
  else
    echo "[INSTALADO] - $nome_do_app"
  fi
done

### Instalação de pacotes Flatpak.
flatpak remote-add --if-not-exists flathub $url_flathub

for nome_do_flatpak in "${flatpak[@]}"; do
  if ! flatpak list | grep -q "$nome_do_flatpak"; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin
wget -O - $url_jopplin | bash

### Download de programas .deb.
mkdir -p "$diretorio_downloads"
wget -cq --show-progress "$url_code" 	-P "$diretorio_downloads"
wget -cq --show-progress "$url_dbox"    -P "$diretorio_downloads"
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .deb.
sudo apt install -y "$diretorio_downloads"/*.deb

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    code --install-extension "$code_ext" 2> /dev/null
done

### Instalação do Firefox Release.
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

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Ativando ZRAM 
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
sudo apt purge totem -y
sudo apt purge gnome-software -y
sudo apt purge firefox-esr -y
sudo apt autoremove
sudo apt autoclean

### Limpando pasta temporária dos downloads.
sudo rm "$diretorio_downloads"/*.* -f

### Reiniciará o PC ou encerrará a execução do script.
echo -e "Digite S para reiniciar, ou N para sair do Script:"
read -r reinicia

case $reinicia in
    S|s)
    	sudo shutdown -r now
		;;
    N|n)
    	exit 0
		;;
esac

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------- PÓS-REBOOT ----------------------------------------------- #
### Segundo script que deverá ser executado após o reboot e carregamento do ambiente gráfico.
### Copie, descomente e salve em um novo arquivo .sh.

### #!/usr/bin/env bash

### Instalação de ícones, temas, fonte e configurações pessoais. Remova este trecho e pule para a próxima seção.
# if [ -d $HOME/.icons ]
# then
#   echo "Pasta já existe."
# else
#   mkdir -p $HOME/.icons
# fi

# if [ -d $HOME/.themes ]
# then
#   echo "Pasta já existe."
# else
#   mkdir -p $HOME/.themes
# fi

# wget -O Fantasque_Sans_Mono_Regular_Nerd_Font_Complete.ttf -cq --show-progress "https://git.io/JX8Ed" -P "$diretorio_downloads"
# mkdir -p .local/share/fonts
# mv *.ttf ~/.local/share/fonts/
# fc-cache -f -v >/dev/null

# git clone https://github.com/ciro-mota/conf-backup.git

# cp -r $HOME/conf-backup/Dracula-Blue $HOME/.themes
# cp -r $HOME/conf-backup/Yaru-Deepblue-dark $HOME/.themes
# cp -r $HOME/conf-backup/Flat-Remix-Blue-Dark $HOME/.icons
# cp -r $HOME/conf-backup/volantes_cursors cp -r $HOME/.icons
# cp -r $HOME/conf-backup/neofetch/config.conf $HOME/.config/neofetch
# cp -r $HOME/conf-backup/terminator $HOME/.config/terminator
# cp -r $HOME/conf-backup/.zsh_aliases $HOME
# cp -r $HOME/conf-backup/.zshrc $HOME
# cp -r $HOME/conf-backup/.vim $HOME

# gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-Blue'
# gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
# gsettings set org.gnome.desktop.interface cursor-theme 'volantes_cursors'
# gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,close'

### Procedimentos e otimizações.
# sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
# sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
# sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
# sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
# sudo mv /etc/network/interfaces /etc/network/interfaces.old
# sudo usermod -aG docker $(whoami)
# sudo usermod -aG lp $(whoami)
# sudo usermod -aG lpadmin $(whoami)
# sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
# sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
# sudo update-grub
# sudo sed -i 's/logo-text-version-64.png/logo-text-64.png/g' /etc/gdm3/greeter.dconf-defaults
# sudo dpkg-reconfigure gdm3
# sudo flatpak --system override org.telegram.desktop --filesystem="$HOME"/.icons/:ro
# sudo flatpak --system override com.spotify.Client --filesystem="$HOME"/.icons/:ro
# sudo flatpak --system override com.valvesoftware.Steam --filesystem="$HOME"/.icons/:ro
# sudo dpkg-reconfigure gdm3
# sudo systemctl stop packagekit
# sudo systemctl disable packagekit