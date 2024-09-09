#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

NOT_FOUND() {
    echo "I could not find that element in the database."
}

SHOW_DATA_BY_ATOMIC_NUMBER() {
    # search on atomic_number
    RESULT_ATOMIC_NUMBER_QUERY=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1 ORDER BY atomic_number;")
    if [[ -z $RESULT_ATOMIC_NUMBER_QUERY ]]; then
        NOT_FOUND
    else
        echo "$RESULT_ATOMIC_NUMBER_QUERY" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS; do
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
        done
    fi
}

SHOW_DATA_BY_SYMBOL() {
    RESULT_SYMBOL_QUERY=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE UPPER(symbol)=UPPER('$1') ORDER BY atomic_number;")
    if [[ -z $RESULT_SYMBOL_QUERY ]]; then
        NOT_FOUND
    else
        echo "$RESULT_SYMBOL_QUERY" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS; do
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
        done
    fi
}

SHOW_DATA_BY_NAME() {
    RESULT_NAME_QUERY=$($PSQL "SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE UPPER(name)=UPPER('$1') ORDER BY atomic_number;")

    if [[ -z $RESULT_NAME_QUERY ]]; then
        NOT_FOUND
    else
        echo "$RESULT_NAME_QUERY" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS; do
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
        done
    fi
}

RUN() {

    echo "Please provide an element as an argument."
    if [[ -z $1 ]]; then
        NOT_FOUND
    else
        if [[ $1 =~ ^[0-9]+$ ]]; then
            SHOW_DATA_BY_ATOMIC_NUMBER $1
        else
            # search on symbol
            if [[ $(echo "$1" | tr '[:lower:]' '[:upper:]') =~ ^[A-Z]{1,2}$ ]]; then
                SHOW_DATA_BY_SYMBOL $1
            else
                # search on name
                SHOW_DATA_BY_NAME $1
            fi
        fi
    fi
}
RUN $1
