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
