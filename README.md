# Build a Periodic Table Database

Repositorio con los archivos necesarios para aprobar el [proyecto requisito obligatorio número 4](https://www.freecodecamp.org/learn/relational-database/build-a-periodic-table-database-project/build-a-periodic-table-database). Proyecto para obtener la [Relational Database Certification](https://www.freecodecamp.org/learn/relational-database/) de freecodecamp

## Tabla de Contenidos

- [Build a Periodic Table Database](#build-a-periodic-table-database)
  - [Tabla de Contenidos](#tabla-de-contenidos)
  - [Instrucciones y All tests passed](#instrucciones-y-all-tests-passed)
  - [Proyecto Aprobado](#proyecto-aprobado)
  - [Script Bash](#script-bash)
  - [Comandos SQL](#comandos-sql)

## Instrucciones y All tests passed

![All tests passed](./screenshots/all_passed.webp)

## Proyecto Aprobado

![Screenshot Proyecto Aprobado](/screenshots/passed.png)

## Script Bash

```bash
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

NOT_FOUND() {
    echo "I could not find that element in the database."
}

SHOW_DATA() {
    # $1 para tipo de consulta y $2 para el dato a buscar
    case "$1" in

    "atomic_number")
        RESULT=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$2 ORDER BY atomic_number;")
        ;;
    "symbol")
        RESULT=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE UPPER(symbol)=UPPER('$2') ORDER BY atomic_number;")
        ;;
    "name")
        RESULT=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE UPPER(name)=UPPER('$2') ORDER BY atomic_number;")
        ;;
    esac

    if [[ -z $RESULT ]]; then
        NOT_FOUND
    else
        echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS; do
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
        done
    fi
}

RUN() {

    if [[ -z $1 ]]; then
        echo "Please provide an element as an argument."
    else
        if [[ $1 =~ ^[0-9]+$ ]]; then
            SHOW_DATA "atomic_number" $1
        else
            # search on symbol
            if [[ $(echo "$1" | tr '[:lower:]' '[:upper:]') =~ ^[A-Z]{1,2}$ ]]; then
                SHOW_DATA "symbol" $1
            else
                # search on name
                SHOW_DATA "name" $1
            fi
        fi
    fi
}
RUN $1

```

## Comandos SQL

```sql

ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;

ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;

ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;

ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

ALTER TABLE elements ADD CONSTRAINT elements_symbol_key UNIQUE (symbol);

ALTER TABLE elements ADD CONSTRAINT elements_name_key UNIQUE (name);

ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;

ALTER TABLE elements ALTER COLUMN name SET NOT NULL;

ALTER TABLE properties ADD CONSTRAINT properties_atomic_number_fkey FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number);

CREATE TABLE types (type_id SERIAL PRIMARY KEY, type VARCHAR NOT NULL);

INSERT INTO types (type) VALUES ('metal'), ('nonmetal'), ('metalloid');

/*
Crear columna type_id
*/

ALTER TABLE properties ADD COLUMN type_id INT;

UPDATE properties SET type_id = (SELECT type_id FROM types WHERE types.type = properties.type);

ALTER TABLE properties ADD CONSTRAINT fkey_properties_type_id FOREIGN KEY (type_id) REFERENCES types (type_id);

ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;

UPDATE elements SET symbol=INITCAP(symbol);

/*
Cambiar tipo de dato numeric(9,6) a solo numeric
*/

ALTER TABLE properties ALTER COLUMN atomic_mass TYPE decimal;

DELETE FROM properties WHERE atomic_number=1000;

DELETE FROM elements WHERE atomic_number=1000;

ALTER TABLE properties DROP COLUMN type;

INSERT INTO elements (atomic_number,name, symbol) VALUES (9,'Fluorine', 'F');

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (9, 18.998, -220, -188.1, 2);

INSERT INTO elements (atomic_number,name, symbol) VALUES (10,'Neon', 'Ne');

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (10, 20.18, -248.6, -246.1, 2);

SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) ORDER BY atomic_number;

```
