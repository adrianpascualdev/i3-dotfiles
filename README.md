# i3 Dotfiles

Configuraciones personales para un escritorio **i3wm** con **Alacritty, Picom, Polybar, Rofi, Flameshot y Fish**, además de un instalador Bash para distribuciones basadas en **Arch Linux, Debian/Ubuntu y Fedora**.

> **Compatibilidad:** el instalador reconoce estas familias de distribuciones, pero la disponibilidad de paquetes y el comportamiento de algunas configuraciones pueden variar según la versión, los repositorios y el hardware. No se garantiza que funcione sin ajustes en todas las instalaciones.

## Captura de pantalla

Puedes añadir aquí una captura de tu escritorio cuando tengas el repositorio publicado.

## Contenido del repositorio

```text
i3-dotfiles/
├── install.sh
├── README.md
└── configs/
    ├── alacritty/
    ├── fish/
    ├── flameshot/
    ├── i3/
    ├── picom/
    ├── polybar/
    └── rofi/
```

| Componente | Función |
| --- | --- |
| i3wm | Gestor de ventanas en mosaico para X11 |
| Alacritty | Emulador de terminal |
| Picom | Compositor para X11 |
| Polybar | Barra de estado |
| Rofi | Lanzador de aplicaciones |
| Flameshot | Capturas de pantalla |
| Fish | Shell interactiva |
| Nemo | Gestor de archivos instalado como dependencia de uso |

El instalador también intenta instalar utilidades como `git`, `feh` y herramientas de `xrandr`, además de algunas fuentes y complementos opcionales.

## Requisitos

- Una instalación de Linux con **X11** para utilizar i3wm y los componentes de escritorio previstos.
- Una cuenta de usuario normal con acceso a `sudo`.
- Conexión a Internet para descargar paquetes.
- `bash` y un gestor de paquetes compatible (`pacman`, `apt` o `dnf`).
- Los archivos `install.sh` y `configs/` juntos dentro del repositorio.

## Instalación

### 1. Clonar el repositorio

Sustituye `TU_USUARIO` por tu nombre de usuario de GitHub:

```bash
git clone https://github.com/TU_USUARIO/i3-dotfiles.git
cd i3-dotfiles
```

Si `git` no está instalado, instálalo primero con el gestor de paquetes de tu distribución o descarga el repositorio como ZIP.

### 2. Revisar los ajustes específicos del equipo

**Antes de instalar**, revisa `configs/i3/config`, especialmente las líneas que ejecuten `xrandr`, los nombres de monitores, las frecuencias de refresco y las rutas absolutas. Una configuración creada para un equipo con salidas `DP-0` y `HDMI-0` puede no funcionar en otro.

Comprueba los nombres reales de tus pantallas con:

```bash
xrandr --query
```

También conviene revisar los scripts de Polybar, las rutas de fondos de pantalla y los comandos de los atajos de teclado.

### 3. Ejecutar el instalador

```bash
bash install.sh
```

**No ejecutes `sudo bash install.sh`.** El instalador debe ejecutarse como usuario normal y pedirá `sudo` cuando necesite instalar paquetes.

El instalador:

1. Detecta si el sistema usa `pacman`, `apt` o `dnf`.
2. Instala los paquetes principales y prueba algunos paquetes opcionales.
3. Muestra una advertencia si detecta una línea `xrandr` específica en i3.
4. Guarda las carpetas de configuración existentes en una copia de seguridad.
5. Copia las carpetas de `configs/` a `~/.config/`.
6. Da permiso de ejecución a `~/.config/polybar/launch.sh`, si existe.

**Atención:** el script **copia intacta** la configuración de i3, incluidas las líneas de monitores. Solo avisa de posibles incompatibilidades: **no las corrige automáticamente**.

## Después de instalar

Valida la configuración de i3:

```bash
i3 -C -c "$HOME/.config/i3/config"
```

Si aparecen errores, corrígelos antes de reiniciar la sesión. Para usar el entorno, cierra sesión y selecciona **i3** en el gestor de inicio de sesión.

Si ya estás usando i3 y la configuración es válida, puedes recargarla con:

```bash
i3-msg reload
```

Para establecer Fish como shell predeterminada, **solo si quieres hacerlo**:

```bash
chsh -s "$(command -v fish)"
```

Cierra sesión y vuelve a entrar para que el cambio de shell tenga efecto.

## Fuentes y apariencia

La configuración de Alacritty puede depender de una fuente Nerd Font, como **CaskaydiaCove Nerd Font Mono**, y del archivo de tema `catppuccin-mocha.toml` incluido en `configs/alacritty/`.

Para ver las fuentes disponibles:

```bash
fc-list : family | grep -i caskaydia
```

En Arch Linux, el instalador intenta instalar `ttf-cascadia-code-nerd`. En Debian/Ubuntu y Fedora puede ser necesario instalar manualmente una Nerd Font compatible y ajustar el nombre de la familia en `~/.config/alacritty/alacritty.toml`.

## Copias de seguridad y restauración

Si ya existía una carpeta como `~/.config/i3`, el instalador **la mueve** antes de copiar la nueva. Los respaldos se guardan en una ruta similar a:

```text
~/.config-backup/i3-dotfiles-AAAAMMDD-HHMMSS-PID/
```

Para restaurar i3, por ejemplo, localiza primero el respaldo correcto y ejecuta:

```bash
mv "$HOME/.config/i3" "$HOME/.config/i3.instalado"
cp -a "$HOME/.config-backup/i3-dotfiles-AAAAMMDD-HHMMSS-PID/i3" "$HOME/.config/i3"
```

Sustituye `AAAAMMDD-HHMMSS-PID` por el nombre real del respaldo. No borres los respaldos hasta verificar que todo funciona.

## Actualizar las configuraciones

Para traer cambios nuevos desde GitHub:

```bash
cd ~/i3-dotfiles
git pull
```

Para volver a copiar las configuraciones actualizadas y ejecutar de nuevo la instalación de paquetes:

```bash
bash install.sh
```

**Importante:** el instalador no sincroniza archivos individuales: reemplaza cada carpeta de destino completa, moviendo antes la carpeta anterior al respaldo. Si modificaste configuraciones directamente en `~/.config/`, guarda esos cambios en el repositorio antes de reinstalar.

## Problemas frecuentes

**Alacritty muestra una fuente incorrecta:** verifica el nombre con `fc-list : family` y `fc-match "CaskaydiaCove Nerd Font Mono"`; después ajusta la familia en `alacritty.toml`.

**i3 indica `Duplicate keybinding`:** busca atajos repetidos en `~/.config/i3/config`, por ejemplo `grep -n 'Print' ~/.config/i3/config`, y vuelve a validar con `i3 -C`.

**Polybar no aparece:** comprueba que `~/.config/polybar/launch.sh` existe, es ejecutable y utiliza nombres de pantalla válidos. Prueba a ejecutarlo manualmente para ver errores.

**La pantalla secundaria no funciona:** revisa `xrandr --query` y adapta la línea de monitores en la configuración de i3.

**Un paquete no está disponible:** algunos paquetes son opcionales y otros pueden depender de repositorios adicionales. Revisa la salida del instalador y los repositorios habilitados de tu distribución.

## Seguridad y publicación

Antes de subir tus dotfiles a un repositorio público, revisa todos los archivos, incluidos los scripts, para asegurarte de que no contienen **tokens, contraseñas, claves privadas, rutas sensibles o información personal**.

Este proyecto está pensado para configuraciones personales: lee `install.sh` y adapta las opciones a tu equipo antes de ejecutarlo.

## Licencia

Añade un archivo `LICENSE` si quieres indicar expresamente los permisos de reutilización y distribución del proyecto.
