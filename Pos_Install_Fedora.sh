#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Fedora.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Fedora 36, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 06/09/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Fedora.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Repos e links de download dinâmicos.
url_key_brave="https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
url_repo_brave="https://brave-browser-rpm-release.s3.brave.com/x86_64/"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm"
url_font_config="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/fonts.conf"
url_neofetch="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config.conf"
url_terminator="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config"
url_fantasque="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FantasqueSansMono/Regular/complete/Fantasque%20Sans%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf"

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
	gnome-text-editor 
	gnome-tour 
	libreoffice-* 
	mediawriter 
	PackageKit 
	totem 
	rhythmbox
	virtualbox-guest-additions-*
	yelp)

apps=(android-tools 
	brave-browser 
	codium 
	cowsay 
	ffmpegthumbnailer 
	file-roller 
	flameshot 
	fortune-mod 
	gedit 
	gnome-tweaks 
	google-arimo-fonts 
	google-cousine-fonts 
	google-tinos-fonts 
	heroic-games-launcher-bin 
	hugo 
	lolcat 
	lutris 
	neofetch 
	qemu-system-x86 
	terminator 
	ulauncher 
	unrar-free 
	vim-enhanced 
	vlc 
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
	emmanuelbeziat.vscode-great-icons
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
if [[ $(awk '{print $3}' /etc/fedora-release) = "36" ]]
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
### Tweaks para o dnf.conf
sudo echo -e "fastestmirror=1" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "color=always" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "clean_requirements_on_remove=True" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
sudo echo -e "metadata_expire=7d" | sudo tee -a /etc/dnf/dnf.conf # Você precisará rodar ao menos uma vez por semana o comando: sudo dnf up --refresh

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

sudo dnf copr enable atim/heroic-games-launcher -y

flatpak remote-add --if-not-exists flathub "$url_flathub"

### Atualizando sistema após adição de novos repositórios.
sudo dnf upgrade --refresh -y

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

### Adicionando Virt-Manager
sudo dnf install @virtualization

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

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #

### Procedimentos e otimizações.
sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

if [ -d "$HOME/".config/gtk-4.0 ]
then
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
else
	mkdir -p "$HOME"/.config/gtk-4.0
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
fi

sudo sed -i '/unix_sock_group/s/^#//g' /etc/libvirt/libvirtd.conf
sudo sed -i '/unix_sock_rw_perms/s/^#//g' /etc/libvirt/libvirtd.conf
sudo usermod -a -G libvirt "$(whoami)"
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

sudo systemctl stop abrt-journal-core.service
sudo systemctl stop abrt-oops.service
sudo systemctl stop abrt-xorg.service
sudo systemctl stop abrtd.service
sudo systemctl disable abrt-oops.service
sudo systemctl disable abrt-journal-core.service
sudo systemctl disable abrt-xorg.service
sudo systemctl disable abrtd.service

sudo dnf config-manager --set-disabled rpmfusion-nonfree-steam
sudo dnf config-manager --set-disabled rpmfusion-nonfree-nvidia-driver
sudo dnf config-manager --set-disabled phracek-PyCharm
sudo dnf config-manager --set-disabled updates-modular
sudo dnf config-manager --set-disabled fedora-modular

if [ -d "$HOME/".config/fontconfig ]
then
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
else
	mkdir -p "$HOME"/.config/fontconfig
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
fi

### Instalação de ícones, temas, fonte e configurações básicas.
theme (){

git clone -q https://github.com/daniruiz/flat-remix-gtk.git "$diretorio_downloads"/flat-remix-gtk
cp -r "$diretorio_downloads"/flat-remix-gtk/themes/Flat-Remix-GTK-Blue-Dark-Solid "$HOME"/.themes
cp -r "$diretorio_downloads"/flat-remix-gtk/themes/Flat-Remix-LibAdwaita-Blue-Dark-Solid/*.* "$HOME"/.config/gtk-4.0
gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Blue-Dark-Solid'

}

icon (){

git clone -q https://github.com/daniruiz/flat-remix.git "$diretorio_downloads"/flat-remix
cp -r "$diretorio_downloads"/flat-remix/Flat-Remix-Blue-Dark "$HOME"/.icons
gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'

}

if [ -d "$HOME"/.icons ]
then
  echo -e "Pasta já existe.\n"
  echo -e "Clonando..."
  icon
else
  mkdir -p "$HOME"/.icons
  echo -e "Clonando..."
  icon
fi

if [ -d "$HOME"/.themes ]
then
  echo -e "Pasta já existe.\n"
  echo -e "Clonando..."
  theme
else
  mkdir -p "$HOME"/.themes
  echo -e "Clonando..."
  theme
fi

sudo flatpak --system override --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override --env=GTK_THEME=Flat-Remix-GTK-Blue-Dark-Solid
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

if [ -d "$HOME/".local/share/fonts ]
then
	wget -cq --show-progress "$url_fantasque" -P "$HOME"/.local/share/fonts
	fc-cache -f -v >/dev/null
else
	mkdir -p "$HOME"/.local/share/fonts
	wget -cq --show-progress "$url_fantasque" -P "$HOME"/.local/share/fonts
	fc-cache -f -v >/dev/null
fi

if [ -d "$HOME/".config/neofetch ]
then
	wget -cq --show-progress "$url_neofetch" -P "$HOME"/.config/neofetch
else
	mkdir -p "$HOME"/.config/neofetch
	wget -cq --show-progress "$url_neofetch" -P "$HOME"/.config/neofetch
fi

if [ -d "$HOME/".config/terminator ]
then
	wget -cq --show-progress "$url_terminator" -P "$HOME"/.config/terminator
else
	mkdir -p "$HOME"/.config/neofetch
	wget -cq --show-progress "$url_terminator" -P "$HOME"/.config/terminator
fi

### Finalização e limpeza.
sudo dnf autoremove -y

### Limpando pasta temporária dos downloads.
sudo rm "$diretorio_downloads"/ -rf
