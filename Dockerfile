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

# 将 AntiCAP 模型目录软链接到持久化数据卷，避免每次启动重新下载模型
# AntiCAP 默认将模型下载到 site-packages/AntiCAP/AntiCAP-Models/，该路径在容器可写层，
# 容器重建后会丢失。通过软链接指向 /app/data/models 即可持久化。
# 将路径写入文件而非用 $(...) 捕获 stdout，避免 import AntiCAP 时
# Ultralytics 的警告信息污染路径变量导致 ln 失败
RUN python -c "import AntiCAP, os; open('/tmp/models_dir.txt','w').write(os.path.join(os.path.dirname(AntiCAP.__file__), 'AntiCAP-Models'))" && \
    MODELS_DIR=$(cat /tmp/models_dir.txt) && \
    rm -rf "$MODELS_DIR" && \
    mkdir -p /app/data/models /app/data/ultralytics-config && \
    ln -s /app/data/models "$MODELS_DIR" && \
    rm -f /tmp/models_dir.txt

# 复制项目代码与静态资源
COPY main.py database.py ./
COPY static/ ./static/

# 通过环境变量将数据库、密钥、模型、Ultralytics 配置指向持久化目录
ENV DB_PATH=/app/data/app.db \
    SECRET_KEY_FILE=/app/data/secret.key \
    YOLO_CONFIG_DIR=/app/data/ultralytics-config \
    HOST=0.0.0.0 \
    PORT=6688

EXPOSE 6688

# 使用 tini 作为 init 进程，确保信号正确传递、僵尸进程被回收
ENTRYPOINT ["/usr/bin/tini", "--"]

# 启动前确保持久化子目录存在（数据卷可能遮住了构建阶段创建的目录） 
CMD sh -c "mkdir -p /app/data/models /app/data/ultralytics-config && exec python main.py"
