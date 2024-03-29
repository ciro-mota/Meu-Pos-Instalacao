O caminho inicial e o principal para a instalação do Arch Linux é a sua wiki que é extremamente completa, mais precisamente o item [Installation guide (Português)](<https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)>). Contudo, não há uma forma exata e "correta" da sua construção e instalação, como uma "receita de bolo". O método abaixo foi o método mais objetivo que consegui desenvolver visando meu perfil de uso.

## Configurações iniciais de instalação:

```
timedatectl set-ntp true
```

```
loadkeys br-abnt2
```

## Particionamento:

Para o meu caso, segue o exemplo do particionamento de um NVME com duas partições (o `/` e o `/boot`) e um disco secundário para a partição `/home`. Utilizei o `cfdisk` por mera preferência. Adapte para seu cenário.

Se não tiver certeza do nome dos discos, use o comando `fdisk -l` para listá-los.

Inicie uma nova tabela de partições escolhendo o formato `gpt`.

```
cfdisk /dev/nvme0n1
```

![imagem](/arch/arch-install1a.png)

Defina o tipo da partição `/boot` de 512MB como `EFI System`.

![imagem](/arch/arch-install1b.png)

```
cfdisk /dev/sda
```

Layout final das minhas partições:

![imagem](/arch/arch-install1.png)

## Formatação:

Para melhor aproveitamento com unidades flash e snapshots, utilizo o formato de particionamento em `brtfs` para o `/` e para meu `/home`. A primeira partição será formatada em FAT32 necessário para o setor de inicialização.

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

Aqui iremos começar de fato a construção do sistema começando pelos pontos de montagem. Vamos montar inicialmente a segunda partição, criar nela um subvolume e por fim desmontá-la. O subvolume é necessário e essencial para os snapshots. Você pode inclusive criar vários para melhor controle, no meu caso optei por somente criar um para toda a partição `/`.

```
mount /dev/nvme0n1p2 /mnt
```

```
btrfs su cr /mnt/@
```

```
umount /mnt
```

Realizamos novamente a montagem da partição principal, porém dessa vez com a montagem do subvolume.

```
mount -o rw,relatime,ssd,subvol=@  /dev/nvme0n1p2 /mnt
```

Crie a seguinte estrutura de diretórios:

```
mkdir -p /mnt/{boot,home}
```

Monte a estrutura que foi criada. No meu caso como citado, a partição `/home` ficará em um outro disco, adapte ao seu cenário se necessário:

```
mount /dev/nvme0n1p1 /mnt/boot
```

```
mount /dev/sda1 /mnt/home
```

## Instalação do sistema base:

```
pacstrap /mnt base base-devel git linux linux-firmware nano sudo
```

Gere o arquivo `fstab` com o comando abaixo:

```
genfstab -U /mnt >> /mnt/etc/fstab
```

Edite-o:

```
nano /mnt/etc/fstab
```

Substitua, para a partição `/` o campo `relatime` para `noatime,compress=zstd:3` onde habilitamos compressão visando desempenho, se aproveitando dos recursos fornecidos pelo sistema de arquivos `btrfs`. Use `cat /mnt/etc/fstab` para verificar como ficou:

![imagem](/arch/arch-install2.png)

## Construção do sistema:

Execute o comando abaixo para execução de `chroot` e configuração do sistema:

```
arch-chroot /mnt
```

Defina seu fuso horário, adapte se necessário.

```
ln -sf /usr/share/zoneinfo/America/Bahia /etc/localtime
```

Sincronização dos relógios (hardware e SO):

```
hwclock --systohc
```

Agora a configuração de idiomas:

```
sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
```

```
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
```

```
locale-gen
```

Aqui a configuração de usuário e `sudo`:

```
EDITOR=nano visudo
```

Ao abrir o editor, descomente a linha `%wheel ALL=(ALL) ALL`. Salve e saia.

Abaixo a criação do seu usuário, adapte ao seu cenário:

```
useradd -m -G wheel ciromota
```

```
passwd ciromota
```

## Instalação do sistema:

No meu caso escolhi uma instalação mínima do GNOME. Caso escolha outro Ambiente Desktop, verifique a lista de pacotes necessários para a instalação. Aqui também são instalados alguns utilitários de sistema, você pode verificar no arquivo `pacotes.txt` neste repositório quais pacotes estão sendo instalados. Abaixo utilizo um link encurtado para facilitar a instalação em um ambiente de terminal:

```
bash <(curl -Ls https://bit.ly/motarchpkg)
```

## Configurando parâmetros:

O comando abaixo irá definir o nome do PC, adapte-o.

```
echo "k6-2-500" >> /etc/hostname
```

O conjunto de linhas abaixo irá povoar o arquivo hosts, adapte-o baseado no hostname definido no passo anterior:

```
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.0.1	k6-2-500.localdomain	k6-2-500
EOF
```

## Instalando o Systemd-Boot.

```
bootctl --path=/boot install
```

```
cat <<EOF >> /boot/loader/loader.conf
default arch.conf
editor no
EOF
```

```
cat <<EOF > /boot/loader/entries/arch.conf
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options root=LABEL=ROOT rootflags=subvol=@ rw quiet splash
EOF
```

## Ativando serviços:

```
systemctl enable NetworkManager
```

```
systemctl enable gdm
```

## Aplicando requisitos:

### Adicionando repositório Multilib.

```
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf && sudo pacman -Sy
```

### Instalando Yay AUR Helper.

Altere de `ciromota` para o usuário que criou anteriormente.

```
sudo -u ciromota bash -c 'cd ~&& git clone https://aur.archlinux.org/yay.git && cd yay/ && makepkg -si --noconfirm'
```

### Atualizando o Initramfs:

```
mkinitcpio -p linux
```

### Saindo da instalação:

```
exit
umount -R /mnt
reboot
```

Se tudo correu bem, após o `reboot` o sistema irá iniciar normalmente e com ambiente gráfico GNOME.

Após a conclusão de todos os passos, execute o script [Pos_Install_Arch.sh](/arch/Pos_Install_Arch.sh) para conclusão da instalação.

## Pós instalação:

É possível que durante a tarefa de execução do `mkinitcpio -p linux` você perceba as mensagens abaixo ou parecidas.

```
==> WARNING: Possibly missing firmware for module: aic94xx
==> WARNING: Possibly missing firmware for module: wd719x
==> WARNING: Possibly missing firmware for module: xhci_pci
```

Não se trata necessariamente de um problema conforme pode ser [lido aqui](https://wiki.archlinux.org/title/Mkinitcpio#Possibly_missing_firmware_for_module_XXXX). Contudo caso deseje "resolver" o que essas mensagens indicam, execute as linhas abaixo, supondo que já instalou o `paru` conforme indicado acima.

```
yay -S aic94xx-firmware ast-firmware upd72020x-fw wd719x-firmware
```

```
sudo pacman -S linux-firmware-qlogic
```
