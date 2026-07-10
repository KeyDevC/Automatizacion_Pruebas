#!/bin/bash
# =====================================================================
# Script: 01_sys_check.sh
# Descripción: Verifica el estado del sistema y genera reporte
# Fecha: Junio 2026
# =====================================================================

# Variables del sistema
USUARIO=$(whoami)
HOSTNAME=$(hostname)
SO=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
MEMORIA_LIBRE=$(free -m | awk 'NR==2 {print $7}')
FECHA=$(date '+%Y-%m-%d %H:%M:%S')
USO_DISCO=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
UMBRAL_DISCO=80
ARCHIVO_REPORTE="reporte_sistema_$(date +%Y%m%d_%H%M).txt"

# Generar reporte
echo "==================================================" > "$ARCHIVO_REPORTE"
echo " REPORTE DE ESTADO DEL SISTEMA - $FECHA" >> "$ARCHIVO_REPORTE"
echo "==================================================" >> "$ARCHIVO_REPORTE"
echo "Usuario Actual: $USUARIO" >> "$ARCHIVO_REPORTE"
echo "Hostname: $HOSTNAME" >> "$ARCHIVO_REPORTE"
echo "Sistema Operativo: $SO" >> "$ARCHIVO_REPORTE"
echo "Memoria Libre: $MEMORIA_LIBRE MB" >> "$ARCHIVO_REPORTE"
echo "Uso de Disco Raíz: $USO_DISCO%" >> "$ARCHIVO_REPORTE"
echo "--------------------------------------------------" >> "$ARCHIVO_REPORTE"

# Estructura de control if
if [ "$USO_DISCO" -gt "$UMBRAL_DISCO" ]; then
    echo "[ALERTA CRÍTICA] El espacio en disco supera el ${UMBRAL_DISCO}%." >> "$ARCHIVO_REPORTE"
else
    echo "[INFO] El espacio en disco está dentro de los parámetros normales." >> "$ARCHIVO_REPORTE"
fi

echo "==================================================" >> "$ARCHIVO_REPORTE"
echo "Estado Final: Revisión completada." >> "$ARCHIVO_REPORTE"

echo "✅ Revisión de sistema completada. Reporte guardado en: $ARCHIVO_REPORTE"

