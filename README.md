<div align="center">

# AntiCAP-WebApi

## Version 1.1.1

</div>

## 🌍环境说明
```
python >= 3.8 64bit

# pyjwt库可能不支持低版本python 推荐使用3.10.6版本 

# https://registry.npmmirror.com/-/binary/python/3.10.6/python-3.10.6-amd64.exe

```

<div align="center">

## 📁 手动安装

</div>



```
# 1.Git克隆仓库 或 手动下载
git clone https://github.com/81NewArk/AntiCAP-WebApi

# 2.进入项目目录
cd AntiCAP-WebApi

# 3.使用清华源下载项目所需依赖
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 4.运行项目
python main.py

# 5.默认端口为6688，初始化账号密码均为admin

# 6.访问Web主页和开发者文档：
http://127.0.0.1:6688/
http://localhost:6688/

http://127.0.0.1:6688/docs
http://localhost:6688/docs


```

<div align="center">

## 🤖 自动安装

</div>

```
# 1.Git克隆仓库 或 手动下载
git clone https://github.com/81NewArk/AntiCAP-WebApi

# 2.根据系统 选择运行 Run-Windows.bat或 Run-Linux.sh 会自动安装所需依赖并运行项目

# 3.默认端口为6688 初始化账号密码均为admin

```


<div align="center">

## 🐳 Docker 部署

</div>

本项目已支持通过 Docker 部署，镜像由 GitHub Actions 自动构建并发布到 GitHub Container Registry (GHCR)。

镜像地址：`ghcr.io/hoopec/anticap-webapi`

### 方式一：直接拉取镜像运行（推荐）

```bash
# 1.拉取最新镜像
docker pull ghcr.io/hoopec/anticap-webapi:latest

# 2.运行容器（持久化数据 + 映射端口）
docker run -d \
  --name anticap-webapi \
  -p 6688:6688 \
  -v anticap-data:/app/data \
  --restart unless-stopped \
  ghcr.io/hoopec/anticap-webapi:latest

# 3.访问服务
# Web 主页： http://127.0.0.1:6688/
# 开发者文档：http://127.0.0.1:6688/docs
# 默认账号密码均为 admin
```

> 说明：`-v anticap-data:/app/data` 会将 SQLite 数据库（`app.db`）和 JWT 密钥（`secret.key`）持久化到 Docker 命名卷 `anticap-data` 中，容器重建后账号与登录态不会丢失。

### 方式二：本地构建镜像运行

```bash
# 1.克隆仓库
git clone https://github.com/hoopec/AntiCAP-WebApi
cd AntiCAP-WebApi

# 2.本地构建镜像
docker build -t anticap-webapi .

# 3.运行容器
docker run -d \
  --name anticap-webapi \
  -p 6688:6688 \
  -v anticap-data:/app/data \
  --restart unless-stopped \
  anticap-webapi
```

### 使用 docker-compose 运行

新建 `docker-compose.yml`：

```yaml
services:
  anticap-webapi:
    image: ghcr.io/hoopec/anticap-webapi:latest
    # 如需本地构建，取消下面一行注释
    # build: .
    container_name: anticap-webapi
    ports:
      - "6688:6688"
    volumes:
      - anticap-data:/app/data
    restart: unless-stopped

volumes:
  anticap-data:
```

```bash
# 启动
docker compose up -d

# 查看日志
docker compose logs -f

# 停止
docker compose down
```

### 环境变量说明

容器内可通过以下环境变量自定义运行参数（一般无需修改）：

| 环境变量 | 默认值 | 说明 |
|:--|:--|:--|
| `PORT` | `6688` | 服务监听端口 |
| `HOST` | `0.0.0.0` | 服务监听地址 |
| `DB_PATH` | `/app/data/app.db` | SQLite 数据库文件路径 |
| `SECRET_KEY_FILE` | `/app/data/secret.key` | JWT 密钥文件路径 |

如需修改端口，例如改为 `8080`：

```bash
docker run -d \
  --name anticap-webapi \
  -p 8080:8080 \
  -e PORT=8080 \
  -v anticap-data:/app/data \
  --restart unless-stopped \
  ghcr.io/hoopec/anticap-webapi:latest
```

### 数据持久化与备份

- 数据卷 `anticap-data` 中保存了 `app.db`（用户、注册码、扣点配置）和 `secret.key`（JWT 签名密钥）。
- 备份命令：

```bash
# 备份数据卷到当前目录
docker run --rm -v anticap-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/anticap-data-backup.tar.gz -C /data .

# 恢复备份
docker run --rm -v anticap-data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/anticap-data-backup.tar.gz -C /data
```

### 查看日志

```bash
# 实时查看容器日志
docker logs -f anticap-webapi
```


<div align="center">

## 📄 使用说明

### 本项目支持本地，局域网，公网部署

</div>

```
# 早期版本录制的视频，但是内容大致适用

https://www.bilibili.com/video/BV1xYGgz9ENE
```


<br>
<br>
<br>


## ❌ 缺少系统DLL报错解决方案

### 大部分服务器或家庭系统缺少模型推理必要的DLL，请根据需要安装。




| 系统架构      | 下载链接 |
|:----------| :--------- | 
| **ARM64** | https://aka.ms/vs/17/release/vc_redist.arm64.exe |
| **x64**   | https://aka.ms/vs/17/release/vc_redist.x64.exe| 
| **参考地址**  | https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist?view=msvc-170| 

<br>
<br>
<br>



# 🐧 QQ交流群

<br>

<div align="center">

<img src="https://free.picui.cn/free/2025/07/04/6867f1907d1a0.png" alt="QQGroup" width="200" height="200">

</div>


<br>
<br>
<br>


# 🚬 请作者抽一包香香软软的利群
<br>

<div align="center">

<img src="https://free.picui.cn/free/2025/07/04/6867efd0bd67e.png" alt="Ali" width="200" height="200">
<img src="https://free.picui.cn/free/2025/07/04/6867efd0d7cbb.png" alt="Wx" width="200" height="200">

</div>




