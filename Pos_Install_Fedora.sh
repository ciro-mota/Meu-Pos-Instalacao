#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Fedora.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Fedora 35, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 06/04/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Fedora.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Repos e links de download dinâmicos.
url_key_brave="https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
url_repo_brave="https://brave-browser-rpm-release.s3.brave.com/x86_64/"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm"
# url_backup="https://github.com/ciro-mota/conf-backup.git"

### Programas para instalação e desinstalação.
apps_remover=(cheese 
	gnome-abrt 
	gnome-boxes 
	gnome-clocks 
	gnome-connections 
	gnome-contacts 
	gnome-maps 
	gnome-photos 
	gnome-software 
	gnome-tour 
	libreoffice-*
	mediawriter 
	PackageKit 
	totem 
	rhythmbox
	yelp)	

apps=(android-tools 
	brave-browser 
	celluloid 
	codium 
	chrome-gnome-shell
	containerd.io 
	cowsay 
	ffmpegthumbnailer 
	file-roller
	fortune-mod 
	gnome-tweaks 
	hugo 
	lolcat 
	lutris 
	neofetch 
	pass 
	terminator 
	ulauncher 
	zram-generator 
	zram-generator-defaults 
	zsh)

flatpak=(com.obsproject.Studio 
	com.valvesoftware.Steam  
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
if [[ $(tail /etc/fedora-release | awk '{ print $3 }') = "36" ]]
then
	echo ""
	echo ""
	echo -e "\e[32;1mDistribuição correta. Prosseguindo com o script...\e[m"
	echo ""
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Desinstalando apps desnecessários.
for nome_do_programa in "${apps_remover[@]}"; do
    sudo dnf remove "$nome_do_programa" -y
done

### Adicionando RPM Fusion.
 sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
 https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm -y

### Adicionando repositórios de terceiros.
sudo dnf config-manager --add-repo "$url_repo_brave"
sudo rpm --import "$url_key_brave"

sudo tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

flatpak remote-add --if-not-exists flathub "$url_flathub"

### Atualizando sistema após adição de novos repositórios.
sudo dnf update -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação da lista de apps.
for nome_do_app in "${apps[@]}"; do
  if ! dnf list --installed | grep -q "$nome_do_app"; then
    sudo dnf install "$nome_do_app" -y
  else
    echo "$nome_do_app ==> [JÁ INSTALADO]"
  fi
done

### Ativando suporte multimídia:
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
sudo dnf install lame\* --exclude=lame-devel -y
sudo dnf group upgrade --with-optional Multimedia -y

### Instalação de apps Flatpak.
for nome_do_flatpak in "${flatpak[@]}"; do
  if ! flatpak list | grep -q "$nome_do_flatpak"; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Download de programas .rpm.
mkdir -p "$diretorio_downloads"
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .rpm.
sudo dnf install -y "$diretorio_downloads"/*.rpm

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    codium --install-extension "$code_ext" 2> /dev/null
done

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

### Procedimentos e otimizações.
sudo echo -e "fastestmirror=1" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "max_parallel_downloads=5" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "color=always" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "clean_requirements_on_remove=True" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
echo -e "gtk-hint-font-metrics=1" | sudo tee -a /home/"$(whoami)"/.config/gtk-4.0/settings.ini
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
sudo flatpak --system override org.telegram.desktop --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.valvesoftware.Steam --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override org.onlyoffice.desktopeditors --filesystem="$HOME"/.icons/:ro
sudo gsettings set org.gnome.desktop.default-applications.terminal exec terminator
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false

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

# sudo gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-Blue'
# sudo gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# sudo gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
# sudo gsettings set org.gnome.desktop.interface cursor-theme 'volantes_cursors'

### Finalização e limpeza.
sudo dnf autoremove -y

### Limpando pasta temporária dos downloads.
sudo rm "$diretorio_downloads"/ -rf