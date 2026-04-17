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

### 快速检测所有服务状态

```bash
# 一键检测所有服务健康状态
docker-compose ps --format "table {{.Name}}\t{{.Status}}"
```

输出示例（所有服务 UP 表示启动成功）：
```
NAME                        STATUS
wher-ever-mysql             Up (healthy)
wher-ever-redis             Up (healthy)
wher-ever-nacos             Up (healthy)
wher-ever-rocketmq          Up
wher-ever-rocketmq-dashboard Up
wher-ever-rocketmq-broker   Up
```

### 逐个服务验证

**1. MySQL**
```bash
docker exec wher-ever-mysql mysqladmin ping -h localhost -u root -proot123456
# 输出: mysqld is alive 表示正常
```

**2. Redis**
```bash
docker exec wher-ever-redis redis-cli ping
# 输出: PONG 表示正常
```

**3. Nacos**
```bash
curl -s http://localhost:8848/nacos/v1/ns/instance?serviceName=nacos&ip=127.0.0.1&port=8848
# 输出包含 ok:true 表示注册中心正常
```

**4. RocketMQ NameServer**
```bash
docker exec wher-ever-rocketmq sh mqadmin clusterList -n rocketmq:9876
# 输出包含 Cluster Name 表示正常
```

**5. RocketMQ Broker**
```bash
docker exec wher-ever-rocketmq-broker sh mqadmin brokerStatus -n rocketmq:9876 -b rocketmq-broker
# 输出包含 broker-runtime-pid 表示正常
```

**6. RocketMQ Dashboard**
```bash
curl -s http://localhost:8080
# 返回 HTML 页面表示 Dashboard 正常
```

### 自动化检测脚本

创建 `check_services.sh`：
```bash
#!/bin/bash
echo "=== WherEver 服务健康检查 ==="

check() {
  local name=$1
  local cmd=$2
  if eval "$cmd" > /dev/null 2>&1; then
    echo "[✓] $name - 正常"
    return 0
  else
    echo "[✗] $name - 异常"
    return 1
  fi
}

check "MySQL" "docker exec wher-ever-mysql mysqladmin ping -h localhost -u root -proot123456"
check "Redis" "docker exec wher-ever-redis redis-cli ping"
check "Nacos" "curl -s http://localhost:8848/nacos/v1/ns/instance?serviceName=nacos&ip=127.0.0.1&port=8848 | grep -q ok"
check "RocketMQ Dashboard" "curl -s http://localhost:8080 | grep -q html"

echo "=== 检查完成 ==="
```

执行检测：
```bash
chmod +x check_services.sh
./check_services.sh
```

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
