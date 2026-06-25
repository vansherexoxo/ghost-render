FROM ghost:5-alpine
RUN cd /var/lib/ghost/versions/5.130.6 && npm install pg --save --legacy-peer-deps

# Patch knex-migrator: skip createDatabaseIfNotExist (throws for postgres)
RUN node -e "\
var fs=require('fs');\
var f='/var/lib/ghost/versions/5.130.6/node_modules/knex-migrator/lib/database.js';\
var c=fs.readFileSync(f,'utf8');\
var p=c.replace(\
  'exports.createDatabaseIfNotExist = function createDatabaseIfNotExist',\
  'exports.createDatabaseIfNotExist = function createDatabaseIfNotExist_disabled'\
);\
if(c===p){process.stdout.write('WARNING: patch not found\n');}\
else{fs.writeFileSync(f,p);process.stdout.write('database.js patched OK\n');}\
"

# Add a no-op replacement
RUN node -e "\
var fs=require('fs');\
var f='/var/lib/ghost/versions/5.130.6/node_modules/knex-migrator/lib/database.js';\
var c=fs.readFileSync(f,'utf8');\
var p=c+'\\nexports.createDatabaseIfNotExist = function(){return Promise.resolve();};\\n';\
fs.writeFileSync(f,p);\
process.stdout.write('no-op added OK\n');\
"

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
