# MongoDB Sharding

Демонстрационный проект MongoDB с шардированием. Включает конфигурационный сервер, два шарда и роутер (mongos).

## Запуск

1. **Запустите сервисы:**
```bash
docker compose up -d
```

2. **Подождите 10-15 секунд** для инициализации контейнеров

3. **Инициализируйте шардирование:**
```bash
./scripts/mongo-init.sh
```

Скрипт выполнит следующие действия:
- Инициализирует replica set для config server
- Инициализирует replica set для каждого шарда
- Настроит шардирование через роутер
- Создаст базу `somedb`, коллекцию `helloDoc` с hashed sharding
- Заполнит коллекцию 1000 тестовыми документами
- Проверит распределение документов между шардами

## Подключение к MongoDB

**Роутер (mongos) - для работы с шардированной БД:**
```bash
docker compose exec mongodb-router mongosh
```

**Config Server:**
```bash
docker compose exec mongodb-conf mongosh
```

**Шард 1:**
```bash
docker compose exec mongodb-shard1 mongosh
```

**Шард 2:**
```bash
docker compose exec mongodb-shard2 mongosh
```

После выполнения `scripts/mongo-init.sh` вы увидите распределение документов между шардами (примерно 500 на каждый).

## Как проверить

Откройте в браузере http://localhost:8080



## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://localhost:8080/docs