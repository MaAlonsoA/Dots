# Requisitos

```Shell
sudo apt install kitty bspwm rofi feh imagemagick
```

## Bspwm & Sxhkd

```Shell
apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev

git clone https://github.com/baskerville/bspwm.git

git clone https://github.com/baskerville/sxhkd.git

cd bspwm

make

sudo make install

cd sxhkd

make

sudo make install

sudo apt-get install bspwm 
```

### Configuración Sxhkd

Copiamos los archivos de configuración de ejemplo.

## Polybar

```Shell
apt install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev

git clone --recursive https://github.com/polybar/polybar

mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make instal
```

## Picom

```Shell
apt install libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson


git clone https://github.com/ibhagwan/picom.git

git submodule update --init --recursive 
meson --buildtype=release . build 
ninja -C build
sudo ninja -C build install
```

## Kitty

instalamos kitty desde github y creamos una carpeta en OTP

```Shell
cd /opt
sudo su
cd kitty
mv ~/Downloads/kitty-0.26.5-x86_64.txz
mv ~/Downloads/kitty-0.26.5-x86_64.txz .
tar -xf kitty-0.26.5-x86_64.txz
```

## Polybar launch

```Shell
git clone https://github.com/VaughnValle/blue-sky.git
echo '~/.config/polybar/./launch.sh' >> ~/.config/bspwm/bspwmrc
sudo cp * /usr/share/fonts/truetype/
fc-cache -v
```

## Powerlevel 10k

```Shell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

chown root:root /usr/local/share/zsh/site-functions/
ln -s -f /home/zbr/.zshrc .zshrc
```

## fzF

 ```Shell
 git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Modificar la polybar

color.ini

```bash
[color]
bg =    #2E3440
fg =    #D8DEE9

# white
snow3 = #ECEFF4
snow2 = #E5E9F0
snow1 = #D8DEE9

# Polar

polar4 = #4C566A
polar3 = #434C5E
polar2 = #3B4252
polar1 = #2E3440

# frost

frost1 = #8FBCBB
frost2 = #88C0D0
frost3 = #81A1C1
frost4 = #5E81AC

# Aurora

aurora1 = #BF616A
aurora2 = #D08770
aurora3 = #EBCB8B
aurora4 = #A3BE8C
aurora5 = #B4