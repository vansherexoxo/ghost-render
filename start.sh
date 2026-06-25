#!/bin/sh
set -e

# Step 1: Pre-create migrations_lock without PK (avoids duplicate constraint bug)
node -e "
const {Client}=require('/var/lib/ghost/versions/5.130.6/node_modules/pg');
const c=new Client({connectionString:process.env.database__connection__connectionString,ssl:{rejectUnauthorized:false}});
c.connect()
 .then(()=>c.query('DROP TABLE IF EXISTS migrations_lock CASCADE'))
 .then(()=>c.query('CREATE TABLE migrations_lock (lock_key varchar(255) NOT NULL, locked integer NOT NULL DEFAULT 0, acquired_at varchar(255), released_at varchar(255))'))
 .then(()=>c.query(\"INSERT INTO migrations_lock (lock_key, locked) VALUES ('km01', 0)\"))
 .then(()=>{console.log('OK: migrations_lock ready');return c.end();})
 .catch((e)=>{console.log('note:',e.message);return c.end();});
" || true

# Step 2: Run knex-migrator to create ALL tables including "migrations"
node /var/lib/ghost/versions/5.130.6/node_modules/knex-migrator/bin/knex-migrator init \
  --mgpath /var/lib/ghost/versions/5.130.6 || true

node /var/lib/ghost/versions/5.130.6/node_modules/knex-migrator/bin/knex-migrator migrate \
  --mgpath /var/lib/ghost/versions/5.130.6 || true

# Step 3: Start Ghost
exec docker-entrypoint.sh node current/index.js
