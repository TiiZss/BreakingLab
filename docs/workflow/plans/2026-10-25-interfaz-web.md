# Interfaz web

El lanzador sigue siendo `breakinglab.sh`. La web es el mismo menú en el navegador de este ordenador, en `127.0.0.1:8765`. No se publica en la red del aula: desde ahí solo se arrancan los laboratorios.

## Skills

En esta máquina están Frontend Design y, en ECC, `frontend-design-direction`, `frontend-a11y` y `make-interfaces-feel-better`. No están Impeccable, UI UX Pro Max, Theme Factory ni unas reglas visuales de Vercel con ese nombre. No se inventa su contenido.

La pantalla es la lista de laboratorios. Los colores son los del logo de `display_logo`: verde ANSI 42, blanco 47, texto verde 32 y blanco 37, sobre el negro del terminal. El nombre parte en celdas verdes y blancas, como el arte ASCII.

## Contrato

- `./breakinglab.sh web` arranca `web/server.py` con el Python 3 de WSL. No hay dependencias ni `pyproject.toml`: `uv` no está dentro de Ubuntu.
- `GET /api/labs` lee `config/projects.d/docker_*.conf` y `docker ps`.
- On y Off llaman a `breakinglab.sh`. Público y Privado solo marcan la dirección; con la máquina en marcha no se cambia. Si el público choca con otra máquina, la API responde 409 y la página pregunta. Confirmar manda `BREAKINGLAB_PUBLIC_CONFIRM=1`.
