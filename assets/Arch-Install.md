Não há uma forma correta da construção e instalação do Arch Linux, o método abaixo foi o método mais objetivo que consegui, visando meu perfil de uso.
## Configurações iniciais de instalação:

```
timedatectl set-ntp true
```
```
loadkeys br-abnt2
```

## Particionamento:

Para o meu caso, segue o exemplo do particionamento de um NVME com duas partições (o `/` e o `/boot/EFI`) e um disco secundário para a partição `/home`. Utilizei o `cfdisk` por mera preferência. Adapte para seu cenário.

Se não tiver certeza do nome dos discos, use o comando `fdisk -l` para listá-los.

Inicie uma nova tabela de partições escolhendo o modo `gpt`.

```
cfdisk /dev/nvme0n1
```
```
cfdisk /dev/sda
```

Layout final das partições:

![imagem](/assets/arch-install1.png)
## Formatação:

Para melhor aproveitamento com unidades flash e snapshots, utilizo o formato de particionamento em `brtfs` para o `/` e `xfs` para meu `/home`. A primeira partição será formatada em FAT32 necessário para o setor de inicialização.

```
mkfs.vfat -F32 /dev/nvme0n1p1
```
```
mkfs.btrfs /dev/nvme0n1p2
```
```
mkfs.xfs /dev/sda1
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

Crie a seguinte estrutura de pasta:

```
mkdir -p /mnt/{boot/EFI,home}
```
Monte a estrutura que foi criada. No meu caso como citado, a partição `/home` ficará em um outro disco, adapte ao seu cenário se necessário:

```
mount /dev/nvme0n1p1 /mnt/boot/EFI
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

![imagem](/assets/arch-install2.png)

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

Agora a configuração de idiomas, edite o arquivo:

```
nano /etc/locale.gen
```

Descomente a linha referente a `pt_BR.UTF-8 UTF-8`. Salve e saia.

![imagem](/assets/arch-install3.png)

Execute os comandos à seguir:

```
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
```
```
locale-gen
```
```
EDITOR=nano visudo
```

Ao abrir o editor, descomente a linha `%wheel ALL=(ALL) ALL`. Salve e saia.

Abaixo a criação do usuário, adapte ao seu cenário:

```
useradd -m -G wheel ciromota
```

```
passwd ciromota
```
## Instalação do sistema:

No meu caso escolhi uma instalação mínima do GNOME. Caso escolha outra _DE_, verifique a lista de pacotes necessários. Aqui também são instalados alguns utilitários de sistema:

```
pacman -S btrfs-progs dosfstools efibootmgr gnome-shell gnome-control-center gdm gnome-terminal grub mtools networkmanager nautilus network-manager-applet os-prober wireless_tools wpa_supplicant xdg-user-dirs xorg
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

## Instalando o Grub.
```
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
```
```
grub-mkconfig -o /boot/grub/grub.cfg
```

## Ativando serviços:
```
systemctl enable NetworkManager
```
```
systemctl enable gdm
```

Se tudo correu bem, digite `exit` e por fim `reboot` e o sistema irá iniciar normalmente e com ambiente gráfico.

## Aplicando requisitos:
### Adicionando repositório Multilib.
```
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf && sudo pacman -Sy
```
### Instalando yay AUR Helper.
```
git clone https://aur.archlinux.org/yay.git && cd yay/ 
```
```
makepkg -sri
```

Após a conclusão de todos os passos, execute o script [Pos_Install_Arch.sh](/Pos_Install_Arch.sh) para conclusão da instalação.