# EWW Monitor Configuration Reference
# Basado en monitors.conf de Hyprland

# Monitor Principal (DP-3)
# Resolución: 1920x1080@75
# Escala: 1.0
# Resolución lógica: 1920x1080
# Ancho EWW recomendado: 99.5% = ~1910px

# Monitor Secundario (HDMI-A-1) 
# Resolución física: 1366x768@60
# Escala: 0.67
# Resolución lógica: 1366÷0.67 = 2039x768÷0.67 = 2039x1146
# Ancho EWW recomendado: 99% = 2019px
# Alto EWW recomendado: Para ventanas flotantes considerar 1146px total

# Configuraciones EWW implementadas:
# bar_widget_0: width "99.5%" (auto-ajuste en monitor principal)
# bar_widget_1: width "2019px" (valor absoluto para monitor escalado)

# Notas:
# - El escalado 0.67 hace que el contenido se vea más pequeño físicamente
# - Pero aumenta el espacio lógico disponible para las aplicaciones
# - EWW usa el espacio lógico, por eso necesitamos el valor más grande

# Cálculo de verificación:
# 1366 ÷ 0.67 = 2039.4 ≈ 2039px
# 2039 × 0.99 = 2018.61 ≈ 2019px