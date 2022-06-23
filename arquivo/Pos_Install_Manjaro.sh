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
### 		Última edição 11/05/2022. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Manjaro.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Links de download dinâmicos.
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
# url_backup="https://github.com/ciro-mota/conf-backup.git"

### Programas para instalação e desinstalação.
apps_remover=(gnome-calendar 
	gnome-user-docs 
	gthumb 
	lollypop 
	manjaro-hello 
	manjaro-settings-manager-notifier
	manjaro-settings-manager 
	yelp)

apps=(bootsplash-manager 
	bootsplash-theme-manjaro 
	celluloid 
	chromium 
	containerd 
	cowsay 
	docker 
	docker-compose 
	ttf-fantasque-sans-mono 
	ffmpegthumbnailer 
	flatpak 
	font-manager 
	fortune-mod 
	gnome-icon-theme-symbolic 
	hplip 
	hugo 
	libpamac-flatpak-plugin 
	lolcat 
	lutris 
	neofetch 
	pass 
	qbittorrent 
	seahorse 
	systemd-swap  
	terminator)

apps_do_aur=(android-sdk-platform-tools 
	brave-bin 
	heroic-games-launcher-bin 
	teamviewer 
	ulauncher 
	vscodium-bin)

pipewire_remove=(pulseaudio 
	pulseaudio-alsa 
	pulseaudio-bluetooth 
	pulseaudio-ctl 
	pulseaudio-jack 
	pulseaudio-lirc 
	pulseaudio-rtp 
	pulseaudio-zeroconf)

pipewire_adiciona=(manjaro-pipewire)		  
	
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
if [[ $(lsb_release -cs) = "Qonos" ]]
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
### Atualizando listas e sistema após adição de novos repositórios.
sudo sed -i '/EnableAUR/s/^#//' /etc/pamac.conf
sudo pacman-mirrors -c United_States -m rank
sudo pamac update --no-confirm --force-refresh && sudo pamac upgrade -a --no-confirm

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Desinstalando apps desnecessários.
for nome_do_programa in "${apps_remover[@]}"; do
    sudo pamac remove "$nome_do_programa" --no-confirm
done

for pipe_rem in "${pipewire_remove[@]}"; do
    sudo pacman -Rdd "$pipe_rem" --noconfirm
done

### Instalação de programas.
for nome_do_app in "${apps[@]}"; do
  if ! pamac list -i | grep -q "$nome_do_app"; then
    sudo pamac install "$nome_do_app" --no-confirm
  else
    echo "$nome_do_app ==> [JÁ INSTALADO]"
  fi
done

for pipe_add in "${pipewire_adiciona[@]}"; do
    sudo pamac install "$pipe_add" --no-confirm
done

### Instalação de programas do AUR.
for nome_do_aur in "${apps_do_aur[@]}"; do
    sudo pamac build "$nome_do_aur" --no-confirm
done

for nome_do_flatpak in "${flatpak[@]}"; do
  if ! flatpak list | grep -q "$nome_do_flatpak"; then
    sudo flatpak install --system "$nome_do_flatpak" -y
  fi
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
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo echo -e "# Menor uso de Swap" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo usermod -aG docker "$(whoami)"
sudo flatpak --system override --filesystem="$HOME"/.icons/:ro
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
sudo gsettings set org.gnome.desktop.default-applications.terminal exec terminator
sudo rm /usr/share/applications/avahi-discover.desktop
sudo rm /usr/share/applications/bssh.desktop
sudo rm /usr/share/applications/bvnc.desktop
sudo rm /usr/share/applications/gtk-lshw.desktop
sudo rm /usr/share/applications/lstopo.desktop
sudo rm /usr/share/applications/nm-connection-editor.desktop
sudo rm /usr/share/applications/qv4l2.desktop
sudo rm /usr/share/applications/qvidcap.desktop

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