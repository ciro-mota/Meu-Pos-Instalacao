#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Manjaro.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Manjaro, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 28/02/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Arch.sh".
### ESTE SCRIPT AINDA ENCONTRA-SE EM FASE DE TESTES E NÃO DEVE SER UTILIZADO PARA PRODUÇÃO.


# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
# url_backup="https://github.com/ciro-mota/conf-backup.git"
# url_fantasque="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FantasqueSansMono/Regular/complete/Fantasque%20Sans%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"


### Programas para instalação e desinstalação.

apps=(amd-ucode 
	btrfs-progs 
	celluloid 
	chromium 
	containerd 
	cowsay 
	dialog 
	docker 
	docker-compose 
	efibootmgr 
	dosfstools 
	eog 
	evince 
	exfat-utils 
	ffmpegthumbnailer 
	file-roller 
	flatpak 
	font-manager 
	fortune-mod 
	gdm 
	gedit 
	gnome-calculator 
	gnome-characters 
	gnome-icon-theme-symbolic 
	gnome-keyring 
	gnome-control-center 
	gnome-shell 
	gnome-system-monitor 
	gnome-terminal 
	gnome-tweak-tool 
	grub 
	gufw 
	hplip 
	hugo 
	jre-openjdk 
	libpamac-flatpak-plugin 
	lolcat 
	lutris 
	mtools 
	nautilus 
	neofetch 
	neovim 
	networkmanager 
	network-manager-applet 
	os-prober 
	pass 
	qbittorrent 
	seahorse 
	systemd-swap 
	terminator 
	wireless_tools 
	wpa_supplicant 
	xdg-user-dirs 
	xf86-video-amdgpu 
	xorg  
	zsh)

apps_do_aur=(brave-bin 
	dropbox 
	teamviewer 
	ulauncher 
	xiaomi-adb-fastboot-tools 
	vscodium-bin)  
	
flatpak=(com.obsproject.Studio
	com.spotify.Client 
	com.valvesoftware.Steam 
	com.valvesoftware.Steam.Utility.MangoHud 
	nl.hjdskes.gcolor3 
	org.gimp.GIMP 
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

# diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(cat /etc/arch-release) = "" ]]
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
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando repositório Multilib e atualizando listas.
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo pacman -Sy

### Instalando yay AUR Helper.
sudo pacman -S --needed base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git && cd yay/ && makepkg -sri

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #

### Configurando parâmetros.
echo "k6-2-500" >> nano /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.0.1	k6-2-500.localdomain	k6-2-500
EOF

### Instalação de programas.
for nome_do_app in "${apps[@]}"; do
    sudo pacman -S "$nome_do_app"  --noconfirm
done

### Instalação de programas do AUR.
for nome_do_aur in "${apps_do_aur[@]}"; do
    sudo yay -S "$nome_do_aur" --noconfirm
done

### Instalando o Grub.
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

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

### Instalação de ícones, temas e configurações.
if [ -d "$HOME"/.icons ]
then
  echo "Pasta já existe."
else
  mkdir -p "$HOME"/.icons
fi

if [ -d "$HOME"/.themes ]
then
  echo "Pasta já existe."
else
  mkdir -p "$HOME"/.themes
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Ativando ZRAM.
sudo sed -i "s/zram_enabled=0/zram_enabled=1/g" /usr/share/systemd-swap/swap-default.conf
sudo systemctl enable --now systemd-swap

### Procedimentos e otimizações.
systemctl enable NetworkManager
systemctl enable gdm
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
sudo usermod -aG docker "$(whoami)"
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
sudo flatpak --system override org.telegram.desktop --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.spotify.Client --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.valvesoftware.Steam --filesystem="$HOME"/.icons/:ro
sudo gsettings set org.gnome.desktop.default-applications.terminal exec terminator

### Bloco de personalizações pessoais.
# mkdir -p "$diretorio_downloads"

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
sudo pacman -R "$(pacman -Qdtq)" --noconfirm

### Limpando pasta temporária dos downloads.
# sudo rm "$diretorio_downloads"/ -rf

### Reiniciará o PC ou encerrará a execução do script.
echo -e "Digite S para reiniciar, ou N para sair do Script:"
read -r reinicia

case $reinicia in
    S|s)
    	exit
		reboot
		;;
    N|n)
    	exit 0
		;;
esac