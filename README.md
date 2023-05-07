# Script de Pós Instalação

![License](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-294172?style=for-the-badge&logo=fedora&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)

Este script foi desenvolvido com o objetivo de demonstrar a parametrização do meu PC com o **Fedora Workstation** que é a minha distro principal no momento. O intuito é construir uma instalação mínima e ir personalizando à medida da necessidade de uso, com instalações de apps apenas via terminal.

Este script conta também com uma versão "backup" caso eu opte em algum momento migrar para o Arch Linux. Para instalação do Arch Linux, seguir recomendações de instalação em [anexo](/arch/Arch-Install.md).

### Observações:

É inteiramente livre a cópia e execução dos scripts contidos neste repositório contudo, você deverá **acima de tudo ler e entender** o que cada passo faz caso opte por executá-lo de forma integral sabendo que meu perfil de uso é seguramente diferente do seu, ou **adaptá-lo (melhor opção) para sua necessidade** antes da execução, modificando programas que serão instalados nas etapas de repositório, .rpm, Flatpak, extensões do Codium e AUR caso opte pelo Arch Linux. O intuito além de demostrar é de servir de inspiração para a construção do seu próprio script de pós instalação.

### Isenção de Responsabilidade:

Os scripts disponibilizados são seguramente **testados** por mim antes de serem publicados contudo devido a natureza da diferença entre hardwares e o período quando ocorre as atualizações do script e as atualizações dos sistemas e pacotes, erros poderão ocorrer na execução. Em sendo, não há garantias plenas do total funcionamento deste script de modo que não me responsabilizo caso haja algum dano material ou de perda de dados.

Peço **gentilmente** que em caso de erros reporte-os na guia [Issues](https://github.com/ciro-mota/Meu-Pos-Instalacao/issues) que tentarei o possível para ajudar.

### Extensões GNOME:

- [Vitals](https://extensions.gnome.org/extension/1460/vitals/)
- [Date Menu Formatter](https://extensions.gnome.org/extension/4655/date-menu-formatter/) (String: dd MMMM y | k:mm)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [Hide Activities Button](https://extensions.gnome.org/extension/744/hide-activities-button/)
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Desktop Icons NG (DING)](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)
- [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)

### Tema

Utilize o app [Gradience](https://flathub.org/apps/details/com.github.GradienceTeam.Gradience) para aplicação de esquema de cores Dracula com cor de destaque azul ao invés do rosa/roxo padrão deste tema. Importe meu esquema de cores caso desejar:

<details>
  <summary>Clique para expandir</summary>
    
```json
{
    "name": "local-theme",
    "variables": {
        "accent_color": "rgb(28, 113, 216)",
        "accent_bg_color": "rgb(26, 95, 180)",
        "accent_fg_color": "#f8f8f2",
        "destructive_color": "#f55",
        "destructive_bg_color": "#f55",
        "destructive_fg_color": "#f8f8f2",
        "success_color": "#50fa7b",
        "success_bg_color": "#50fa7b",
        "success_fg_color": "#f8f8f2",
        "warning_color": "#f1fa8c",
        "warning_bg_color": "#f1fa8c",
        "warning_fg_color": "rgba(0, 0, 0, 0.8)",
        "error_color": "#f55",
        "error_bg_color": "#f55",
        "error_fg_color": "#f8f8f2",
        "window_bg_color": "rgb(35, 37, 46)",
        "window_fg_color": "#f8f8f2",
        "view_bg_color": "rgb(35, 37, 46)",
        "view_fg_color": "#f8f8f2",
        "headerbar_bg_color": "rgb(35, 37, 46)",
        "headerbar_fg_color": "#f8f8f2",
        "headerbar_border_color": "#fff",
        "headerbar_shade_color": "rgba(0, 0, 0, 0.36)",
        "card_bg_color": "rgba(255, 255, 255, 0.08)",
        "card_fg_color": "#f8f8f2",
        "card_shade_color": "rgba(0, 0, 0, 0.36)",
        "dialog_bg_color": "rgb(35, 37, 46)",
        "dialog_fg_color": "#f8f8f2",
        "popover_bg_color": "rgb(35, 37, 46)",
        "popover_fg_color": "#f8f8f2",
        "shade_color": "#383838",
        "scrollbar_outline_color": "rgba(0, 0, 0, 0.5)"
    },
    "palette": {
        "blue_": {
            "1": "#99c1f1",
            "2": "#62a0ea",
            "3": "#3584e4",
            "4": "#1c71d8",
            "5": "#1a5fb4"
        },
        "green_": {
            "1": "#8ff0a4",
            "2": "#57e389",
            "3": "#33d17a",
            "4": "#2ec27e",
            "5": "#26a269"
        },
        "yellow_": {
            "1": "#f9f06b",
            "2": "#f8e45c",
            "3": "#f6d32d",
            "4": "#f5c211",
            "5": "#e5a50a"
        },
        "orange_": {
            "1": "#ffbe6f",
            "2": "#ffa348",
            "3": "#ff7800",
            "4": "#e66100",
            "5": "#c64600"
        },
        "red_": {
            "1": "#f66151",
            "2": "#ed333b",
            "3": "#e01b24",
            "4": "#c01c28",
            "5": "#a51d2d"
        },
        "purple_": {
            "1": "#dc8add",
            "2": "#c061cb",
            "3": "#9141ac",
            "4": "#813d9c",
            "5": "#613583"
        },
        "brown_": {
            "1": "#cdab8f",
            "2": "#b5835a",
            "3": "#986a44",
            "4": "#865e3c",
            "5": "#63452c"
        },
        "light_": {
            "1": "#fff",
            "2": "#f6f5f4",
            "3": "#deddda",
            "4": "#c0bfbc",
            "5": "#9a9996"
        },
        "dark_": {
            "1": "#77767b",
            "2": "#5e5c64",
            "3": "#3d3846",
            "4": "#241f31",
            "5": "#000"
        }
    },
    "custom_css": {
        "gtk4": ""
    },
    "plugins": {}
}
```
</details>

É possível também aplicar uma transparência sem o uso de extensões na barra de tarefas do GNOME, para isso edite o arquivo `gnome-shell.css` do seu tema favorito, localize o conjunto de linhas abaixo:

```css
/* Top Bar */
#panel {
  background-color: rgba(0, 0, 0, 0.7);
```

E modifique o último valor do campo. No meu caso há uma transparência de 0.7, equivalente a 70% e na cor preta.

### Aparência final:

![](imgs/screenshot.png)

### Ultima Modificação:

> 07 Mai 2023
