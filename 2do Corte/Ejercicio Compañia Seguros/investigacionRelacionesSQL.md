# Investigación Relaciones en MySQL Workbench
### _Ok se que debe ser re chistoso que escriba esto después de la clase de hoy 16/03/26 porque literalmente lo vimos en clase pero ni modo, toca dejar constancia_

_Para una relacion 1:N..._

Sea A la tabla de donde sale el 1. Sea B la tabla a donde llega el N. 
Tal que la relación se vea:
A — 1 ——— N — B:

Sea idA la Primary Key de A. Análogamente con B. Sea el sufijo 'FK' indicar foreign key. 

## Forma 1: Crear la relacion al mismo tiempo que se crea la tabla
Dentro de los campos de B...:

create table B (
...
{idA}FK
constraint FKAB
foreign key ({idAFK})
references {A}({idA})
...
on update cascade
on delete cascade
...
);

Lo importante de esta forma es que si estoy creando una FK en B usando la PK de A, la tabla A ya debe estar creada. Si es necesario crear A y B antes de hacer relaciones, entonces toca hacerlo por la forma 2.

## Forma 2: Crearla afuerita, cuando la tabla ya está creada
Cuatro líneas will get the job done.

alter table {B}
add constraint {nombre_de_la_constraint} _(usualmente se le llama FKAB)_
foreign key ({idAFK})
references {A} ({idA})

Obviamente, idAFK ya debe ser un campo dentro de B antes de que se pueda hacer esta vuelta.

ERROR IMPORTANTE que me pasó: Los tipos de datos de las keys deben coincidir. No puedo tener una PK llamada "idA" que sea int y después tratar de referenciarla en B como "idAFK" si creé esta última como varchar(20).

Eso es como todo. Constancia dejada. 
