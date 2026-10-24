# Prefijo por laboratorio

Dentro del stack `breakinglab`, los contenedores de un laboratorio se nombran con la clave del proyecto y un guion bajo: `jvl2013_jvl`, `jvl2013_mysql`, `web4pentester_w4p`.

El render del compose escribe `container_name` y descarta el `container_name` que traiga el fichero de origen. Los `docker run` usan el mismo prefijo. Parar un laboratorio borra los contenedores `clave_`.

Web for Pentester conserva el hostname `w4p`. El prefijo del contenedor es `web4pentester_`, que es la clave con la que se arranca y se para.
