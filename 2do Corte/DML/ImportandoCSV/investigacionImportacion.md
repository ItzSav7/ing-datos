## Una maravilla de investigación
### Parte 1: ¿Qué archivos se pueden abrir en MySQL para llenar registros?
Según lo que investigué, parece que nativamente NO existe forma de importar usando `.xlsx`, pero si usando `.csv`.
Se puede subir `.txt` separando con _tabs_ o formato JSON. También se puede con `.xml` (markdown para guardar cosas, estructura similar a hmtl)

### Parte 2: ¿y cómo?

_Con interfaz de MySQL es decir sin código:_
Hacer click derecho sobre la base de datos o sobre una tabla en la pestaña de _Schemas_ abre la opción que dice '**Table Data Import Wizard**', se especifica la ubicación del archivo. Después deja elegir si debe guardar los registros en una tabla existente o en una nueva. Deja ajustar por cada campo el tipo de dato deseado.

y listo:)

si algún día se me olvida o algo mira este video de un indio que explicó pero uff rápido y bueno...
[https://youtu.be/El_QkLkO_9k?si=03sfEzA2cZqyj7W3](https://youtu.be/El_QkLkO_9k?si=03sfEzA2cZqyj7W3)

_Con sentencias:_
`LOAD DATA LOCAL INFILE '/.../whatever.csv'
INTO TABLE {nombre_tabla}
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;`

Pero usar el `LOCAL` necesita permisos. 
**LA SENTENCIA NO ME SIRVIÓ POR TEMA DE PERMISOS QUE NO PUDE RESOLVER**


### Parte 3: Subconsultas y consultar multitabla
Una subconsulta es una consulta dentro de otra (anidada) para que la de adentro se ejecute primero que la de afuera. Como para hacer que el resultado de una consulta se pueda usar como operador en la condición de la consulta de afuera.

**Enunciado ejemplo:** Quiero ver los productos que nunca han sido comprados por clientes que sí han comprado el producto más caro.

Una consulta multitabla usa la cláusula JOIN para combinar filas de dos o más tablas relacionadas por una FK. Existe INNER JOIN, LEFT JOIN, RIGHT JOIN. LEFT JOIN une las filas de la primera tabla sin importar si existe un registro de esa en la segunda. RIGHT JOIN lo mismo pero intercambiando el orden de las tablas. Estas dos pueden devovler campos en NULL.

INNER JOIN obliga a que hayan valores que coincidan en ambas tablas.

**Enunciado ejemplo:** Quiero listar los clientes que han hecho pedidos donde todos los productos del pedido también han sido comprados por al menos otro cliente distinto.