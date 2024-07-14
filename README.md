<div align="right">🖕</div>

<div align="center">
<img src="https://img.shields.io/github/last-commit/tonigineer/.dotfiles?style=for-the-badge&logo=github&color=a6da95&logoColor=D9E0EE&labelColor=302D41"/>
<img src="https://img.shields.io/github/repo-size/tonigineer/.dotfiles?style=for-the-badge&logo=dropbox&color=7dc4e4&logoColor=D9E0EE&labelColor=302D41"/>
<a href="https://www.reddit.com/r/unixporn/">
<img alt="just-wallpaper-with-waybar" src="https://github.com/Welcome2Heaven/Unixporn-Banner/blob/main/PNGS/Unixporn%20-%20Mobile.png?raw=true" style="width: 140px;"/>
</a>
</div>

<br>

<div align="center">
<a href="#overview"><kbd>Overview</kbd></a> ❗ <a href="#installation"><kbd>Install</kbd></a> ❗ <a href="https://github.com/tonigineer/zsh"><kbd>tonigineer/zsh</kbd></a> ❗ <a href="https://github.com/tonigineer/nvim"><kbd>tonigineer/nvim</kbd>
</a></div>

## 🎨 Impressions

<div align="center">
<kbd><img alt="messy-impression" src="./assets/impression.png" style="width: 500px;"/></kbd>
</div>

## 📖 Overview

<details open>
<summary><b>🔬 Display</b></summary>

>
<!-- Get some vertical space -->

➖ Display Server: [Wayland](https://wiki.archlinux.org/title/Wayland)
🔺 Compositor: [Hyprland](https://hyprland.org/)
🔺 Graphics: [Nvidia](https://wiki.hyprland.org/Nvidia/)
🔺 Bar: [EWW](https://github.com/elkowar/eww)

</details>

<details open>
<summary><b>⚙️ Configuration</b></summary>

>
<!-- Get some vertical space -->

➖ Wallpaper: [Hyprpaper](https://github.com/hyprwm/hyprpaper) | [mpvpaper]()
🔺 Lockscreen: [Hyprlock](https://github.com/hyprwm/hyprlock) | [Hypridle](https://github.com/hyprwm/hypridle)
🔺 Launcher: [Rofi](https://github.com/lbonn/rofi)
</details>

<details open><summary><b>🌈 Appearance</b></summary>

>
<!-- Get some vertical space -->

➖ Color scheme: [Tokyonight-Dark-BL-LB](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme)
🔺 Cursor: [Hyprcursor](https://github.com/hyprwm/hyprcursor) | [rose-pine-hyprcursor](https://github.com/ndom91/rose-pine-hyprcursor)
🔺 Icons: [Candy Icons](https://github.com/EliverLara/candy-icons)
</details>

<details open><summary><b>📠 Terminal</b></summary>

>
<!-- Get some vertical space -->

➖ Emulator: [Alacritty](https://github.com/alacritty/alacritty) 🔺 Shell: [ZSH](https://github.com/tonigineer/zsh)
🔺 Editor: [Neovim](https://github.com/tonigineer/nvim) | [Visual Studio Code](https://code.visualstudio.com/download) 
</details>

<details open><summary><b>✂️ Misc</b></summary>

>
<!-- Get some vertical space -->

➖ Files: [Thunar](https://github.com/xfce-mirror/thunar) 🔺 Visuallizer: [cava](https://github.com/karlstav/cava) 🔺 Resources: [btop](https://github.com/aristocratos/btop) 🔺 Show off: [cmatrix](https://github.com/abishekvashok/cmatrix)
</details>


## 🥼 Installation

Clone repository and run the installation script:

```sh
git clone --recurse-submodules https://github.com/tonigineer/dotfiles.git ~/Dotfiles

cd ~/Dotfiles/scripts/install.sh all
```

> [!IMPORTANT]
> Some parts of the configuration, like monitor names, are specific to my setup. So, it might be a good idea to install it manually. Plus, you'll probably learn something along the way.
>
> Furthermore, the configuration is based on a 4K display. Using different resolutions might change or break things. For example, [hyprlock](https://github.com/hyprwm/hyprlock) positions are specified in pixels from anchors.

