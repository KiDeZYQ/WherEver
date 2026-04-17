# WherEver Docker Development Environment

## Services

| Service | Port | Description |
|---------|------|-------------|
| MySQL | 3306 | Database |
| Redis | 6379 | Cache |
| Nacos | 8848 | Service Discovery & Config |
| RocketMQ | 9876, 10911 | Message Queue |
| RocketMQ Dashboard | 8080 | MQ Management Console |

## Quick Start

```bash
# Start all services
cd wher_ever_docker
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Verify Services

### Nacos
- Access: http://localhost:8848/nacos
- Default credentials: nacos / nacos

### RocketMQ Dashboard
- Access: http://localhost:8080

### MySQL
- Host: localhost:3306
- Password: root123456
- Database: wher_ever

### Redis
- Host: localhost:6379
- No password

## Notes

- RocketMQ NameServer runs on port 9876
- RocketMQ Broker runs on port 10911
- Nacos console runs on port 8848
- Volumes are created in `./data` directories for persistence
