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
### 		Última edição 27/09/2023. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Arch.sh".


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_neofetch="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/dots/config.conf"
url_terminator="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/dots/config"

### Programas para instalação e desinstalação.

apps=(amd-ucode 
	android-tools 
	baobab 
	containerd 
	cowsay 
	cups 
	curl 
	dialog 
	dnsmasq 
	docker 
	docker-compose 
	edk2-ovmf 
	eog 
	evince 
	exfat-utils 
	ttf-fantasque-nerd 
	ffmpeg 
	ffmpegthumbnailer 
	file-roller 
	firefox 
	firefox-i18n-pt-br 
	flameshot 
	flatpak 
	font-manager 
	fortune-mod 
	gamemode 
	gedit 
	gimp 
	gnome-calculator 
	gnome-calendar 
	gnome-characters 
	gnome-disk-utility 
	gnome-firmware 
	gnome-icon-theme-symbolic 
	gnome-keyring 
	gnome-logs 
	gnome-system-monitor 
	gnome-tweaks
	gnome-weather 
	gparted 
	gsfonts 
	gst-libav 
	gst-plugins-bad 
	gst-plugins-base 
	gst-plugins-good 
	gst-plugins-ugly 
	gtk2 
	gstreamer 
	gstreamer-vaapi 
	gvfs-smb 
	gufw 
	haskell-gnutls 
	hplip 
	hugo 
	kernel-modules-hook 
	ksnip 
	lame 
	libva-mesa-driver 
	libva-utils 
	lib32-gamemode 
	lib32-vulkan-icd-loader 
	lib32-vulkan-radeon 
	libmpeg2 
	libreoffice-fresh-pt-br 
	lolcat 
	lutris 
	mesa-vdpau 
	micro 
	neofetch 
	noto-fonts 
	noto-fonts-cjk 
	noto-fonts-extra 
	qbittorrent 
	qemu-full 
	reflector 
	remmina 
	sdl_image 
	seahorse 
	simplescreenrecorder 
	snap-pac 
	steam 
	system-config-printer 
	systemd-swap 
	telegram-desktop 
	terminator 
	terraform 
	texlive-latexrecommended 
	traceroute 
	ttf-caladea 
	ttf-croscore 
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
	gradience 
	goverlay-bin 
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
	
flatpak=(nl.hjdskes.gcolor3
	org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark)

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
if [[ -f /etc/arch-release ]]
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
    yay -S "$nome_do_aur" --noconfirm
done

### Instalação de Flatpaks.
flatpak remote-add --if-not-exists flathub "$url_flathub"

for nome_do_flatpak in "${flatpak[@]}"; do
    sudo flatpak install --system "$nome_do_flatpak" -y
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    codium --install-extension "$code_ext" 2> /dev/null
done

### Instalação do Node.
nvm install "$(nvm ls-remote | grep "Latest LTS" | grep v18 | awk '{ print $1 }')"

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #

### Ativando ZRAM.
### github.com/Nefelim4ag/systemd-swap
sudo sed -i "s/zram_enabled=0/zram_enabled=1/g" /usr/share/systemd-swap/swap-default.conf
sudo systemctl enable --now systemd-swap

### Melhorias de performance.
### wiki.archlinux.org/title/improving_performance#Changing_I/O_scheduler

sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules << 'EOF'
# HDD
ACTION=="add|change", KERNEL=="sdb", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

# SSD
ACTION=="add|change", KERNEL=="sda", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
EOF

### Correções de fontes.
### discussion.fedoraproject.org/t/fonts-in-gtk-4-apps-look-different-more-blurry/66778

if [ -d "$HOME/".config/gtk-4.0 ]
then
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
else
	mkdir -p "$HOME"/.config/gtk-4.0
	echo -e "gtk-hint-font-metrics=1" | tee -a "$HOME/".config/gtk-4.0/settings.ini
fi

### wiki.manjaro.org/index.php/Improve_Font_Rendering

sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sudo sed -i 's/#export/export/g' /etc/profile.d/freetype2.sh

sudo tee -a /etc/fonts/local.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="rgba">
      <const>rgb</const>
    </edit>
    <edit mode="assign" name="hintstyle">
      <const>hintslight</const>
    </edit>
    <edit mode="assign" name="lcdfilter">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
EOF

sudo tee -a "$HOME"/.Xresources << 'EOF'
Xft.antialias: 1
Xft.hinting: 1
Xft.rgba: rgb
Xft.hintstyle: hintslight
Xft.lcdfilter: lcddefault
EOF

xrdb -merge ~/.Xresources
sudo fc-cache -fv 

### Configurando para uso de Swap/ZRAM.
### wiki.archlinux.org/title/sysctl#Virtual_memory
sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.dirty_ratio=6" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.dirty_background_ratio=6" | sudo tee -a /etc/sysctl.conf
### wiki.archlinux.org/title/gaming#Game_environments
sudo echo -e "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.d/80-gamecompatibility.conf

### Melhorias do Pacman.
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
sudo sed -i '/#VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf

### Mirror de downloads das atualizações.
### wiki.archlinux.org/title/reflector
sudo sed -i "s/France,Germany/'United States',Brazil/g" /etc/xdg/reflector/reflector.conf
sudo sed -i 's/--sort age/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector
sudo systemctl start reflector
sudo systemctl enable reflector.timer
sudo systemctl start reflector.service

### Ativando o Docker.
sudo usermod -aG docker "$(whoami)"
sudo systemctl enable docker
sudo systemctl start docker

### Configuração da extensão/app Gamemode.
wget -q https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini -O /home/"$(id -nu 1000)"/.config/gamemode.ini
sudo groupadd gamemode

### Adição do usuário a alguns grupos.
sudo usermod -aG lp "$(whoami)"
sudo usermod -aG gamemode "$(whoami)"
sudo usermod -a -G libvirt "$(whoami)"

### Ativando serviço do CUPS.
sudo systemctl enable cups.service
sudo systemctl start cups.service

### Ativando o comando Trim.
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

### Ativando trim do Snapper.
sudo systemctl enable snapper-cleanup.timer
sudo systemctl start snapper-cleanup.timer

### Configurações do QEMU.
sudo sed -i '/unix_sock_group/s/^#//g' /etc/libvirt/libvirtd.conf
sudo sed -i '/unix_sock_rw_perms/s/^#//g' /etc/libvirt/libvirtd.conf
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo virsh net-start default

### Aplicando Plymouth
### wiki.archlinux.org/title/plymouth
sudo sed -i 's/fsck)/fsck plymouth)/g' /etc/mkinitcpio.conf
sudo plymouth-set-default-theme -R arch-charge-big
sudo mkinitcpio -p linux

### Instalação de ícones, temas, fonte e configurações básicas.
theme (){

curl -s https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest | grep "browser_download_url.*tar.xz" | \
cut -d : -f 2,3 | tr -d \" | \
wget -P "$diretorio_downloads" -i-
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

sudo flatpak override --system --filesystem=/usr/share/icons/:ro
sudo flatpak override --system --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --system --env=XCURSOR_PATH=/run/host/user-share/icons:/run/host/share/icons
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.default-applications.terminal exec terminator
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
xdg-mime default org.gnome.Nautilus.desktop inode/directory 

### Finalização e limpeza.
sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm
sudo rm "$diretorio_downloads"/ -rf
sudo snapper -c root create-config /
