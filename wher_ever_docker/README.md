# WherEver Docker Development Environment

## 目录结构

```
wher_ever_docker/
├── docker-compose.yml          # 主编排文件
├── README.md                  # 本文档
├── mysql/
│   ├── conf/my.cnf           # MySQL 配置
│   ├── init/01-init.sql      # 数据库初始化脚本
│   └── data/                # MySQL 数据持久化
├── redis/
│   ├── conf/redis.conf       # Redis 配置
│   └── data/                # Redis 数据持久化
├── nacos/
│   ├── application.properties # Nacos 配置
│   ├── data/                # Nacos 数据持久化
│   └── logs/                # Nacos 日志
└── rocketmq/
    ├── conf/broker.conf     # RocketMQ Broker 配置
    ├── store/              # 消息存储
    └── logs/               # RocketMQ 日志
```

## 服务列表

| 服务 | 镜像 | 端口 | 用途 |
|------|------|------|------|
| MySQL | mysql:8.0 | 3306 | 关系型数据库 |
| Redis | redis:7-alpine | 6379 | KV 缓存 |
| Nacos | nacos/nacos-server:v2.2.3 | 8848 | 服务注册/配置中心 |
| RocketMQ | apache/rocketmq:5.1.0 | 9876, 10911 | 消息队列 |
| RocketMQ Dashboard | apacherocketmq/rocketmq-dashboard | 8080 | MQ 管理界面 |

## 快速启动

```bash
# 进入目录
cd wher_ever_docker

# 启动所有服务(后台运行)
docker-compose up -d

# 查看运行状态
docker-compose ps

# 实时查看日志
docker-compose logs -f

# 停止所有服务
docker-compose down

# 停止并清除数据(完全重置)
docker-compose down -v
```

## 服务验证

| 服务 | 访问地址 | 凭据 |
|------|----------|------|
| Nacos | http://localhost:8848/nacos | nacos / nacos |
| RocketMQ Dashboard | http://localhost:8080 | - |
| MySQL | localhost:3306 | root / root123456 |
| Redis | localhost:6379 | 无密码 |

## 配置文件说明

| 文件 | 作用 |
|------|------|
| `docker-compose.yml` | 容器编排，定义所有服务启动参数 |
| `mysql/conf/my.cnf` | MySQL 运行参数(字符集/连接数/缓存等) |
| `mysql/init/01-init.sql` | 首次启动自动执行的建库建表SQL |
| `redis/conf/redis.conf` | Redis 运行参数(内存/持久化/安全等) |
| `rocketmq/conf/broker.conf` | RocketMQ Broker 配置(集群/端口/刷盘策略) |
| `nacos/application.properties` | Nacos 应用配置 |

## 数据持久化

数据存储在 `./data/` 目录:
- `mysql/data/` - MySQL 数据文件
- `redis/data/` - Redis 数据文件
- `nacos/data/` - Nacos 注册中心数据
- `rocketmq/store/` - RocketMQ 消息存储

## 重置环境

```bash
# 完全重置(删除容器和数据)
docker-compose down -v

# 重新启动
docker-compose up -d
```

## 注意事项

- RocketMQ NameServer 端口: 9876
- RocketMQ Broker 端口: 10911
- Nacos 控制台端口: 8848
- 所有数据通过 volume 持久化到本地目录
