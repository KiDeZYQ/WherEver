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

### Web 控制台访问

| 服务 | 访问地址 | 凭据 | 验证方法 |
|------|----------|------|----------|
| Nacos | http://localhost:8848/nacos | nacos / nacos | 登录后显示服务列表或配置列表 |
| RocketMQ Dashboard | http://localhost:8080 | 无 | 登录后显示 Dashboard 页面 |
| MySQL | localhost:3306 | root / root123456 | 连接成功，可查询数据库 |

### 1. Nacos 验证

**浏览器访问**: http://localhost:8848/nacos

1. 打开浏览器访问上述地址
2. 默认账号: `nacos`，密码: `nacos`
3. 登录后应看到 Nacos 控制台界面

**API 验证**:
```bash
# 检查 Nacos 健康状态
curl -s http://localhost:8848/nacos/v1/ns/instance?serviceName=nacos&ip=127.0.0.1&port=8848
# 返回 {"enabled":true,"ephemeral":true,"clusterName":"DEFAULT","serviceName":"nacos","ip":"127.0.0.1","port":8848,"weight":1}

# 检查服务列表
curl -s http://localhost:8848/nacos/v1/ns/instance/list
```

### 2. RocketMQ Dashboard 验证

**浏览器访问**: http://localhost:8080

1. 打开浏览器访问上述地址
2. 无需登录，直接进入 Dashboard 主页
3. 点击左侧 "Dashboard" 查看集群状态

**日志验证**:
```bash
# 检查 Dashboard 日志无报错
docker-compose logs rocketmq-dashboard | grep -E "RemotingConnectException|10909"
# 无输出表示正常（VIP 通道已禁用）

# 检查 Dashboard 正常运行
docker-compose logs rocketmq-dashboard | grep "Started App"
# 应显示类似: Started App in x seconds
```

### 3. MySQL 验证

**命令行连接**:
```bash
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "SHOW DATABASES;"
```

**预期输出**:
```
Database
information_schema
mysql
nacos_config
performance_schema
sys
wher_ever
```

**验证 Nacos 数据库表**:
```bash
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "USE nacos_config; SHOW TABLES;"
```

**预期输出**:
```
Tables_in_nacos_config
config_info
config_info_aggr
config_info_beta
config_info_tag
config_tags_relation
group_capacity
his_config_info
permissions
roles
tenant_capacity
tenant_info
users
```

### 4. RocketMQ 完整验证

**NameServer 状态**:
```bash
docker exec wher-ever-rocketmq sh mqadmin clusterList -n rocketmq:9876
```

**Broker 状态**:
```bash
docker exec wher-ever-rocketmq-broker sh mqadmin brokerStatus -n rocketmq:9876 -b broker-auto
```

### 快速检测所有服务状态

```bash
# 一键检测所有服务健康状态
docker-compose ps --format "table {{.Name}}\t{{.Status}}"
```

输出示例（所有服务 UP 表示启动成功）：
```
NAME                           STATUS
wher-ever-mysql                Up
wher-ever-redis                Up
wher-ever-nacos                Up
wher-ever-rocketmq             Up
wher-ever-rocketmq-broker      Up
wher-ever-rocketmq-dashboard   Up
```

### 逐个服务验证

**1. MySQL**
```bash
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "SELECT 1;"
# 输出: Query OK 表示正常
```

**2. Redis**
```bash
docker exec wher-ever-redis redis-cli ping
# 输出: PONG 表示正常
```

**3. Nacos**
```bash
curl -s http://localhost:8848/nacos/v1/ns/instance?serviceName=nacos&ip=127.0.0.1&port=8848 | grep ok
```

**4. RocketMQ Dashboard**
```bash
curl -s http://localhost:8080 | head -1
# 输出 HTML 表示正常
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

- RocketMQ Dashboard 端口映射: `8080:8082`（宿主机 8080 → 容器 8082）
- RocketMQ NameServer 端口: 9876
- RocketMQ Broker 端口: 10911
- Nacos 控制台端口: 8848
- RocketMQ Dashboard 访问: http://localhost:8080
- RocketMQ VIP 通道默认启用，如遇连接错误 `connect to xxxx:10909 failed`，需设置环境变量 `ROCKETMQ_CONFIG_VIPCHANNELENABLED=false`
- 所有数据通过 volume 持久化到本地目录
