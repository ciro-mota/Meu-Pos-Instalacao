#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Arch.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Arch, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 06/09/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Arch.sh".


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_font_config="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/fonts.conf"
url_neofetch="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config.conf"
url_terminator="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/downloads/config"

### Programas para instalação e desinstalação.

apps=(amd-ucode 
	android-tools 
	baobab 
	chromium 
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
	lame 
	libva-mesa-driver 
	lib32-gamemode 
	lib32-vulkan-icd-loader 
	lib32-vulkan-radeon 
	libmpeg2 
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
	sdl_image 
	seahorse 
	simplescreenrecorder 
	systemd-swap 
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
	heroic-games-launcher-bin 
	plymouth 
	systemd-boot-pacman-hook 
	teamviewer 
	ulauncher 
	unrar-free 
	vscodium-bin)
	
flatpak=(com.obsproject.Studio
	com.valvesoftware.Steam 
	nl.hjdskes.gcolor3 
	org.freedesktop.Platform.VulkanLayer.MangoHud 
	org.gimp.GIMP 
	org.ksnip.ksnip 
	org.libreoffice.LibreOffice 
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
sudo sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

wget -q https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini -O /home/"$(id -nu 1000)"/.config/gamemode.ini

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
sudo systemctl enable reflector
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

sudo sed -i '/unix_sock_group/s/^#//g' /etc/libvirt/libvirtd.conf
sudo sed -i '/unix_sock_rw_perms/s/^#//g' /etc/libvirt/libvirtd.conf
sudo usermod -a -G libvirt "$(whoami)"
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

### Aplicando Plymouth
sudo sed -i 's/fsck)/fsck plymouth shutdown)/g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo plymouth-set-default-theme -R bgrt
sudo grub-mkconfig -o /boot/grub/grub.cfg

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

sudo flatpak --system override --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override --env=GTK_THEME=Flat-Remix-GTK-Blue-Dark-Solid
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.default-applications.terminal exec terminator
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
sudo flatpak --system override --env=MANGOHUD=1 com.valvesoftware.Steam

### Finalização e limpeza.
sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm
sudo rm "$diretorio_downloads"/ -rf
sudo snapper -c root create-config /
