#!/usr/bin/env bash
# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Debian.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Debian Sid, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Meu-Pos-Instalacao/blob/main/LICENSE>
## CHANGELOG:
### 		Última edição 01/09/2023. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Debian.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #
export DEBIAN_FRONTEND=noninteractive

### PPA's e links de download dinâmicos.
url_lutris="https://download.opensuse.org/repositories/home:/strycore/Debian_12/"
url_ppa_lutris="https://download.opensuse.org/repositories/home:/strycore/Debian_12/Release.key"
url_dck_key="https://download.docker.com/linux/debian/gpg"
url_ppa_dck="https://download.docker.com/linux/debian"
url_key_brave="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
url_ppa_brave="https://brave-browser-apt-release.s3.brave.com/"
url_ppa_ulauncher="http://ppa.launchpad.net/agornostal/ulauncher/ubuntu"
url_code="https://download.vscodium.com/debs"
url_key_code="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
url_neofetch="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/dots/config.conf"
url_terminator="https://github.com/ciro-mota/Meu-Pos-Instalacao/raw/main/dots/config"

### Programas para remoção.
apps_remover=(firefox-esr 
	gnome-software 
	totem 
	yelp)

### Programas para instalação.
apps=(brave-browser 
	codium 
	containerd 
	cowsay 
	docker-ce 
	exfat-fuse 
	fastboot 
	ffmpeg 
	ffmpegthumbnailer 
	file-roller 
	firefox 
	firefox-l10n-pt-pt 
	firmware-linux-nonfree 
	flameshot 
	font-manager 
	fonts-croscore 
	fonts-noto 
	fonts-noto-extra 
	fonts-ubuntu 
	fortune-mod 
	gamemode 
	gimp 
	gir1.2-gtop-2.0 
	gnome-browser-connector 
	gnome-tweaks 
	goverlay 
	gparted 
	gstreamer1.0-plugins-ugly 
	gstreamer1.0-vaapi 
	gufw 
	hplip 
	hugo 
	ksnip 
	libavcodec-extra 
	ldap-utils 
	libasound2-plugins 
	libreoffice 
	libreoffice-l10n-pt-br 
	lolcat
	lutris 
	micro 
	nala 
	neofetch 
	network-manager-gnome 
	openprinting-ppds 
	printer-driver-pxljr 
	plymouth 
	plymouth-themes 
	qbittorrent 
	remmina 
	seahorse 
	simplescreenrecorder 
	telegram-desktop 
	terminator 
	ulauncher 
	vdpauinfo 
	vim 
	virt-manager 
	vlc 
	zsh)
	
flatpak=(com.valvesoftware.Steam 
	com.github.GradienceTeam.Gradience 
	nl.hjdskes.gcolor3 
	org.freedesktop.Platform.VulkanLayer.MangoHud 
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
if ping -q -c 3 -W 1 1.1.1.1 >/dev/null;
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
# -------------------------------- ATIVANDO O DEBIAN SID, CONTRIB E NON-FREE ---------------------------------- #
sudo sed -i 's/#.*$//;/^$/d' /etc/apt/sources.list
sudo sed -i '/deb-src/d' /etc/apt/sources.list
sudo sed -i '/debian-security/d' /etc/apt/sources.list
sudo sed -i '/sid-updates/d' /etc/apt/sources.list
sudo sed -i 's/bookworm/sid/g' /etc/apt/sources.list
sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sudo apt update && sudo apt full-upgrade -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Adicionando/Confirmando arquitetura de 32 bits.
### wiki.debian.org/Multiarch/HOWTO
sudo dpkg --add-architecture i386

### Instalando requerimentos.
sudo apt install \
    apt-transport-https \
    curl \
	git \
    gnupg \
	flatpak \
    software-properties-common -y

### Adicionando repositórios de terceiros.
### Lutris.
echo "deb $url_lutris ./" | sudo tee /etc/apt/sources.list.d/lutris.list > /dev/null
wget -q -O- "$url_ppa_lutris" | gpg --dearmor | sudo tee /etc/apt/keyrings/lutris.gpg > /dev/null

### Docker.
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "$url_dck_key" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] $url_ppa_dck \
  bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

### Brave Browser.
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg "$url_key_brave"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
	$url_ppa_brave stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

### Ulauncher.
gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176
gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
          $url_ppa_ulauncher jammy main" \
          | sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list

### VSCodium.
wget -qO - $url_key_code | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] '$url_code' vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

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
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .deb.
sudo apt install -y "$diretorio_downloads"/*.deb

### Heroic Games.
heroic (){
curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest \
 | grep "heroic_2.9.1_amd64.deb" | \
cut -d : -f 2,3 | tr -d \" | \
wget -P "$diretorio_downloads" -i-
sudo dpkg -i "$diretorio_downloads"/*.deb
}

heroic

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    codium --install-extension "$code_ext" 2> /dev/null
done

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Melhorias de performance.
### Ativando ZRAM. 
sudo echo -e "zram" | sudo tee -a /etc/modules-load.d/zram.conf
sudo echo -e "options zram num_devices=1" | sudo tee -a  /etc/modprobe.d/zram.conf

sudo tee -a /etc/udev/rules.d/99-zram.rules << 'EOF' 
KERNEL=="zram0", ATTR{disksize}="2048M",TAG+="systemd"
EOF

sudo tee -a /etc/systemd/system/zram.service << 'EOF' 
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
EOF

sudo systemctl enable zram

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

### Configurações do QEMU.
sudo sed -i '/unix_sock_group/s/^#//g' /etc/libvirt/libvirtd.conf
sudo sed -i '/unix_sock_rw_perms/s/^#//g' /etc/libvirt/libvirtd.conf
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo virsh net-start default

### Aplicando Plymouth.
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo sed -i 's/logo-text-version-64.png/logo-text-64.png/g' /etc/gdm3/greeter.dconf-defaults
sudo update-grub
sudo dpkg-reconfigure gdm3

### Aplicação de dot files.
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

### Recria configurações de rede.
sudo mv /etc/network/interfaces /etc/network/interfaces.old

### Finalização e limpeza.
for nome_do_app_remover in "${apps_remover[@]}"; do
  if ! dpkg -l | grep -q "$nome_do_app_remover"; then
    sudo apt purge "$nome_do_app_remover" -y
  fi
done

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
	*)
		echo -e "Opção inválida!"
		exit 1
	;;	
esac

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------- PÓS-REBOOT ----------------------------------------------- #
### As configurações a seguir não podem ser executadas em um ambiente TTY, deste modo será necessário reiniciar
### e executar o script "Pos_Install_Debian_B" após carregamento do ambiente gráfico.