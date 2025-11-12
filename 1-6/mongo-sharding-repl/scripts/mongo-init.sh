#!/bin/bash

###
# Инициализация config server
###

docker compose exec -T mongodb-conf mongosh <<EOF
rs.initiate({
  _id: 'configServer',
  configsvr: true,
  members: [
    { _id: 0, host: 'mongo-sharding-repl-mongodb-conf-1:27017' },
    { _id: 1, host: 'mongo-sharding-repl-mongodb-conf-2:27017' },
    { _id: 2, host: 'mongo-sharding-repl-mongodb-conf-3:27017' },
  ]
})
EOF

echo "Ожидание инициализации config server..."
sleep 10

###
# Инициализация shard1
###

docker compose exec -T mongodb-shard1 mongosh <<EOF
rs.initiate({
  _id: 'shard1',
  members: [
    { _id: 0, host: 'mongo-sharding-repl-mongodb-shard1-1:27017' },
    { _id: 1, host: 'mongo-sharding-repl-mongodb-shard1-2:27017' },
    { _id: 2, host: 'mongo-sharding-repl-mongodb-shard1-3:27017' },
  ]
})
EOF

echo "Ожидание инициализации shard1..."
sleep 10

###
# Инициализация shard2
###

docker compose exec -T mongodb-shard2 mongosh <<EOF
rs.initiate({
  _id: 'shard2',
  members: [
    { _id: 0, host: 'mongo-sharding-repl-mongodb-shard2-1:27017' },
    { _id: 1, host: 'mongo-sharding-repl-mongodb-shard2-2:27017' },
    { _id: 2, host: 'mongo-sharding-repl-mongodb-shard2-3:27017' },
  ]
})
EOF

echo "Ожидание инициализации shard2..."
sleep 10

###
# Настройка шардирования через router
###

echo "Добавление шардов в router..."
docker compose exec -T mongodb-router mongosh <<EOF
sh.addShard('shard1/mongo-sharding-repl-mongodb-shard1-1:27017,mongo-sharding-repl-mongodb-shard1-2:27017,mongo-sharding-repl-mongodb-shard1-3:27017');
sh.addShard('shard2/mongo-sharding-repl-mongodb-shard2-1:27017,mongo-sharding-repl-mongodb-shard2-2:27017,mongo-sharding-repl-mongodb-shard2-3:27017');

EOF

echo "Ожидание регистрации шардов..."
sleep 5

# Проверяем статус шардов
shard_count=$(docker compose exec -T mongodb-router mongosh --quiet --eval "sh.status().shards.length" 2>/dev/null || echo "0")
echo "Количество зарегистрированных шардов: $shard_count"

docker compose exec -T mongodb-router mongosh <<EOF
sh.enableSharding('somedb');
sh.shardCollection('somedb.helloDoc', { 'name' : 'hashed' } )
EOF

###
# Инициализируем бд
###

docker compose exec -T mongodb-router mongosh <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

###
# Проверка документов в shard1
###

docker exec -it mongo-sharding-repl-mongodb-shard1-1 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard1: ', d.helloDoc.countDocuments())"
docker exec -it mongo-sharding-repl-mongodb-shard1-2 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard1: ', d.helloDoc.countDocuments())"
docker exec -it mongo-sharding-repl-mongodb-shard1-3 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard1: ', d.helloDoc.countDocuments())"

###
# Проверка документов в shard2
###

docker exec -it mongo-sharding-repl-mongodb-shard2-1 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard2: ', d.helloDoc.countDocuments())"
docker exec -it mongo-sharding-repl-mongodb-shard2-2 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard2: ', d.helloDoc.countDocuments())"
docker exec -it mongo-sharding-repl-mongodb-shard2-3 mongosh --eval "const d = db.getSiblingDB('somedb'); print('Documents in shard2: ', d.helloDoc.countDocuments())"
