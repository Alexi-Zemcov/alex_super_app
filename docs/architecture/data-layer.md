# Data layer: DTO, API clients и cache strategy

## Когда открывать

- Нужно понять, куда класть generated DTO и API clients.
- Нужно разделить DTO и domain entity.
- Нужно решить, где должна жить cache strategy.

## Swagger / generated DTO / API clients

Если DTO и API-клиенты генерируются из Swagger, их обычно кладут в общий infrastructure package, а не в конкретную feature, особенно если они могут использоваться несколькими фичами или модулями.

Пример:

```text
packages/
  core/
    api_clients/
      lib/
        src/generated/
          auth_api/
          orders_api/
```

Тогда:

- generated DTO и API clients живут в общем infrastructure package
- в feature или модуле остаются `repository_impl`, datasource, mappers, domain entities, use case и presentation

Ключевое разделение:

- Swagger DTO != domain entity
- mapping DTO -> Entity обычно делается в `data/mappers`
- orchestration и выбор источника данных делает repository

## Где должна жить cache strategy

Стратегии вроде `cache-first`, `network-first` и `stale-while-revalidate` - это обычно ответственность Repository, а не DataSource.

Причина простая:

- DataSource должен просто уметь читать и писать
- Repository решает, когда брать cache, когда сеть, как делать fallback, refresh и обновление UI

Практическое правило:

- если логика простая, держать её прямо в `RepositoryImpl`
- если одна и та же логика повторяется во многих репозиториях, вынести её в отдельную сущность в data layer

Примеры reusable сущностей:

- `CachePolicy`
- `CachedRequestExecutor`
- `OfflineFirstStrategy`

Итоговая модель:

- DataSource - низкоуровневый доступ
- CachePolicy - reusable orchestration
- Repository - место, где policy применяется
