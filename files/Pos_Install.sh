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
### 		Última edição 18/08/2021. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/commits/master>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### PPA's e links de download dinâmicos.
ppa_celluloid="ppa:xuzhen666/gnome-mpv"
ppa_lutris="ppa:lutris-team/lutris"
url_key_brave="https://brave-browser-apt-release.s3.brave.com/brave-core.asc"
url_ppa_brave="https://brave-browser-apt-release.s3.brave.com/"
url_key_code="https://packages.microsoft.com/keys/microsoft.asc"
url_ppa_code="https://packages.microsoft.com/repos/vscode"
url_ppa_obs="ppa:obsproject/obs-studio"
url_ppa_dbox="https://linux.dropbox.com/ubuntu"
url_dck_key="https://download.docker.com/linux/ubuntu/gpg"
url_ppa_dck="https://download.docker.com/linux/ubuntu"
url_key_only="hkp://keyserver.ubuntu.com:80"
url_ppa_only="https://download.onlyoffice.com/repo/debian"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
# url_backup"https://github.com/ciro-mota/conf-backup.git"


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
	fortune 
	gir1.2-gtop-2.0 
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
	lm-sensors 
	lolcat 
	lutris 
	neofetch 
	obs-studio 
	onlyoffice-desktopeditors 
	qbittorrent 
	terminator 
	ubuntu-restricted-extras 
	vim-runtime  
	zsh)

flatpak=(com.spotify.Client 
	com.valvesoftware.Steam 
	com.valvesoftware.Steam.Utility.MangoHud 
	nl.hjdskes.gcolor3 
	org.gimp.GIMP 
	org.libreoffice.LibreOffice 
	org.remmina.Remmina 
	org.telegram.desktop)

code_extensions=(CoenraadS.bracket-pair-colorizer-2 
	dendron.dendron-markdown-shortcuts 
	eamodio.gitlens
	HashiCorp.terraform
	ms-azuretools.vscode-docker 
	MS-CEINTL.vscode-language-pack-pt-BR
	ms-kubernetes-tools.vscode-kubernetes-tools
	shakram02.bash-beautify 
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
if [[ $(lsb_release -cs) = 'focal' ]] then;
	echo -e "\e[32;1mUbuntu Focal 20.04.2. Prosseguindo com o script...\e[m"
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits.
sudo dpkg --add-architecture i386

### Adicionando repositórios de terceiros.
sudo add-apt-repository "$ppa_celluloid"
sudo add-apt-repository "$ppa_lutris"
sudo add-apt-repository "$url_ppa_obs"

curl -fsSL "$url_dck_key" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_dck $(lsb_release -cs) stable"

curl -fsSL "$url_key_code" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_code stable main"

curl -fsSL "$url_key_brave" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] $url_ppa_brave stable main"

sudo add-apt-repository "deb $url_ppa_dbox $(lsb_release -cs) main"
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E

sudo apt-key adv --keyserver $url_key_only --recv-keys CB2DE8E5
echo "deb $url_ppa_only squeeze main" | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list

### Atualizando sistema após adição de novos repositórios.
sudo apt update && sudo apt upgrade -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
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

### Instalação da lista de apps.
for nome_do_app in ${apps[@]}; do
  if ! dpkg -l | grep -q $nome_do_app; then
    sudo apt install "$nome_do_app" -y
  else
    echo "$nome_do_app ==> [JÁ INSTALADO]"
  fi
done

### Instalação de apps Flatpak.
flatpak remote-add --if-not-exists flathub $url_flathub

for nome_do_flatpak in ${flatpak[@]}; do
  if ! flatpak list | grep -q $nome_do_flatpak; then
    flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Download de programas .deb.
mkdir -p "$diretorio_downloads"
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .deb.
sudo apt install -y $diretorio_downloads/*.deb

### Limpando pasta temporária dos downloads.
sudo rm $diretorio_downloads/*.* -f

### Instalação extensões do Code.
for code_ext in ${code_extensions[@]}; do
    code --install-extension "$code_ext" -y
  fi
done

### Instalação de ícones, temas e configurações.
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

# git clone https://github.com/ciro-mota/conf-backup.git

# mv $HOME/conf-backup/Dracula-Blue $HOME/.themes
# mv $HOME/conf-backup/Yaru-Deepblue-dark $HOME/.themes
# mv $HOME/conf-backup/Flat-Remix-Blue-Dark $HOME/.icons
# mv $HOME/conf-backup/volantes_cursors $HOME/.icons
# mv $HOME/conf-backup/neofetch $HOME/.config/neofetch
# mv $HOME/conf-backup/terminator $HOME/.config/terminator
# mv $HOME/conf-backup/.zsh_aliases $HOME
# mv $HOME/conf-backup/.zshrc $HOME
# mv $HOME/conf-backup/.vim $HOME

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
# gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-Blue'
# gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
# gsettings set org.gnome.desktop.interface cursor-theme 'volantes_cursors'
# gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,close'
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

# ln -s /usr/share/hunspell/* ~/.config/Code/Dictionaries