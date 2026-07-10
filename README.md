Automatización de Tareas de Administración de Servidores Linux
📌 Descripción del Proyecto
Este proyecto desarrolla scripts Bash para automatizar tareas críticas de administración en servidores Linux, abordando la problemática de ineficiencias operativas en el área de TI de una empresa mediana.
⚠️ Descripción del Problema
El área de TI de una empresa mediana enfrenta ineficiencias operativas debido a la ejecución manual de tareas básicas de administración en sus servidores Linux. Actualmente, los administradores del sistema dedican tiempo considerable a actividades repetitivas como:
Revisar el uso de disco en particiones críticas
Organizar y limpiar archivos temporales acumulados en directorios específicos
Generar reportes simples sobre el estado del sistema y de los archivos gestionados
Esta falta de automatización ha provocado:
Alto riesgo de errores humanos (eliminar archivos incorrectos o no liberar espacio a tiempo)
Demoras en las operaciones, afectando la disponibilidad de servicios
Dificultad para mantener trazabilidad de las acciones realizadas en los servidores
🛠️ Requisitos del Sistema
Sistema Operativo: Ubuntu Linux (20.04/22.04/24.04)
Permisos: Usuario estándar con permisos de lectura/escritura
Herramientas: Bash, cron, sed, awk, find

## 📂 Contenido del Proyecto

El sistema está compuesto por tres scripts principales:

| Script | Descripción | Frecuencia Sugerida |
| :--- | :--- | :--- |
| `01_sys_check.sh` | Verifica el estado del sistema (Memoria, CPU/Disco) y genera un reporte de estado. | Diario (Madrugada) |
| `02_file_manager_cleaner.sh` | Busca y elimina archivos temporales antiguos, maneja reintentos de desbloqueo y genera una auditoría formateada con `sed` y `awk`. | Diario (Posterior al chequeo) |
| `setup_cron.sh` | Automatiza la instalación y configuración de los dos scripts anteriores en el `crontab` del usuario. | Ejecución única (Setup) |

---

## 🛠️ Detalles de los Scripts

### 1. Monitoreo de Sistema (`01_sys_check.sh`)
Este script recopila información clave de la máquina para prevenir problemas de almacenamiento o rendimiento.
* **Métricas capturadas:** Usuario ejecutor, Hostname, Distribución del Sistema Operativo, Memoria RAM libre y Uso del disco raíz (`/`).
* **Alertas:** Si el uso del disco supera el **80%** (umbral configurable), registra una `[ALERTA CRÍTICA]` en el reporte. De lo contrario, marca un estado normal.
* **Salida:** Genera un archivo con formato `reporte_sistema_AAAAMMDD_HHMM.txt`.

### 2. Gestor y Limpiador de Archivos (`02_file_manager_cleaner.sh`)
Un potente script de mantenimiento de espacio en disco enfocado en la seguridad y la auditoría.
* **Simulación/Prueba:** Genera un entorno controlado de pruebas (`./temp_automatizacion`) con archivos `.tmp` y `.log`.
* **Auditoría rigurosa:** Almacena de manera estructurada qué archivos se eliminaron, su tamaño exacto, la fecha de modificación y si la operación fue un éxito o un fallo.
* **Lógica de Resiliencia:** Si detecta un archivo bloqueado, implementa un bucle de hasta 3 reintentos antes de desistir.
* **Post-Procesamiento:** Usa `sed` para normalizar los estados del Log Crudo y `awk` para procesar las métricas de espacio libre, generando un `reporte_final_AAAAMMDD.txt` con marcas de tiempo dinámicas.

### 3. Configurador de Cron (`setup_cron.sh`)
Facilita el despliegue del sistema programando las tareas de manera automática.
* **Seguridad:** Incluye una validación que evita la duplicación de tareas si el script se ejecuta más de una vez.
* **Rutas Dinámicas:** Detecta automáticamente la ruta absoluta del proyecto (`pwd`) para asegurar que `cron` localice los scripts sin importar dónde estén instalados.
* **Programación por defecto:**
    * `01_sys_check.sh` -> Todos los días a las **02:00 AM**.
    * `02_file_manager_cleaner.sh` -> Todos los días a las **03:00 AM**.

---

## 🚀 Instrucciones de Uso

### Prerrequisitos
Asegúrate de otorgar permisos de ejecución a todos los scripts antes de empezar:
```bash
chmod +x 01_sys_check.sh 02_file_manager_cleaner.sh setup_cron.sh
