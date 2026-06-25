FROM ghost:5-alpine

RUN cd /var/lib/ghost/versions/5.130.6 && npm install pg --save --legacy-peer-deps

# Fix knex-migrator bug: creates migrations_lock WITH .primary() in CREATE TABLE,
# then immediately tries ALTER TABLE ADD CONSTRAINT primary key → duplicate error.
# Remove .primary() from CREATE TABLE so the ALTER TABLE step succeeds.
RUN node -e "\
var fs=require('fs');\
var f='/var/lib/ghost/versions/5.130.6/node_modules/knex-migrator/lib/index.js';\
var c=fs.readFileSync(f,'utf8');\
var p=c.replace(\"t.string('lock_key').notNullable().defaultTo(null).primary()\",\"t.string('lock_key').notNullable().defaultTo(null)\");\
if(c===p){process.stdout.write('WARNING: patch not found\n');}\
else{fs.writeFileSync(f,p);process.stdout.write('knex-migrator patched OK\n');}\
"

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
