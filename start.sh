#!/bin/sh
set -e

node -e "
const {Client}=require('/var/lib/ghost/versions/5.130.6/node_modules/pg');
const c=new Client({connectionString:process.env.database__connection__connectionString,ssl:{rejectUnauthorized:false}});
c.connect()
  .then(()=>c.query('DROP TABLE IF EXISTS migrations_lock CASCADE'))
  .then(()=>c.query('DROP TABLE IF EXISTS migrations CASCADE'))
  .then(()=>c.query(\`CREATE TABLE migrations_lock (
    lock_key varchar(255) NOT NULL,
    locked integer NOT NULL DEFAULT 0,
    acquired_at varchar(255),
    released_at varchar(255)
  )\`))
  .then(()=>c.query(\"INSERT INTO migrations_lock (lock_key, locked) VALUES ('km01', 0)\"))
  .then(()=>{console.log('OK: tables ready');return c.end();})
  .catch((e)=>{console.error('FATAL:',e.message);process.exit(1);});
"

exec docker-entrypoint.sh node current/index.js
