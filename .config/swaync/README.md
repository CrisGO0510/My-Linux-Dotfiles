# SwayNotificationCenter - Configuración Azure Dreams

## Instalación Completada ✅

Se ha configurado exitosamente SwayNotificationCenter con la estética Azure Dreams que coincide con tu dotfiles.

### Archivos creados/modificados:

#### Configuración SwayNC:
- `~/.config/swaync/config.json` - Configuración principal
- `~/.config/swaync/style.css` - Estilos Azure Dreams  
- `~/.config/swaync/icons/` - Iconos personalizados SVG

#### Integración Hyprland:
- `~/.config/hypr/hyprland.conf` - Daemon swaync agregado
- `~/.config/hypr/keybindings.conf` - Keybindings agregados:
  - `Super + N`: Abrir/cerrar centro de notificaciones
  - `Super + Shift + N`: Toggle Do Not Disturb

#### Widget Eww:
- `~/.config/eww/eww.yuck` - Widget de notificaciones agregado
- `~/.config/eww/eww.scss` - Estilos del widget

#### Scripts actualizados:
- `Scripts/hypr/volumecontrol.sh` - Soporte para swaync
- `Scripts/installer/hyprland-apps.sh` - Paquete swaync agregado

### Características implementadas:

✅ **Centro de notificaciones deslizable**
✅ **Gestión avanzada** (DND, prioridades, filtros) 
✅ **Acciones interactivas** en notificaciones
✅ **Animaciones suaves** con efectos glassmorphism
✅ **Widget Eww** con contador de notificaciones
✅ **Keybindings** integrados en Hyprland
✅ **Iconos personalizados** con colores Azure Dreams

### Para activar la configuración:

1. **Instalar swaync** (si no se instaló automáticamente):
   ```bash
   sudo pacman -S swaync
   ```

2. **Reiniciar Hyprland** o recargar configuración:
   ```bash
   hyprctl reload
   ```

3. **Reiniciar Eww**:
   ```bash
   eww reload
   ```

### Controles disponibles:

- **Super + N**: Abrir/cerrar centro de notificaciones
- **Super + Shift + N**: Activar/desactivar modo No Molestar  
- **Clic en widget Eww**: Abrir centro de notificaciones
- **Clic derecho en widget Eww**: Toggle DND

### Pruebas:

```bash
# Enviar notificación de prueba
notify-send "Test" "SwayNC funciona correctamente!"

# Verificar estado del daemon
swaync-client --help
```

### Personalización adicional:

Los estilos se pueden ajustar en:
- Colores: `~/.config/swaync/style.css` (variables CSS al inicio)
- Comportamiento: `~/.config/swaync/config.json`
- Widget: `~/.config/eww/eww.scss` (sección .notifications)

¡La configuración está lista para usar! 🎉