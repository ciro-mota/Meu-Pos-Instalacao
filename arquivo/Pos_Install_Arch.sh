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
### 		Última edição 11/05/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Arch.sh".


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_font_config="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/assets/fonts.conf"
# url_backup="https://github.com/ciro-mota/conf-backup.git"


### Programas para instalação e desinstalação.

apps=(amd-ucode 
	android-tools 
	baobab 
	celluloid 
	chromium 
	containerd 
	cowsay 
	curl 
	docker 
	dialog 
	docker-compose 
	eog 
	evince 
	exfat-utils 
	ttf-fantasque-sans-mono 
	ffmpegthumbnailer 
	file-roller 
	firefox 
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
	gnome-tweak-tool
	gparted 
	gsfonts 
	gst-libav 
	gtk2 
	gstreamer-vaapi 
	gufw 
	haskell-gnutls 
	hplip 
	hugo 
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
	qbittorrent 
	reflector
	sdl_image 
	seahorse 
	simplescreenrecorder 
	systemd-swap 
	terminator 
	ttf-caladea 
	ttf-dejavu 
	ttf-liberation 
	ttf-opensans 
	ttf-roboto 
	ttf-ubuntu-font-family 
	vdpauinfo 
	vim 
	vulkan-radeon 
	vulkan-tools 
	wget 
	wine 
	xf86-video-amdgpu 
	zsh)

apps_do_aur=(brave-bin 
	dropbox 
	heroic-games-launcher-bin 
	plymouth 
	teamviewer 
	ulauncher 
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
echo -e "gtk-hint-font-metrics=1" | tee -a /home/"$(whoami)"/.config/gtk-4.0/settings.ini

if [ -d "$HOME/".config/fontconfig ]
then
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
else
	mkdir -p "$HOME"/.config/fontconfig
	wget -cq --show-progress "$url_font_config" -P "$HOME"/.config/fontconfig
fi

sudo usermod -aG docker "$(whoami)"
sudo usermod -aG lp "$(whoami)"
sudo groupadd gamemode
sudo usermod -aG gamemode "$(whoami)"
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable reflector
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
sudo gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
sudo flatpak --system override --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override --env=MANGOHUD=1 com.valvesoftware.Steam
sudo gsettings set org.gnome.desktop.default-applications.terminal exec terminator

### Aplicando Plymouth
sudo sed -i 's/fsck)/fsck plymouth shutdown)/g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo plymouth-set-default-theme -R bgrt
sudo grub-mkconfig -o /boot/grub/grub.cfg

### Bloco de personalizações pessoais.
# mkdir -p "$diretorio_downloads"

# wget -cq --show-progress "$url_fantasque" -P "$diretorio_downloads"
# mkdir -p .local/share/fonts
# mv *.ttf ~/.local/share/fonts/
# fc-cache -f -v >/dev/null

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
sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm
sudo snapper -c root create-config /
