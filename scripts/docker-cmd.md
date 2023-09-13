# 常用 Docker 命令

## 开发阶段

### **登录到 Docker Hub**:

在执行推送之前，您需要登录到 Docker Hub 帐户。

```sh
docker login
```

您将被提示输入您的 Docker Hub 用户名和密码。

### **构建 Docker 镜像**:

使用以下命令构建 Docker 镜像。将 `<image_name>` 替换为您想要的镜像名称，`<tag>` 替换为您的镜像标签（例如 `latest`）。

```Shell
docker build --platform <platform> -t <image_name>:<tag> .

docker build --platform linux/amd64 -t realchar-web:latest .
```

### **标记镜像**:

如果您要将镜像推送到 Docker Hub，您需要将构建的镜像标记为与您的 Docker Hub 仓库匹配。

```sh
docker tag <image_name>:<tag> <docker_hub_username>/<image_name>:<tag>

docker tag realchar-web:latest taokevin1024/realchar-web:latest
```

### build & tag

```Shell
docker build --platform linux/amd64 -t taokevin1024/realchar-web:latest .
```

将 `<docker_hub_username>` 替换为您的 Docker Hub 用户名。

### **推送镜像**:

使用以下命令将标记的镜像推送到 Docker Hub。

```sh
docker push <docker_hub_username>/<image_name>:<tag>
docker push taokevin1024/realchar-web:latest
```

这会将您的镜像上传到 Docker Hub 的相应仓库中。

## 测试阶段

### 拉取镜像

API 后端服务：

```Shell
docker pull taokevin1024/realchar:latest
```

Web 服务

```Shell
docker pull taokevin1024/realchar-web:latest
```

### 启动容器

Docker Run Backend Server:

```Shell
docker run -d --env-file .env --name realchar-backend -p 8000:8000 taokevin1024/realchar:latest
```

Docker Run Web Server:

```Shell
docker run -d --name realchar-web -p 80:80 taokevin1024/realchar-web:latest
```

```Shell
docker run -d --name realchar-web -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt taokevin1024/realchar-web:latest
```

### 查看日志

```Shell
docker logs -f <container_name>
```

### 进入容器

```Shell
dcoker exec -it <container_name> /bin/sh
```

### 停止容器

```Shell
docker stop <container_name>
```

### 删除容器

```Shell
docker rm <container_name>
```

### 删除未使用的镜像

```Shell
docker image prune
```

### 删除未使用的镜像、停止的容器、无用的网络和挂载卷

```Shell
docker system prune
```

## docker-compose 常用命令

> 💡 需要在 `docker-compose.yml` 所在位置执行 `docker-compose` 命令。

1. **docker-compose up**：启动容器，创建并启动所有在 `docker-compose.yml` 文件中定义的服务。

   ```bash
   docker-compose up
   ```

2. **docker-compose up -d**：以后台模式启动容器，创建并启动所有在 `docker-compose.yml` 文件中定义的服务。

   ```bash
   docker-compose up -d
   ```

3. **docker-compose down**：停止并移除所有在 `docker-compose.yml` 文件中定义的服务的容器、网络和卷。

   ```bash
   docker-compose down
   ```

4. **docker-compose ps**：查看所有正在运行的服务的容器状态。

   ```bash
   docker-compose ps
   ```

5. **docker-compose logs**：查看服务的容器日志输出。

   ```bash
   docker-compose logs
   ```

6. **docker-compose logs <service-name>**：查看特定服务的容器日志输出。

   ```bash
   docker-compose logs <service-name>
   ```

7. **docker-compose exec <service-name> <command>**：在运行中的服务容器内执行命令。

   ```bash
   docker-compose exec <service-name> <command>
   ```

8. **docker-compose build**：根据 `docker-compose.yml` 文件中的定义重新构建服务的镜像。

   ```bash
   docker-compose build
   ```

9. **docker-compose pull**：拉取服务的镜像，但不重新构建它们。

   ```bash
   docker-compose pull
   ```

10. **docker-compose restart <service-name>**：重启特定服务的容器。

    ```bash
    docker-compose restart <service-name>
    ```

11. **docker-compose stop <service-name>**：停止特定服务的容器。

    ```bash
    docker-compose stop <service-name>
    ```

这些命令可以帮助你管理和操作 Docker Compose 项目中的容器化服务。根据你的项目需求，你可以选择合适的命令来管理服务。
