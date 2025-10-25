# MI APRENDIZAJE

## Principales Conceptos Aprendidos

### 1. Limitación de Recursos en Contenedores

#### Memoria
- **Memoria RAM (`--memory`)**: Limita la cantidad de RAM que el contenedor puede usar. Mínimo permitido: 6MB.
- **Memoria Swap (`--memory-swap`)**: Define el límite TOTAL (RAM + Swap). La swap disponible se calcula como: `memory-swap - memory`.
- **Diferencia clave**: RAM es memoria física rápida; Swap es memoria secundaria (disco) más lenta que actúa como desbordamiento.

#### CPU
- **`--cpus`**: Limita CUÁNTOS núcleos puede usar (Docker decide cuáles).
- **`--cpuset-cpus`**: Especifica CUÁLES núcleos usar exactamente. 

### 2. Healthcheck
- Verifica automáticamente el estado de salud del contenedor.
- **`|| exit 1`**: Garantiza que Docker detecte fallos incluso si el comando no retorna error explícitamente.
- Docker usa el código de salida: `0` = saludable ≠0 = no saludable 

### 3. Dockerfile
- Archivo de instrucciones para construir imágenes personalizadas.
- **Instrucciones principales**:
  - `FROM`: Imagen base
  - `RUN`: Ejecuta comandos durante la construcción
  - `COPY`: Copia archivos del host al contenedor
  - `EXPOSE`: Documenta el puerto (NO lo mapea)
  - `CMD`: Comando por defecto al iniciar el contenedor

### 4. Mecanismo de Caché
- Docker reutiliza capas no modificadas para acelerar construcciones.
- Si un paso cambia, se invalida la caché de ese paso y todos los siguientes.

### 5. Políticas de Reinicio
Controlan el comportamiento de reinicio automático de los contenedores ante diferentes eventos.

- **`no`** (por defecto): No reinicia el contenedor bajo ninguna circunstancia.
- **`always`**: Reinicia siempre el contenedor si se detiene. Si se detiene manualmente, solo se reiniciará al reiniciar el demonio Docker o manualmente.
- **`unless-stopped`**: Similar a `always`, pero NO reinicia después de reiniciar el demonio Docker si el contenedor fue detenido manualmente.
- **`on-failure`**: Reinicia ÚNICAMENTE cuando hay una falla (exit code ≠ 0). No reinicia si se detiene manualmente.


### 6. Imágenes Huérfanas (Dangling Images)
- Imágenes sin tag (`<none>:<none>`) que no están en uso.
- Se generan al crear nuevas versiones con el mismo nombre/tag.
- Ocupan espacio y deben limpiarse periódicamente.

---

## Tabla Resumen de Comandos Docker

| Comando | Descripción | Ejemplo Aplicado |
|---------|-------------|------------------|
| `docker run --memory=<valor>` | Limita la memoria RAM del contenedor | `docker run -d --memory=300m nginx:alpine` |
| `docker run --memory-swap=<valor>` | Define límite total de memoria (RAM + Swap) | `docker run -d --memory=300m --memory-swap=1g nginx:alpine` |
| `docker run --cpus=<número>` | Limita cantidad de núcleos CPU a usar | `docker run -d --cpus="1.5" nginx:alpine` |
| `docker run --cpuset-cpus=<lista>` | Asigna núcleos específicos de CPU | `docker run -d --cpuset-cpus="0-2" nginx:alpine` |
| `docker run --health-cmd=<comando>` | Define comando para verificar salud del contenedor | `docker run --health-cmd="curl -f http://localhost \|\| exit 1" nginx` |
| `docker run --restart=<política>` | Define la política de reinicio del contenedor | `docker run -d --restart=always nginx:alpine` |
| `docker run --restart=on-failure` | Reinicia solo cuando hay falla (exit code ≠ 0) | `docker run -d --restart=on-failure mi-app:1.0` |
| `docker run --restart=unless-stopped` | Reinicia siempre excepto si se detuvo manualmente | `docker run -d --restart=unless-stopped nginx:alpine` |
| `docker build -t <nombre>:<tag> .` | Construye imagen desde Dockerfile en directorio actual | `docker build -t mi-apache:1.0 .` |
| `docker build -f <archivo> -t <nombre> .` | Construye imagen usando Dockerfile con nombre personalizado | `docker build -t imagen:1.0 -f Dockerfile-custom .` |
| `docker images -f "dangling=true"` | Lista imágenes huérfanas (sin tag) | `docker images -f "dangling=true"` |
| `docker images -f "dangling=true" -q` | Lista solo IDs de imágenes huérfanas | `docker images -f "dangling=true" -q` |
| `docker image prune` | Elimina todas las imágenes huérfanas | `docker image prune` |

---

## 🔧 Problemas Encontrados y Soluciones

### Problema: Error al construir imagen con CentOS 7

**Error encontrado:**
```
Cannot find a valid baseurl for repo: base/7/x86_64
ERROR: failed to solve: process "/bin/sh -c yum -y update" did not complete successfully: exit code: 1
```

**Causa:**
CentOS 7 llegó al final de su vida útil (EOL) el 30 de junio de 2024. Los repositorios oficiales de YUM fueron desactivados y migrados a repositorios archivados (vault).

**Solución aplicada:**
Modificar el Dockerfile para redirigir los repositorios a `vault.centos.org`:

```dockerfile
FROM centos:7

# Cambiar a los repositorios archivados (vault)
RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo

RUN yum -y update
RUN yum -y install httpd
COPY ./web /var/www/html
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
```
## Aprendizajes para mi Formación Profesional

### 1. Gestión de Recursos en Entornos Multi-tenant
En plataformas cloud donde múltiples clientes comparten infraestructura (AWS, Azure, GCP), limitar recursos previene el "noisy neighbor" - un contenedor que consume recursos excesivos afectando a otros servicios.

### 2. Alta Disponibilidad con Políticas de Reinicio
Servicios críticos como APIs de pago o bases de datos requieren estar siempre disponibles. Usar `--restart=unless-stopped` garantiza que tras un reinicio del servidor, los servicios se levanten automáticamente sin intervención manual.

### 3. Optimización de Tiempos de Despliegue
En CI/CD con múltiples builds diarios, entender el caché de Docker reduce tiempos de construcción de 10 minutos a 2 minutos, acelerando entregas a producción.

### 4. Monitoreo Proactivo con Healthchecks
En arquitecturas de microservicios, healthchecks permiten a orquestadores (Kubernetes, Docker Swarm) detectar servicios degradados y redirigir tráfico antes de que usuarios experimenten errores.
