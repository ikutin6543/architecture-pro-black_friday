# MongoDB Sharding с Replication

Демонстрационный проект MongoDB с шардированием и репликацией. Включает конфигурационный сервер в формате replica set, два шарда (каждый как replica set) и роутер (mongos).

## Архитектура

Проект состоит из следующих компонентов:

### Config Server (Replica Set)
- **Сервис:** `mongodb-conf`
- **Replica Set ID:** `configServer`
- **Реплики:** 3 экземпляра (`mongodb-conf-1`, `mongodb-conf-2`, `mongodb-conf-3`)
- **Назначение:** Хранение метаданных шардирования

### Shard 1 (Replica Set)
- **Сервис:** `mongodb-shard1`
- **Replica Set ID:** `shard1`
- **Реплики:** 3 экземпляра (`mongodb-shard1-1`, `mongodb-shard1-2`, `mongodb-shard1-3`)
- **Назначение:** Первый шард данных

### Shard 2 (Replica Set)
- **Сервис:** `mongodb-shard2`
- **Replica Set ID:** `shard2`
- **Реплики:** 3 экземпляра (`mongodb-shard2-1`, `mongodb-shard2-2`, `mongodb-shard2-3`)
- **Назначение:** Второй шард данных

### Router (mongos)
- **Сервис:** `mongodb-router`
- **Реплики:** 3 экземпляра
- **Назначение:** Маршрутизация запросов к шардам

## Запуск

1. **Запустите сервисы:**
```bash
docker compose up -d
```

2. **Проверьте статус контейнеров:**
```bash
docker compose ps
```

   Убедитесь, что все контейнеры имеют статус `healthy` (может занять 30-40 секунд).

3. **Инициализируйте шардирование:**
```bash
chmod +x scripts/mongo-init.sh
./scripts/mongo-init.sh
```

Скрипт выполнит следующие действия:
- Инициализирует replica set для config server (3 реплики)
- Инициализирует replica set для shard1 (3 реплики)
- Инициализирует replica set для shard2 (3 реплики)
- Добавит шарды в роутер (mongos)
- Создаст базу данных `somedb` с включенным шардированием
- Создаст коллекцию `helloDoc` с hashed sharding по полю `name`
- Заполнит коллекцию 1000 тестовыми документами
- Проверит распределение документов между шардами (каждым из 3 реплик)


## Как проверить

Откройте в браузере http://localhost:8080



## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://localhost:8080/docs