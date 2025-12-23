#!/bin/bash
# Script de ejemplo para ejecutar un test de procesamiento en ODM
# 
# Uso:
#   ./test_processing_example.sh /path/to/datasets test_project_name
#
# O con imágenes específicas:
#   ./test_processing_example.sh /path/to/datasets test_project_name /path/to/images

set -e

if [ $# -lt 2 ]; then
    echo "Uso: $0 <project_path> <project_name> [images_path]"
    echo ""
    echo "Ejemplo:"
    echo "  $0 /tmp/odm_test my_test_project"
    echo "  $0 /tmp/odm_test my_test_project /path/to/images"
    exit 1
fi

PROJECT_PATH="$1"
PROJECT_NAME="$2"
IMAGES_PATH="${3:-}"

# Crear estructura de directorios
PROJECT_DIR="${PROJECT_PATH}/${PROJECT_NAME}"
IMAGES_DIR="${PROJECT_DIR}/images"

echo "Preparando test de procesamiento..."
echo "  Project path: ${PROJECT_PATH}"
echo "  Project name: ${PROJECT_NAME}"
echo "  Images dir: ${IMAGES_DIR}"

# Crear directorio de imágenes si no existe
mkdir -p "${IMAGES_DIR}"

# Si se proporcionó un path de imágenes, copiarlas
if [ -n "${IMAGES_PATH}" ] && [ -d "${IMAGES_PATH}" ]; then
    echo "Copiando imágenes desde ${IMAGES_PATH}..."
    cp "${IMAGES_PATH}"/*.{jpg,JPG,jpeg,JPEG,tif,TIF,tiff,TIFF,dng,DNG} "${IMAGES_DIR}/" 2>/dev/null || true
    
    IMAGE_COUNT=$(ls -1 "${IMAGES_DIR}"/*.{jpg,JPG,jpeg,JPEG,tif,TIF,tiff,TIFF,dng,DNG} 2>/dev/null | wc -l)
    if [ "${IMAGE_COUNT}" -eq 0 ]; then
        echo "ERROR: No se encontraron imágenes en ${IMAGES_PATH}"
        echo "Por favor, proporciona imágenes en formato JPG, TIFF o DNG"
        exit 1
    fi
    echo "  ${IMAGE_COUNT} imágenes copiadas"
else
    IMAGE_COUNT=$(ls -1 "${IMAGES_DIR}"/*.{jpg,JPG,jpeg,JPEG,tif,TIF,tiff,TIFF,dng,DNG} 2>/dev/null | wc -l)
    if [ "${IMAGE_COUNT}" -eq 0 ]; then
        echo "ERROR: No se encontraron imágenes en ${IMAGES_DIR}"
        echo "Por favor, coloca imágenes en ${IMAGES_DIR} o proporciona un path con --images-path"
        exit 1
    fi
    echo "  ${IMAGE_COUNT} imágenes encontradas en ${IMAGES_DIR}"
fi

# Verificar que hay suficientes imágenes
if [ "${IMAGE_COUNT}" -lt 3 ]; then
    echo "ADVERTENCIA: Se recomiendan al menos 3-5 imágenes para un test válido"
fi

echo ""
echo "Ejecutando procesamiento con configuración de test rápido..."
echo ""

# Ejecutar ODM con parámetros de test rápido
python3 run.py \
    --project-path "${PROJECT_PATH}" \
    "${PROJECT_NAME}" \
    --fast-orthophoto \
    --orthophoto-resolution 5 \
    --skip-3dmodel \
    --skip-report \
    --max-concurrency 2 \
    --pc-quality medium

echo ""
echo "=========================================="
echo "Test completado!"
echo "=========================================="
echo ""
echo "Resultados en: ${PROJECT_DIR}"
echo ""
echo "Archivos generados:"
echo "  - Ortofoto: ${PROJECT_DIR}/odm_orthophoto/odm_orthophoto.tif"
echo "  - Nube de puntos: ${PROJECT_DIR}/odm_georeferencing/odm_georeferenced_model.laz"
echo "  - Reconstrucción: ${PROJECT_DIR}/opensfm/reconstruction.json"
echo ""


