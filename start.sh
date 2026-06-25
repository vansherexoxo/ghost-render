#!/bin/sh
node -e "
const {Client}=require('/var/lib/ghost/versions/5.130.6/node_modules/pg');
const c=new Client({connectionString:process.env.database__connection__connectionString,ssl:{rejectUnauthorized:false}});
c.connect()
 .then(()=>c.query('DROP TABLE IF EXISTS migrations_lock CASCADE'))
 .then(()=>{console.log('DB cleaned');return c.end();})
 .catch((e)=>{console.log('Note:',e.message);return c.end();});
" || true
exec docker-entrypoint.sh node current/index.js
