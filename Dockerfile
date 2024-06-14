FROM hub.siji.ci/library/python:3.7-alpine AS base
LABEL maintainer="sijinhui <sijinhui@qq.com>"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --no-cache git tzdata vim
RUN apk add --no-cache coreutils
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    linux-headers
# 设置时区环境变量
ENV TZ=Asia/Chongqing
# 更新并安装时区工具
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

FROM base as run
COPY ./app /app
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# Make /app/* available to be imported by Python globally to better support several use cases like Alembic migrations.
ENV PYTHONPATH=/app

EXPOSE 8000

#ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "3"]
ENTRYPOINT ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "main:app"]
#ENTRYPOINT ["python", "main.py"]