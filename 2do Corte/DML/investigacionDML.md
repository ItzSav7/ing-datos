## Una maravillosa y muy pero muy fructífera investigación sobre dos cosas

### Instrucción (copiada y pegada de _ScriptTiendaOnline.sql_):
1. investigar los metodos de tipo numericos y caracteres en MySQL
2. investigar si se puede o no revertir una eliminacion de registros

Así que vamo' a darle...

### 1. Métodos de tipo numéricos y caractéres en MySQL
Ok, como en la clase virtual estábamos hablando del método `now()` para _datetime_ entonces me imagino que hablamos de esos métodos, right? En ese caso, acá hay algunos...

#### Numéricos
1. ABS() - Valor absoluto
2. CEIL() - Función techo. Definición formal (muy necesario)
$$\lceil x \rceil = ceil(x) = mín\{ n \in \mathbb{Z} | n \ge x \}$$
3. Todas las trigonométricas - (SIN(), COS(), TAN(), COT(), ACOS(), ASIN(), ATAN())
4. FLOOR() - Función piso. Definición trivial.
5. PI() - No adivinarás
6. POW(a) - $x^a$ 
7. ROUND() - Redondear
8. SQRT() - $\sqrt{x}$
9. MOD() - Módulo aka residup
10. TRUNCATE() - Truncar a número especificado de decimales

Existen muchas más. Consultarlas en [MySQL Documentation](https://dev.mysql.com/doc/refman/9.6/en/numeric-functions.html)

#### Carácter
1. ASCII() - Valos ASCII (si se le pasa a un varchar o cadena, devuelve únicamente el del carácter más a la izquierda)
2. CHAR() - Dado un entero, el carácter que representa
3. CONCAT() - Concatenar
4. LENGTH() - No adivinarás
5. LOWER() = LCASE() - a minúsculas
6. UPPER() = UCASE() - a mayúsculas
7. SPACE() - crear x cantidad de espacios
8. REVERSE() - No adivinarás (para varchar)

Existen muchas más. Consultarlas en [MySQL Documentation](https://dev.mysql.com/doc/refman/9.6/en/string-functions.html)

### 2. ¿Se puede revertir una eliminación de registros?
Existe un comando llamado `ROLLBACK` que deshace todos los cambios hechos en una transacción (conjunto de operaciones).
Esto solo se puede si no se han guardado permanentemente con `COMMIT`.

La vaina es que parece que MySQL tiene algo así como un "autocommit" activado por defecto así que por defecto, no, no se podría revertir la eliminación de un registro.
Es decir, el `DELETE` debió haber no sido confirmado para que `ROLLBACK` si funcione. Si no, la única esperanza es una copia de seguridad.

Así que ni modos...
