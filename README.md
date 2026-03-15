# Dotfiles

<div align="right">🖕</div>

<div align="center">
  <img src="https://img.shields.io/github/last-commit/tonigineer/.dotfiles?style=for-the-badge&logo=github&color=a6da95&logoColor=D9E0EE&labelColor=302D41"/>
  <img src="https://img.shields.io/github/repo-size/tonigineer/.dotfiles?style=for-the-badge&logo=dropbox&color=7dc4e4&logoColor=D9E0EE&labelColor=302D41"/>
</div>

<div align="center">
  <a href="https://github.com/tonigineer/zsh"><img src="https://img.shields.io/badge/Zsh_Config-181717?style=for-the-badge&logo=github&logoColor=white"/></a>
  <a href="https://github.com/tonigineer/nvim"><img src="https://img.shields.io/badge/Neovim_Config-181717?style=for-the-badge&logo=github&logoColor=white"/></a>
</div>

<br>

<div align="center">
  <p><em>“A minimalist, workflow-focused desktop configuration emphasizing speed, clarity, and visual consistency.”

— Slop</em></p>
</div>

## What's happening

I've fully transitioned to [Noctalia Shell](https://github.com/noctalia-dev) and [Zen Browser](https://zen-browser.app/), though the Caelestia configuration is still versioned. Below is a ~~walkthrough of my workflow~~ along with a demo of `wallcards`, a wallpaper selector, which I plan to convert into a [Noctalia Shell plugin](https://github.com/noctalia-dev/noctalia-plugins). This quickshell-based application is inspired by people on [unixporn](https://github.com/liixini/skwd).

https://github.com/user-attachments/assets/9ffbc83d-95e5-4dcd-a834-7bd224211b55

## Installation

For setup, use the provided Bash installers. Execute [./scripts/install.sh](./scripts/install.sh)

```bash
git clone https://github.com/tonigineer/dotfiles.git ~/Dotfiles
cd ~/Dotfiles

./scripts/install.sh
```

> [!NOTE]
> See the Arch Linux installation documentation in [./docs](./docs) or refer directly to the [ArchWiki](https://wiki.archlinux.org/title/Main_page).

## Features

- [x] Compositor: [Hyprland](https://github.com/hyprwm/Hyprland)
- [x] Shells: [Noctalia](https://github.com/noctalia-dev/noctalia-shell) and ~~[Caelestia](https://github.com/caelestia-dots/shell) (aesthetics)~~
- [x] Editors: [Zed](https://zed.dev/) and [Neovim](https://neovim.io/)
- [x] Terminal: [Kitty](https://sw.kovidgoyal.net/kitty/) with [ZSH](https://www.zsh.org/); tools include Yazi, fastfetch, cava, etc.
- [x] GPU: NVIDIA RTX 40-series; [Gamescope](https://github.com/ValveSoftware/gamescope) and [MangoHud](https://github.com/flightlessmango/MangoHud) supported
- [x] Dynamic color theming via both shells for multiple applications, including [Discord](https://github.com/Vencord/Vesktop)

> [!IMPORTANT]
> Hyprland ecosystem — [Hyprpaper](https://github.com/hyprwm/hyprpaper), [Hypridle](https://github.com/hyprwm/hypridle), and [Hyprlock](https://github.com/hyprwm/hyprlock/) are not used; equivalent functionality is provided by the shells.

## Keymaps

- <kbd>SUPER</kbd> + <kbd>RETURN</kbd> — Open Kitty terminal
- <kbd>SUPER</kbd> + <kbd>E</kbd> — Open Thunar file manager
- <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>E</kbd> — Open Yazi file manager in terminal
- <kbd>SUPER</kbd> + <kbd>R</kbd> — Open launcher (application menu; varies by shell)
- <kbd>SUPER</kbd> + <kbd>S</kbd> — Open control center/sidebar (system controls; varies by shell)
- <kbd>SUPER</kbd> + <kbd>D</kbd> — Open control dashboard (Caelestia only)

- <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>C</kbd> — Close active window
- <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>Q</kbd> — Open powermenu (varies by shell)
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>Y</kbd> — Cast currently playing media URL to MPV player
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>N</kbd> — Start Netflix App (brave app functionality)
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>U</kbd> — Start system update (`yay -Syu`)
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>L</kbd> — Lock screen (varies by shell)
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>S</kbd> — Screenshot tool with walker
- <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>W</kbd> — Wallcards (wallpaper changer)
- <kbd>SUPER</kbd> + <kbd>F1</kbd> — Toggle Gamemode
- <kbd>SUPER</kbd> + <kbd>F9</kbd> — Select `ARD|ZDF|Phoenix` for german television streaming (`mpv`)

<!--Custom commands for the *Caelestia shell* launcher are:

- [x] `:Switch Shell` to change to *Noctalia Shell*
- [x] `:Live Wallpaper` to open a fuzzy list to select a live wallpaper (`mpvpaper`)
- [x] `:Live Stream ARD|ZDF|Phoenix` for german television streaming (`mpv`)-->


## Legacy

I have experimented with custom shells using [eww](https://https://github.com/elkowar/eww), [AGS](https://github.com/Aylur/ags), [Fabric](https://github.com/Fabric-Development/fabric), and [Quickshell](https://quickshell.org/). The [Quickshell](https://quickshell.org/) configurations used here are stable and well maintained, making them a time-efficient choice. Past experiments are included below for reference.
<div align="center">
  <img src="./assets/impressions/current-caelestia-dark.png" width="400"/>
  <img src="./assets/impressions/current-noctalia-dark.png" width="400"/>
</div>
<div align="center">
  <img src="./assets/impressions/current-caelestia-light.png" width="400"/>
</div>

<div align="center">
  <img src="./assets/impressions/legacy-third.png" width="400" alt="Shell with Elkowars Wacky Widgets (eww)"/>
  <img src="./assets/impressions/legacy-second.png" width="400"/>
</div>
<div align="center">
  <img src="./assets/impressions/legacy-first-workflow.gif" width="400"/>
  <img src="./assets/impressions/legacy-first-wall.png" width="400"/>
</div>
<div align="center">
  <img src="./assets/impressions/legacy-first-rofi.png" width="400"/>
</div>

---

<div align="center">
  <p>Built on <strong>Arch Linux</strong> • Powered by <strong>Hyprland</strong> • Inspired by <strong>r/unixporn</strong></p>
</div>
