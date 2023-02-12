#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota
## NOME:
### 	Pos_Install_Arch.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Arch, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 12/02/2023. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Arch.sh".


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_font_config="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/fonts.conf"
url_neofetch="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config.conf"
url_terminator="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config"

### Programas para instalação e desinstalação.

apps=(amd-ucode 
	android-tools 
	baobab 
	containerd 
	cowsay 
	curl 
	dialog 
	docker-compose 
	edk2-ovmf 
	eog 
	evince 
	exfat-utils 
	ttf-fantasque-sans-mono 
	ffmpegthumbnailer 
	file-roller 
	firefox 
	flameshot 
	flatpak 
	font-manager 
	fortune-mod 
	gamemode 
	gedit 
	gimp 
	gnome-calculator 
	gnome-characters 
	gnome-icon-theme-symbolic 
	gnome-keyring 
	gnome-logs 
	gnome-system-monitor 
	gnome-tweaks
	gparted 
	gsfonts 
	gst-libav 
	gtk2 
	gstreamer 
	gstreamer-vaapi 
	gufw 
	haskell-gnutls 
	hplip 
	hugo 
	kernel-modules-hook 
	ksnip 
	lame 
	libva-mesa-driver 
	lib32-gamemode 
	lib32-vulkan-icd-loader 
	lib32-vulkan-radeon 
	libmpeg2 
	libreoffice-fresh-pt-br 
	lolcat 
	lutris 
	mesa-vdpau 
	neofetch 
	noto-fonts 
	pass 
	podman 
	qbittorrent 
	qemu-kvm 
	qemu-system-x86 
	reflector 
	remmina 
	sdl_image 
	seahorse 
	simplescreenrecorder 
	snap-pac 
	steam 
	systemd-swap 
	telegram-desktop 
	terminator 
	ttf-caladea 
	ttf-dejavu 
	ttf-liberation 
	ttf-roboto 
	ttf-ubuntu-font-family 
	vdpauinfo 
	vim 
 	virt-manager 
	vlc 
	vulkan-radeon 
	vulkan-tools 
	wget 
	xdg-user-dirs
	xf86-video-amdgpu 
	zsh)

apps_do_aur=(brave-bin 
	gnome-browser-connector 
	heroic-games-launcher-bin 
	lib32-mangohud-git 
	mangohud-git 
	plymouth 
	plymouth-theme-arch-charge-big 
	systemd-boot-pacman-hook 
	teamviewer 
	ulauncher 
	unrar-free 
	vscodium-bin)
	
flatpak=(com.github.GradienceTeam.Gradience 
	nl.hjdskes.gcolor3)

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
if [[ $(tail /etc/arch-release) = "" ]]
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
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #

### Instalação de programas.
for nome_do_app in "${apps[@]}"; do
    sudo pacman -S "$nome_do_app"  --noconfirm
done

### Instalação de programas do AUR.
for nome_do_aur in "${apps_do_aur[@]}"; do
    paru -S "$nome_do_aur" --noconfirm
done

### Instalação de Flatpaks.
flatpak remote-add --if-not-exists flathub "$url_flathub"

for nome_do_flatpak in "${flatpak[@]}"; do
    sudo flatpak install --system "$nome_do_flatpak" -y
done

### Instalação do Jopplin
wget -O - $url_jopplin | bash

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    codium --install-extension "$code_ext" 2> /dev/null
done

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #

### Ativando ZRAM.
sudo sed -i "s/zram_enabled=0/zram_enabled=1/g" /usr/share/systemd-swap/swap-default.conf
sudo systemctl enable --now systemd-swap

### Procedimentos e otimizações.
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
sudo sed -i '/#VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf

sudo sed -i "s/France,Germany/'United States',Brazil/g" /etc/xdg/reflector/reflector.conf
sudo sed -i 's/--sort age/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector
sudo systemctl start reflector
sudo systemctl enable reflector.timer
sudo systemctl start reflector.service

sudo usermod --add-subuids 10000-75535 "$(whoami)"
sudo usermod --add-subgids 10000-75535 "$(whoami)"

wget -q https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini -O /home/"$(id -nu 1000)"/.config/gamemode.ini

sudo sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

if [ -d "$HOME/".config/gtk-4.0 ]
then
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
else
	mkdir -p "$HOME"/.config/gtk-4.0
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
fi

if [ -d "$HOME/".config/fontconfig ]
then
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
else
	mkdir -p "$HOME"/.config/fontconfig
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
fi

sudo usermod -aG lp "$(whoami)"
sudo groupadd gamemode
sudo usermod -aG gamemode "$(whoami)"
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

sudo sed -i '/unix_sock_group/s/^#//g' /etc/libvirt/libvirtd.conf
sudo sed -i '/unix_sock_rw_perms/s/^#//g' /etc/libvirt/libvirtd.conf
sudo usermod -a -G libvirt "$(whoami)"
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

### Aplicando Plymouth
sudo sed -i 's/fsck)/fsck plymouth shutdown)/g' /etc/mkinitcpio.conf
sudo plymouth-set-default-theme -R arch-charge-big
sudo mkinitcpio -p linux

### Instalação de ícones, temas, fonte e configurações básicas.
theme (){

curl -s https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest | grep "browser_download_url.*tar.xz" | \
cut -d : -f 2,3 | tr -d \" | \
wget -P "$diretorio_downloads" -i - | \
tar xf "$diretorio_downloads"/*.tar.xz -C "$HOME"/.local/share/themes

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

}

icon (){

wget -cqO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.local/share/icons" sh
wget -cqO- https://git.io/papirus-folders-install | sh
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
papirus-folders -C bluegrey --theme Papirus
rm "$HOME"/.local/share/icons/ePapirus-Dark -rf
rm "$HOME"/.local/share/icons/ePapirus -rf
rm "$HOME"/.local/share/icons/Papirus-Dark -rf
rm "$HOME"/.local/share/icons/Papirus-Light -rf

}

if [ -d "$HOME"/.local/share/icons ]
then
  echo -e "Pasta já existe.\n"
  echo -e "Instalando..."
  icon
else
  mkdir -p "$HOME"/.local/share/icons
  echo -e "Instalando..."
  icon
fi

if [ -d "$HOME"/.local/share/themes ]
then
  echo -e "Pasta já existe.\n"
  echo -e "Instalando..."
  theme
else
  mkdir -p "$HOME"/.local/share/themes
  echo -e "Instalando..."
  theme
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

sudo flatpak --system override --filesystem="$HOME"/.local/share/icons:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.default-applications.terminal exec terminator
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"

### Finalização e limpeza.
sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm
sudo rm "$diretorio_downloads"/ -rf
sudo snapper -c root create-config /
