# Próximas máquinas

Web for Pentester I ya arranca como `web4pentester`, imagen `tiizss/webforpentester:1.0`, en `127.18.0.1`. La lista del README añade ahora Web for Pentester II y conserva las otras seis. Cada máquina es una rama. No se inventa un tag de Docker Hub: primero se comprueba la imagen o el compose de origen, y la versión va en el nombre del repositorio `tiizss` y otra vez en el tag. La IP es un `127.x.0.1` que no esté ya en `config/projects.d/`. El stack es `breakinglab_<clave>` y los contenedores `<clave>_`. La vulnerabilidad del laboratorio se queda.

## Orden

1. **Web for Pentester II.** Origen: https://pentesterlab.com/exercises/web_for_pentester_II. Es una ISO de 2013, no un compose. La ficha oficial pide al menos 1 GB de RAM. Antes de escribir `docker_web4pentester2.conf` hay que tener una imagen que se pueda publicar en `tiizss` sin saltarse el acceso de PentesterLab PRO. Si esa imagen existe, la clave es `web4pentester2`, el puerto publicado es el 80 y la URL no reutiliza `127.18.0.1`. `web4pentester` no se toca.

2. **Un ejercicio de VulHub, no el catálogo entero.** https://github.com/vulhub/vulhub es una colección de compose. Una entrada del menú por ejercicio, con su propia clave y su propio stack. El clon, si hace falta, va a `labs/`. El compose que sea del lanzador va a `projects/<clave>/`. El siguiente ejercicio espera a que el anterior arranque y responda.

3. **CSPF ASP Vulnerable Lab.** https://github.com/CSPF-Founder/ASPVulnerableLab, licencia GPL-3.0. El repo no trae Dockerfile ni compose: es un proyecto ASP.NET. Entra cuando haya un contenedor que lo sirva. Hasta entonces no se copia el árbol al repositorio.

4. **Drunk Admin Web Hacking Challenge.** El enlace del README es un zip. Antes de hornear esos ficheros en una imagen hay que leer la licencia del zip y comprobar que la aplicación sigue arrancando. Si la licencia no deja republicar, se queda en la lista.

5. **GameOver.** https://sourceforge.net/projects/null-gameover/ es una máquina virtual. Misma puerta que la ISO de Web for Pentester II: no hay conf hasta que exista una imagen.

6. **OWASP Broken Web Applications.** La VM 1.2 es de agosto de 2015 y el proyecto en GitHub está archivado. Varias aplicaciones de esa VM ya están en el lanzador por separado (Mutillidae, bWAPP, Security Shepherd). No se importa la VM. La línea del README se queda como recuerdo, no como el siguiente arranque.

7. **Dodo Vulnerable Bank.** https://github.com/CSPF-Founder/DodoVulnerableBank es una aplicación Android. El lanzador arranca contenedores. Esta entrada espera a que el script sepa lanzar algo distinto de un contenedor web.

## Qué lleva cada máquina que sí entre

- `config/projects.d/docker_<clave>.conf`, copiado de `_template.conf.example`.
- Imagen `tiizss/<nombre>-<version>:<version>`.
- Compose en `projects/<clave>/` solo si hace falta más de un contenedor y esos ficheros son del lanzador.
- Gancho en `scripts/hooks/` solo si el arranque no cabe en un `docker run`.
- Una línea en el README, dentro de Available Labs, y una nota en el changelog.
- Prueba: `BREAKINGLAB_BATCH=1 ./breakinglab.sh start <clave>`, la URL responde, y `stop <clave>` apaga ese stack.

ShellCheck en verde antes de fusionar. Una máquina, una rama.
