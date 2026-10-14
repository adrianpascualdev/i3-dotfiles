#!/usr/bin/env bash
# Instalador de dotfiles i3 para Arch, Debian/Ubuntu y Fedora.
set -Eeuo pipefail

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mAVISO:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die 'Ejecuta el script como usuario normal, no con sudo.'
command -v sudo >/dev/null || die 'Se necesita sudo para instalar paquetes.'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/configs"
[[ -d "$CONFIG_SRC" ]] || die "No existe $CONFIG_SRC. Ejecuta install.sh desde el repositorio completo."

[[ -r /etc/os-release ]] || die 'No se encuentra /etc/os-release.'
# shellcheck disable=SC1091
source /etc/os-release
DISTRO="${ID,,}"
LIKE=" ${ID_LIKE:-} "
if [[ "$DISTRO" == arch || "$LIKE" == *' arch '* ]]; then
  PM=pacman
elif [[ "$DISTRO" =~ ^(debian|ubuntu|linuxmint|pop|elementary|kali)$ || "$LIKE" == *' debian '* || "$LIKE" == *' ubuntu '* ]]; then
  PM=apt
elif [[ "$DISTRO" =~ ^(fedora|nobara)$ || "$LIKE" == *' fedora '* ]]; then
  PM=dnf
else
  die "Distribución no soportada automáticamente: $DISTRO (${ID_LIKE:-sin ID_LIKE})."
fi
command -v "$PM" >/dev/null || die "No se encuentra el gestor de paquetes $PM."

log "Distribución: ${PRETTY_NAME:-$DISTRO} | Gestor: $PM"
log "Repositorio: $SCRIPT_DIR"

# Algunos paquetes opcionales cambian de nombre o no están disponibles según versión/repositorios.
case "$PM" in
  pacman)
    REQUIRED=(i3-wm alacritty picom polybar rofi flameshot fish nemo git xorg-xrandr xorg-xsetroot feh)
    OPTIONAL=(ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd nemo-fileroller nemo-share)
    sudo pacman -Sy --needed --noconfirm "${REQUIRED[@]}" || die 'Falló la instalación de paquetes esenciales.'
    ;;
  apt)
    REQUIRED=(i3 alacritty picom polybar rofi flameshot fish nemo git x11-xserver-utils feh)
    OPTIONAL=(fonts-jetbrains-mono nemo-fileroller nemo-share)
    sudo apt-get update || die 'No se pudo actualizar el índice de APT.'
    sudo apt-get install -y "${REQUIRED[@]}" || die 'Falló la instalación de paquetes esenciales. Revisa los repositorios habilitados.'
    ;;
  dnf)
    REQUIRED=(i3 alacritty picom polybar rofi flameshot fish nemo git xrandr feh)
    OPTIONAL=(jetbrains-mono-fonts nemo-fileroller nemo-share)
    sudo dnf install -y "${REQUIRED[@]}" || die 'Falló la instalación de paquetes esenciales. Revisa los repositorios habilitados.'
    ;;
esac

log 'Instalando paquetes opcionales disponibles'
for pkg in "${OPTIONAL[@]}"; do
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm "$pkg" || warn "No se pudo instalar el opcional: $pkg" ;;
    apt) sudo apt-get install -y "$pkg" || warn "No se pudo instalar el opcional: $pkg" ;;
    dnf) sudo dnf install -y "$pkg" || warn "No se pudo instalar el opcional: $pkg" ;;
  esac
done

# Evitar que un xrandr de una máquina concreta rompa la disposición de otra.
# La configuración original se copia intacta; el usuario debe revisar monitores antes de reiniciar i3.
if [[ -f "$CONFIG_SRC/i3/config" ]] && grep -Eq '(^|[[:space:]])xrandr[[:space:]]+--output' "$CONFIG_SRC/i3/config"; then
  warn 'Tu configuración de i3 contiene un comando xrandr específico de monitores.'
  warn 'Revisa ~/.config/i3/config antes de iniciar o recargar i3 en otro ordenador.'
fi

BACKUP_ROOT="$HOME/.config-backup/i3-dotfiles-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$HOME/.config"

log 'Copiando configuraciones (con copias de seguridad)'
for name in i3 alacritty picom polybar rofi flameshot fish; do
  src="$CONFIG_SRC/$name"
  dst="$HOME/.config/$name"
  if [[ ! -d "$src" ]]; then
    warn "No existe configs/$name; se omite."
    continue
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP_ROOT"
    mv -- "$dst" "$BACKUP_ROOT/$name"
    log "Respaldo: $dst -> $BACKUP_ROOT/$name"
  fi
  cp -a -- "$src" "$dst"
  # Scripts de arranque de Polybar deben ser ejecutables.
  if [[ -f "$dst/launch.sh" && "$name" == polybar ]]; then
    chmod u+x "$dst/launch.sh"
  fi
done

# Detectar fuentes que la configuración de Alacritty pueda requerir.
if [[ -f "$HOME/.config/alacritty/alacritty.toml" ]]; then
  if grep -q 'CaskaydiaCove' "$HOME/.config/alacritty/alacritty.toml" && ! fc-list : family 2>/dev/null | grep -qi 'CaskaydiaCove'; then
    warn 'Alacritty pide CaskaydiaCove, pero no aparece instalada. Instala esa Nerd Font manualmente si tu distribución no la incluye.'
  fi
fi

log 'Instalación completada'
printf 'Configuraciones: %s/.config\n' "$HOME"
if [[ -d "$BACKUP_ROOT" ]]; then printf 'Copias de seguridad: %s\n' "$BACKUP_ROOT"; fi
printf '\nSiguientes pasos:\n'
printf '  1. Revisa ~/.config/i3/config (monitores, rutas y programas externos).\n'
printf '  2. Valida la configuración: i3 -C -c "$HOME/.config/i3/config"\n'
printf '  3. Cierra sesión e inicia i3 desde tu gestor de sesiones.\n'
printf '  4. Para usar Fish como shell predeterminada, ejecuta manualmente: chsh -s "$(command -v fish || printf /usr/bin/fish)"\n'
