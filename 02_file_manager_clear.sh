#!/bin/bash
# =====================================================================
# Script: 02_file_manager_cleaner.sh
# Descripción: Gestiona archivos, limpia temporales y genera auditoría
# Autor: Engels Peña Hidalgo & Guzman Mercado Pool Martin
# Fecha: Junio 2026
# =====================================================================

# Configuración
DIR_TRABAJO="./temp_automatizacion"
LOG_CRUDO="log_ejecucion_crudo.txt"
LOG_AUDITORIA="auditoria_eliminaciones_$(date +%Y%m%d_%H%M%S).log"
REPORTE_FINAL="reporte_final_$(date +%Y%m%d).txt"
DIAS_ANTIGUEDAD=0
USUARIO_EJECUCION=$(whoami)
FECHA_INICIO=$(date '+%Y-%m-%d %H:%M:%S')

# 1. Preparación del entorno
mkdir -p "$DIR_TRABAJO"
echo "Creando archivos de prueba..."
for i in {1..5}; do
    touch "$DIR_TRABAJO/archivo_viejo_$i.tmp"
    touch "$DIR_TRABAJO/archivo_reciente_$i.log"
done

# Cambiar permisos con bucle for
for archivo in "$DIR_TRABAJO"/*; do
    chmod 644 "$archivo"
done

# 2. Cabecera del log de auditoría
echo "================================================================" > "$LOG_AUDITORIA"
echo "  LOG DE AUDITORÍA - ELIMINACIÓN DE ARCHIVOS TEMPORALES" >> "$LOG_AUDITORIA"
echo "================================================================" >> "$LOG_AUDITORIA"
echo "Fecha de Inicio: $FECHA_INICIO" >> "$LOG_AUDITORIA"
echo "Usuario Ejecutor: $USUARIO_EJECUCION" >> "$LOG_AUDITORIA"
echo "Directorio Analizado: $DIR_TRABAJO" >> "$LOG_AUDITORIA"
echo "Criterio de Eliminación: Archivos .tmp con más de $DIAS_ANTIGUEDAD días" >> "$LOG_AUDITORIA"
echo "Hostname: $(hostname)" >> "$LOG_AUDITORIA"
echo "================================================================" >> "$LOG_AUDITORIA"
echo "" >> "$LOG_AUDITORIA"

# 3. Búsqueda y eliminación con auditoría
echo "🔍 Buscando archivos .tmp antiguos..."
ARCHIVOS_ELIMINADOS=0
BYTES_LIBERADOS=0

while IFS= read -r archivo; do
    if [ -f "$archivo" ]; then
        NOMBRE_ARCHIVO=$(basename "$archivo")
        TAMANO=$(stat -c%s "$archivo" 2>/dev/null || echo "0")
        FECHA_MOD=$(stat -c%y "$archivo" 2>/dev/null | cut -d'.' -f1)
        FECHA_ELIM=$(date '+%Y-%m-%d %H:%M:%S')
        
        if rm -f "$archivo" 2>/dev/null; then
            ARCHIVOS_ELIMINADOS=$((ARCHIVOS_ELIMINADOS + 1))
            BYTES_LIBERADOS=$((BYTES_LIBERADOS + TAMANO))
            
            echo "----------------------------------------------------------------" >> "$LOG_AUDITORIA"
            echo "[ELIMINADO] Archivo: $NOMBRE_ARCHIVO" >> "$LOG_AUDITORIA"
            echo "  Ruta Completa: $archivo" >> "$LOG_AUDITORIA"
            echo "  Tamaño: $TAMANO bytes" >> "$LOG_AUDITORIA"
            echo "  Fecha de Modificación: $FECHA_MOD" >> "$LOG_AUDITORIA"
            echo "  Fecha de Eliminación: $FECHA_ELIM" >> "$LOG_AUDITORIA"
            echo "  Eliminado por: $USUARIO_EJECUCION" >> "$LOG_AUDITORIA"
            echo "  Estado: ÉXITO" >> "$LOG_AUDITORIA"
            echo "----------------------------------------------------------------" >> "$LOG_AUDITORIA"
            
            echo "  ✅ Eliminado: $NOMBRE_ARCHIVO ($TAMANO bytes)"
        else
            echo "----------------------------------------------------------------" >> "$LOG_AUDITORIA"
            echo "[FALLO] Archivo: $NOMBRE_ARCHIVO" >> "$LOG_AUDITORIA"
            echo "  Ruta: $archivo" >> "$LOG_AUDITORIA"
            echo "  Fecha de Intento: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_AUDITORIA"
            echo "  Estado: ERROR - Permiso denegado o archivo bloqueado" >> "$LOG_AUDITORIA"
            echo "----------------------------------------------------------------" >> "$LOG_AUDITORIA"
            
            echo "  ❌ Error al eliminar: $NOMBRE_ARCHIVO"
        fi
    fi
done < <(find "$DIR_TRABAJO" -name "*.tmp" -mtime +$DIAS_ANTIGUEDAD -print)

# 4. Resumen en log de auditoría
echo "" >> "$LOG_AUDITORIA"
echo "================================================================" >> "$LOG_AUDITORIA"
echo "  RESUMEN DE LA EJECUCIÓN" >> "$LOG_AUDITORIA"
echo "================================================================" >> "$LOG_AUDITORIA"
echo "Total Archivos Eliminados: $ARCHIVOS_ELIMINADOS" >> "$LOG_AUDITORIA"
echo "Total Bytes Liberados: $BYTES_LIBERADOS bytes" >> "$LOG_AUDITORIA"
FECHA_FIN=$(date '+%Y-%m-%d %H:%M:%S')
echo "Fecha de Finalización: $FECHA_FIN" >> "$LOG_AUDITORIA"
echo "================================================================" >> "$LOG_AUDITORIA"

# 5. Lógica de reintentos con while
ARCHIVO_BLOQUEADO="$DIR_TRABAJO/bloqueado.tmp"
touch "$ARCHIVO_BLOQUEADO"
MAX_REINTENTOS=3
INTENTO=1
EXITO=0

echo "Intentando eliminar archivo bloqueado..."
while [ $INTENTO -le $MAX_REINTENTOS ]; do
    if rm -f "$ARCHIVO_BLOQUEADO" 2>/dev/null; then
        EXITO=1
        break
    else
        echo "Intento $INTENTO fallido. Reintentando..."
        INTENTO=$((INTENTO+1))
        sleep 1
    fi
done

# 6. Generación de Log Crudo
echo "Fecha: $(date) | Accion: Limpieza_Temp | Estado: OK | Detalle: $ARCHIVOS_ELIMINADOS archivos" > "$LOG_CRUDO"
echo "Fecha: $(date) | Accion: Permisos | Estado: OK | Detalle: 10 archivos" >> "$LOG_CRUDO"
echo "Fecha: $(date) | Accion: Espacio_Liberado | Estado: OK | Detalle: $BYTES_LIBERADOS bytes" >> "$LOG_CRUDO"
if [ $EXITO -eq 1 ]; then
    echo "Fecha: $(date) | Accion: Desbloqueo | Estado: OK | Detalle: Intento $INTENTO" >> "$LOG_CRUDO"
else
    echo "Fecha: $(date) | Accion: Desbloqueo | Estado: ERROR | Detalle: Fallo tras $MAX_REINTENTOS intentos" >> "$LOG_CRUDO"
fi

# 7. Procesamiento con SED
sed -i 's/ERROR/FALLO_CRITICO/g' "$LOG_CRUDO"
sed -i 's/OK/EXITOSO/g' "$LOG_CRUDO"

# 8. Procesamiento con AWK para reporte final
awk -F'|' '
BEGIN {
    print "================================================================" > "'"$REPORTE_FINAL"'"
    print " REPORTE FINAL DE AUTOMATIZACIÓN - GESTIÓN DE ARCHIVOS" >> "'"$REPORTE_FINAL"'"
    print "================================================================" >> "'"$REPORTE_FINAL"'"
    exitosos=0; fallos=0;
}
{
    if ($3 ~ /EXITOSO/) exitosos++;
    if ($3 ~ /FALLO/) fallos++;
    print ">> " $2 " -> " $3 " (" $4 ")" >> "'"$REPORTE_FINAL"'";
}
END {
    print "----------------------------------------------------------------" >> "'"$REPORTE_FINAL"'"
    print "RESUMEN EJECUCIÓN:" >> "'"$REPORTE_FINAL"'"
    print "Total Acciones Exitosas: " exitosos >> "'"$REPORTE_FINAL"'"
    print "Total Fallos: " fallos >> "'"$REPORTE_FINAL"'"
    print "Fecha de Cierre: " strftime("%Y-%m-%d %H:%M:%S", systime()) >> "'"$REPORTE_FINAL"'"
    print "================================================================" >> "'"$REPORTE_FINAL"'"
}' "$LOG_CRUDO"

echo ""
echo "✅ Gestión de archivos completada."
echo "📊 Archivos eliminados: $ARCHIVOS_ELIMINADOS"
echo "💾 Espacio liberado: $BYTES_LIBERADOS bytes"
echo "📄 Reporte final en: $REPORTE_FINAL"
echo "🔍 Log de auditoría detallado en: $LOG_AUDITORIA"
