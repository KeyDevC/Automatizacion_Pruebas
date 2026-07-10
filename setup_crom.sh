#!/bin/bash
# =====================================================================
# Script: setup_cron.sh
# Descripción: Configura tareas programadas en cron
# Fecha: Junio 2026
# =====================================================================

# Obtener ruta absoluta del proyecto
SCRIPT_DIR=$(pwd)

echo "📅 Configurando tareas programadas en cron..."

# Validación para evitar duplicados
if crontab -l 2>/dev/null | grep -q "01_sys_check.sh"; then
    echo "⚠️  Las tareas ya están configuradas. No se duplicarán."
else
    # Configurar tareas en cron
    (crontab -l 2>/dev/null; \
    echo "0 2 * * * $SCRIPT_DIR/01_sys_check.sh >> /var/log/sys_check_cron.log 2>&1"; \
    echo "0 3 * * * $SCRIPT_DIR/02_file_manager_cleaner.sh >> /var/log/file_manager_cron.log 2>&1") | crontab -
    
    echo "✅ Tareas de cron configuradas exitosamente."
fi

# Mostrar tareas programadas
echo ""
echo " Tareas programadas actuales:"
crontab -l | grep "proyecto_automatizacion"

echo ""
echo "📝 Los logs se guardarán en:"
echo "   - /var/log/sys_check_cron.log"
echo "   - /var/log/file_manager_cron.log"
