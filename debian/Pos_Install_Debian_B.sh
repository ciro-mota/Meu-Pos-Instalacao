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
### 		Última edição 14/08/2023. <https://github.com/ciro-mota/Meu-Pos-Instalacao/commits/main>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Debian.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #
diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(cat /etc/debian_version) = "trixie/sid" ]]
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

# ------------------------------------------------------------------------------------------------------------- #
# ---------------------------------------- APLICANDO PERSONALIZAÇÕES ------------------------------------------ #
### Instalação de ícones, temas, fonte e configurações pessoais. Remova este trecho e pule para a próxima seção.
theme (){

curl -s https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest | grep "browser_download_url.*tar.xz" | \
cut -d : -f 2,3 | tr -d \" | \
wget -P "$diretorio_downloads" -i-
tar xf "$diretorio_downloads"/*.tar.xz -C "$HOME"/.local/share/themes

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

}

icon (){

wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.icons" sh
wget -cqO- https://git.io/papirus-folders-install | sh
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
papirus-folders -C bluegrey --theme Papirus
rm "$HOME"/.icons/ePapirus-Dark -rf
rm "$HOME"/.icons/ePapirus -rf
rm "$HOME"/.icons/Papirus-Dark -rf
rm "$HOME"/.icons/Papirus-Light -rf

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

sudo flatpak override --system --filesystem=/usr/share/icons/:ro
sudo flatpak override --system --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --system --env=XCURSOR_PATH=/run/host/user-share/icons:/run/host/share/icons
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.desktop.default-applications.terminal exec terminator
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
xdg-mime default org.gnome.Nautilus.desktop inode/directory 

sudo systemctl stop packagekit
sudo systemctl disable packagekit