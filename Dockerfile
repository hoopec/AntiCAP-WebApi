# syntax=docker/dockerfile:1

# AntiCAP-WebApi 运行在 Python 3.10 环境（README 推荐 3.10.6）
FROM python:3.10-slim AS base

# 设置时区，避免日志时间混乱
ENV TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 安装 AntiCAP / OpenCV / ONNX Runtime 运行所需的系统依赖
# libgl1, libglib2.0-0: opencv-python 运行时依赖
# libgomp1: ONNX Runtime 运行时依赖
# libsm6, libxext6, libxrender1: OpenCV 图形相关依赖
# tini: 作为 init 进程正确处理信号
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libsm6 \
        libxext6 \
        libxrender1 \
        tini \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 先单独复制依赖文件，利用 Docker 层缓存
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制项目代码与静态资源
COPY main.py database.py ./
COPY static/ ./static/

# 创建数据目录用于持久化 SQLite 数据库与 secret.key
RUN mkdir -p /app/data

# 通过环境变量将数据库与密钥指向持久化目录
ENV DB_PATH=/app/data/app.db \
    SECRET_KEY_FILE=/app/data/secret.key \
    HOST=0.0.0.0 \
    PORT=6688

EXPOSE 6688

# 使用 tini 作为 init 进程，确保信号正确传递、僵尸进程被回收
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["python", "main.py"]
