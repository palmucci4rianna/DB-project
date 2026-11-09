#!/usr/bin/env bash
# Avvia il database MySQL in Docker e poi l'app Java.
#
# Uso:
#   ./avvia.sh            avvia DB (lo crea e lo popola se non esiste) + app
#   ./avvia.sh --reset    ricarica da zero schema e dati (sql/ddl.sql + sql/dml.sql), poi avvia l'app
#   ./avvia.sh --solo-db  avvia solo il database, senza l'app
#   ./avvia.sh --stop     spegne il container del database
#
# Credenziali: root / root su localhost:3306, database 'wedding_planner'
# (corrispondono a una delle coppie provate in DAOUtils.getWeddingPlannerConnection).

set -euo pipefail
cd "$(dirname "$0")"

CONTAINER=wedding-mysql
IMAGE=mysql:8
PASSWORD=root
DB=wedding_planner

mysql_exec() {
    docker exec -i "$CONTAINER" mysql -uroot -p"$PASSWORD" "$@" 2> >(grep -v "Using a password" >&2)
}

carica_schema_e_dati() {
    echo "→ Carico schema (sql/ddl.sql)..."
    mysql_exec < sql/ddl.sql
    echo "→ Carico dati di esempio (sql/dml.sql)..."
    mysql_exec "$DB" < sql/dml.sql
}

aspetta_mysql() {
    echo -n "→ Attendo che MySQL sia pronto"
    # Il ping via TCP fallisce finché MySQL è ancora in fase di inizializzazione
    for _ in $(seq 1 60); do
        if docker exec "$CONTAINER" mysqladmin ping -h 127.0.0.1 --protocol=tcp \
               -uroot -p"$PASSWORD" --silent >/dev/null 2>&1; then
            echo " ok"
            return
        fi
        echo -n "."
        sleep 2
    done
    echo
    echo "✗ MySQL non risponde. Controlla i log con: docker logs $CONTAINER" >&2
    exit 1
}

if ! docker info >/dev/null 2>&1; then
    echo "✗ Docker non è attivo. Avvialo con: sudo systemctl start docker" >&2
    exit 1
fi

MODE="${1:-}"

if [[ "$MODE" == "--stop" ]]; then
    docker stop "$CONTAINER"
    exit 0
fi

nuovo=false
if ! docker container inspect "$CONTAINER" >/dev/null 2>&1; then
    echo "→ Creo il container $CONTAINER ($IMAGE)..."
    docker run -d --name "$CONTAINER" -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD="$PASSWORD" \
        "$IMAGE" >/dev/null
    nuovo=true
elif [[ "$(docker container inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]]; then
    echo "→ Avvio il container $CONTAINER..."
    docker start "$CONTAINER" >/dev/null
fi

aspetta_mysql

if [[ "$nuovo" == true || "$MODE" == "--reset" ]]; then
    carica_schema_e_dati
fi

echo "✓ Database pronto su localhost:3306 (root/$PASSWORD, db '$DB')"

if [[ "$MODE" == "--solo-db" ]]; then
    exit 0
fi

echo "→ Avvio l'app..."
exec ./gradlew run
