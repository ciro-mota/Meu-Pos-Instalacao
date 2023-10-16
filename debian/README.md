Esta instalação do Debian consiste em um conjunto mínimo de pacotes semelhante ao que é feito com o Arch Linux. Com a ajuda do [debootstrap](https://wiki.debian.org/Debootstrap) será possível replicar quase que totalmente uma instalação parecida com o Arch Linux a exceção do `systemd-boot`, contando com sistema de arquivos `btrfs` e subvolumes.

Você **deverá** utilizar um liveCD de qualquer distro para iniciar o procedimento, recomendo que seja Linux Mint devido ao instalador não iniciar automaticamente e gerar erros ou você pode tentar distribuições base `.deb`. Caso seu terminal não esteja reconhecendo caracteres em pt_BR execute o comando abaixo.

```
setxkbmap -layout br
```

É feita uma varredura do repositório da mídia de instalação no uso do `apt` e o comando abaixo irá desabilitar a busca no CD e manter apenas os repositórios online. Recomendo que execute-o.

```
sed -e '/deb/ s/^#*/#/' -i /etc/apt/sources.list
```

## Particionamento:

Para o meu caso segue o exemplo do particionamento de um NVME com duas partições (o `/` e o `/boot`) e um disco secundário para a partição `/home`. Utilizei o `cfdisk` por mera preferência. Adapte para seu cenário.

Se não tiver certeza do nome dos discos use o comando `fdisk -l` para listá-los.

Inicie uma nova tabela de partições escolhendo o formato `gpt`.

Defina o layout de partições como desejar, sendo uma partição de 512MB ou 1GB para o `/boot/efi`.

```
cfdisk /dev/nvme0n1
```

Defina o tipo da partição `/boot` de 512MB ou 1GB como `EFI System`.

![imagem](/arch/arch-install1b.png)

```
cfdisk /dev/sda
```

Layout final das minhas partições:

![imagem](/arch/arch-install1.png)

## Formatação:

Para melhor aproveitamento com unidades flash e snapshots eu utilizo o formato de particionamento em `brtfs` para o `/` e para meu `/home`. A primeira partição será formatada em FAT32 necessário para o setor de inicialização.

```
mkfs.vfat -F32 /dev/nvme0n1p1
```

```
mkfs.btrfs -L ROOT /dev/nvme0n1p2
```

```
mkfs.btrfs /dev/sda1
```

## Pontos de montagem:

Aqui iremos começar de fato a construção do sistema começando pelos pontos de montagem. Vamos montar inicialmente a segunda partição, criar nela um subvolume e por fim desmontá-la. O subvolume é necessário e essencial para os snapshots. Você pode inclusive criar vários para melhor controle, no meu caso optei por somente criar um para toda a partição `/`. Porém antes de iniciar precisamos criar um diretório específico para armazenagem dos arquivos de instalação e que eu nomeei como `debian`.

```
mkdir /debian
```

Montagem da partição no diretório `/debian`.

```
mount /dev/nvme0n1p2 /debian
```

```
btrfs su cr /debian/@
```

```
umount /debian
```

Realizamos novamente a montagem da partição principal, porém dessa vez com a montagem do subvolume.

```
mount -o rw,relatime,ssd,subvol=@ /dev/nvme0n1p2 /debian
```

## Instalação do sistema base:

Aqui vamos instalar, no liveCD mesmo, alguns pacotes que serão necessários para a instalação.

```
apt update && apt install debootstrap arch-install-scripts
```

Neste ponto o `debootstrap` entrará em ação e fará a instalação do sistema base. Você poderá trocar o `sid` pelo `testing` ou `stable`, dependendo de qual versão do sistema você deseje instalar. Deverá ser informada o diretório que criamos para realizar o ponto de montagem e o endereço do repositório do Debian.

```
debootstrap sid /debian http://deb.debian.org/debian
```

Aqui devemos montar/ligar os diretórios do sistema do liveCD ao sistema que será "enjaulado" para a instalação do Debian.

```
mount --bind /dev /debian/dev
mount --bind /proc /debian/proc
mount --bind /sys /debian/sys
```

Finalmente executar o `chroot` (que é semelhante ao `arch-chroot`).

```
chroot /debian
```

Após entrar no `chroot` vamos adicionar os repositórios `non-free` e em seguida execute o comando `apt update`:

```
sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
```

Vamos montar a segunda partição no diretório `/home`.

```
mount /dev/sda1 /home
```

Agora devemos preparar o sistema para inicialização. Para isso devemos criar o diretório `efi` dentro de `/boot`.

```
mkdir -p /boot/efi
```

E por fim montar a partição `efi` nesse diretório.

```
mount /dev/nvme0n1p1 /boot/efi
```

Agora vamos finalmente instalar o sistema base.

```
apt install btrfs-progs dosfstools firmware-linux-free firmware-linux-nonfree grub-efi-amd64 linux-image-amd64 linux-headers-amd64 locales network-manager pipewire python3 sudo
```

## Configurando parâmetros:

Ao executar os passos acima o sistema já estará parcialmente construído necessitando apenas alguns ajustes para a primeira inicialização.

Abaixo a criação do seu usuário e senha, adapte ao seu cenário:

```
adduser ciromota
```

Adição ao grupo `sudo`:

`usermod -aG sudo ciromota`

Configuração de idiomas:

```
dpkg-reconfigure locales
```

Localize `pt_BR.UTF-8 UTF-8`.

![imagem](/debian/dpkg-locales1.png)
![imagem](/debian/dpkg-locales2.png)

O comando abaixo irá definir o nome do PC, adapte-o.

```
echo "k6-2-500" > /etc/hostname
```

## Instalando do GRUB para primeira inicialização.

```
grub-install /dev/nvme0n1
```

```
update-grub
```

Caso você receba a mensagem de erro:

```
grub-install: warning: EFI variables cannot be set on this system.
grub-install: warning: You will have to complete the GRUB setup manually.
```

Basta usar o ponto de montagem do `efivars` abaixo:

```
mount -t efivarfs none /sys/firmware/efi/efivars
```

## Ativando serviço de rede:

```
systemctl enable NetworkManager
```

## Saindo do chroot/instalação:

```
exit
```

## Geração do arquivo fstab:

```
genfstab -U /debian > /debian/etc/fstab
```

## Finalização:

```
umount -R /debian
reboot
```

## Instalando o systemd-boot

No Debian é necessário alguns passos a mais para instalação e ativação do `systemd-boot` (eu segui [este guia](https://p5r.uk/blog/2020/using-systemd-boot-on-debian-bullseye.html) e o adaptei) e esse processo deverá ser feito após a primeira inicialização. Recomendo que o processo seja executado como root. Você deve desabilitar o Secure Boot para funcionar.

Primeiramente devemos editar o arquivo `fstab` para alterar algumas permissões. Para a partição de inicialização `/boot/efi  vfat` altere as permissões de `fmask` e `dmask` para `fmask=0137,dmask=0027`.

Agora devemos instalar instale o pacote `systemd-boot`:

```
apt install systemd-boot
```

Agora devermos gerar as entradas de inicialização:

```
cat <<EOF >> /boot/efi/loader/loader.conf
default debian
editor no
EOF
```

Necessário criar o diretório que conterá os arquivos de configuração das imagens do kernel instaladas.

```
mkdir -p /boot/efi/loader/entries
```

Em seguida realizaremos a instalação (em si após a instalação do pacote o script já executa este procedimento porém vejo necessidade de repetir após a inserção das entradas acima):

```
bootctl --path=/boot/efi install
```

Os scripts abaixo farão os ganchos de adição e remoção dos novos kernels após atualizações à estrutura do `systemd-boot`:

```
cat <<EOF > /etc/kernel/postinst.d/zz-update-systemd-boot
#!/bin/sh
set -e

/usr/bin/kernel-install add "$1" "$2"

exit 0
EOF
```

```
cat <<EOF > /etc/kernel/postrm.d/zz-update-systemd-boot
#!/bin/sh
set -e

/usr/bin/kernel-install remove "$1"

exit 0
EOF
```

O seguinte script irá verificar a existência de pasta em `/boot/efi` com o mesmo conteúdo do arquivo `/etc/machine-id` e caso não haja essa pasta irá criá-la. Pode salvá-lo em qualquer local, dar permissões e executá-lo.

```
#!/usr/bin/env bash

machineid="$(cat /etc/machine-id)"

if [ -d /boot/efi/"$machineid" ]
then
  echo -e "Pasta já existe.\n"
else
  mkdir $(echo "$machineid")
fi
```

Por fim o comando abaixo realizará a cópia do kernel para a estrutura do `systemd-boot`.

```
kernel-install add `uname -r` /boot/vmlinuz-`uname -r`
```

Se tudo deu certo ao reiniciar você já poderá inicializar através do `systemd-boot` ao invés do `GRUB`. Após isso você já poderá remover o pacote `grub-efi-amd64`.

## Instalando plymouth

É possível utilizar o Plymouth com o `systemd-boot` porém alguns passos a mais são necessários se comparado com o Arch.

Instale os pacotes abaixo:

```
apt install plymouth plymouth-themes
```

O script de instalação no Debian usa como base o conteúdo de `/proc/cmdline` e este diretório é somente leitura. Precisamos aqui usar um ponto de montagem para [mascarar essa restrição](https://wiki.archlinux.org/title/Kernel_parameters#Hijacking_cmdline). Crie o arquivo `cmdline` dentro do diretório `/root`:

```
cat /proc/cmdline > /root/cmdline
```

Edite o arquivo e mantenha somente como conteúdo deste arquivo a identificação a partir de `root`. Adicione também o parâmetro `splash` à linha. Exemplo:

```
root=UUID=<id-da-sua-partição> ro rootflags=subvol=@ quiet splash systemd.machine_id=<id-da-sua-máquina>
```

Agora devemos montar esse diretório:

```
mount -n --bind -o ro /root/cmdline /proc/cmdline
```

Aplique o tema padrão do Plymouth do Debian:

```
/usr/sbin/plymouth-set-default-theme emerald --rebuild-initrd
```

Feito isso ao iniciar o sistema já contará com um tema de Plymouth.