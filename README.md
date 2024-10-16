<div align="right">🖕</div>

<div align="center">
<img src="https://img.shields.io/github/last-commit/tonigineer/.dotfiles?style=for-the-badge&logo=github&color=a6da95&logoColor=D9E0EE&labelColor=302D41"/>
<img src="https://img.shields.io/github/repo-size/tonigineer/.dotfiles?style=for-the-badge&logo=dropbox&color=7dc4e4&logoColor=D9E0EE&labelColor=302D41"/>
</div>

<br>

<div align="center">
<a href="https://github.com/tonigineer/zsh"><kbd>tonigineer/zsh</kbd></a> ❗ <a href="https://github.com/tonigineer/nvim"><kbd>tonigineer/nvim</kbd>
</a></div>

## 🎨 Impressions

<div align="center">
<kbd><img alt="messy-impression" src="./assets/impression.png" style="width: 500px;"/></kbd>
</div>

## 📖 Configuration details

The table below provides information on the key repositories, frameworks, and libraries used in my setup.

Category | Links and Information
---: | ---
Display Server| [Wayland](https://wiki.archlinux.org/title/Wayland)
Compositor | [Hyprland](https://hyprland.org/)
Graphics | [Nvidia](https://wiki.hyprland.org/Nvidia/)
|
Wallpaper | [Hyprpaper](https://github.com/hyprwm/hyprpaper) & [mpvpaper]()
Bar & Side panel | [AGS](https://github.com/Aylur/ags)
Launcher | [AGS](https://github.com/Aylur/ags) (Modes: *bin*, *URL*, *duckduckgo*, *bash*)
Lockscreen | [Hyprlock](https://github.com/hyprwm/hyprlock) & [Hypridle](https://github.com/hyprwm/hypridle)
|
Color scheme | [Tokyonight-Dark-BL-LB](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme)
Cursor | [Hyprcursor](https://github.com/hyprwm/hyprcursor) & [rose-pine-hyprcursor](https://github.com/ndom91/rose-pine-hyprcursor)
Icons | [Candy Icons](https://github.com/EliverLara/candy-icons)
|
Terminal emulator | [Kitty](https://github.com/kovidgoyal/kitty)
Shell | [ZSH](https://www.zsh.org/) + [Config repo](https://github.com/tonigineer/zsh)
Editor | [Nvim](https://github.com/neovim/neovim) + [Config repo](https://github.com/tonigineer/nvim)
|
Files explorer | [Yazi](https://github.com/sxyazi/yazi)
Visualizer | [Cava](https://github.com/karlstav/cava)
Resource monitor | [BTop++](https://github.com/aristocratos/btop)

## 🥼 Installation

For my machine, simply cloning the repository and running the installation script should be enough to set up the environment:

```sh
git clone --recurse-submodules https://github.com/tonigineer/dotfiles.git ~/Dotfiles
cd ~/Dotfiles/scripts/install.sh all
```

> [!IMPORTANT]
> Some parts of this configuration, such as monitor names, are specific to my setup. As a result, it’s recommended to install the configuration manually, so you can tailor it to your system. Plus, you’ll likely pick up useful knowledge along the way.

> [!NOTE]
> Additionally, this configuration is designed for a 4K display. If you’re using a different resolution, certain aspects might behave differently or even break. For instance, tools like [hyprlock](https://github.com/hyprwm/hyprlock) rely on pixel-perfect positioning from anchors, so adjustments may be necessary.
