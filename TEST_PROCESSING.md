# Guía para Ejecutar Tests de Procesamiento en ODM

## Opción 1: Test de Procesamiento Completo (Recomendado)

Para ejecutar un test de procesamiento completo, necesitas:

1. **Preparar un dataset de prueba:**
   - Crea una carpeta con imágenes de prueba (mínimo 3-5 imágenes con overlap)
   - Las imágenes deben tener metadata GPS (EXIF) si es posible

2. **Estructura del dataset:**
```
/path/to/datasets/
  └── test_project/
      └── images/
          ├── IMG_001.jpg
          ├── IMG_002.jpg
          ├── IMG_003.jpg
          └── ...
```

3. **Ejecutar el procesamiento:**

### Si estás usando Docker:
```bash
docker run -ti --rm \
  -v /path/to/datasets:/datasets \
  opendronemap/odm \
  --project-path /datasets test_project \
  --orthophoto-resolution 5 \
  --dsm
```

### Si estás en el entorno de desarrollo:
```bash
# Desde el directorio raíz de ODM
python3 run.py --project-path /path/to/datasets test_project \
  --orthophoto-resolution 5 \
  --dsm \
  --fast-orthophoto  # Para un test más rápido
```

### Test rápido (solo ortofoto, sin modelo 3D):
```bash
python3 run.py --project-path /path/to/datasets test_project \
  --fast-orthophoto \
  --orthophoto-resolution 5
```

## Opción 2: Usar el Entorno de Desarrollo

1. **Iniciar el entorno de desarrollo:**
```bash
# Desde el directorio raíz de ODM
DATA=/path/to/datasets ./start-dev-env.sh
```

2. **Dentro del contenedor, ejecutar:**
```bash
# Configurar el entorno (solo la primera vez)
bash configure.sh reinstall

# Ejecutar un test
./run.sh --project-path /datasets test_project --fast-orthophoto
```

## Opción 3: Test con Dataset Mínimo

Para un test rápido con configuración mínima:

```bash
python3 run.py --project-path /path/to/datasets test_project \
  --fast-orthophoto \
  --orthophoto-resolution 10 \
  --skip-3dmodel \
  --skip-report \
  --end-with odm_orthophoto
```

## Opción 4: Tests Unitarios (Requiere dependencias)

Los tests unitarios requieren todas las dependencias instaladas:

```bash
# Instalar dependencias primero
pip install -r requirements.txt

# Ejecutar todos los tests
bash test.sh

# Ejecutar un test específico
bash test.sh osfm
```

## Parámetros Útiles para Tests

- `--fast-orthophoto`: Salta reconstrucción densa (más rápido)
- `--orthophoto-resolution 5`: Resolución en cm/pixel
- `--skip-3dmodel`: Salta generación de modelo 3D
- `--skip-report`: Salta generación de reporte PDF
- `--end-with <etapa>`: Detener en una etapa específica
- `--max-concurrency 2`: Limitar uso de CPU (para tests)
- `--pc-quality low`: Calidad baja para tests más rápidos

## Verificar Resultados

Después del procesamiento, verifica que se generaron:

- `odm_orthophoto/odm_orthophoto.tif` - Ortofoto
- `odm_georeferencing/odm_georeferenced_model.laz` - Nube de puntos
- `opensfm/reconstruction.json` - Reconstrucción SfM

## Ejemplo Completo de Test

```bash
# 1. Crear estructura
mkdir -p /tmp/odm_test/test_project/images

# 2. Copiar imágenes de prueba (necesitas tener imágenes)
# cp /path/to/your/images/*.jpg /tmp/odm_test/test_project/images/

# 3. Ejecutar test
python3 run.py \
  --project-path /tmp/odm_test test_project \
  --fast-orthophoto \
  --orthophoto-resolution 5 \
  --skip-3dmodel \
  --skip-report \
  --max-concurrency 2
```

## Notas

- Para un test completo, necesitas al menos 3-5 imágenes con overlap suficiente
- El procesamiento puede tardar varios minutos dependiendo del hardware
- Usa `--fast-orthophoto` para tests más rápidos
- Los resultados se guardan en `test_project/` dentro de tu directorio de datasets


