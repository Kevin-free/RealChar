# DEVLOG

### 同步 fork 仓库 git 命令

1.  git remote -v 查看你的远程仓库的路径：

> 如果只有 origin 的两行, 说明你未设置 upstream （中文叫：上游代码库）
> 一般情况下，设置好一次 upstream 后就无需重复设置。

2.  执行命令 git remote add upstream [https://github.com/selfteaching/the-craft-of-selfteaching.git](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fselfteaching%2Fthe-craft-of-selfteaching.git)
3.  再次执行命令 git remote -v 检查是否成功
4.  将未提交的提交

5.  执行命令 git fetch upstream 抓取原仓库的更新
6.  执行命令 git merge upstream/master 合并远程的 master 分支
7.  执行命令 git push 把本地仓库向 github 仓库（你 fork 到自己名下的仓库）推送修改

### 总结：

```Shell
git fetch upstream

git merge upstream/master

git push
```

### 切分支合并 main 分支 git 命令

```Shell
git switch -c new-branch (if new-branch not exist)

git switch new-branch

git merge main

git push
```

## Deploy to Ubuntu

### Add SSL to use HTTPS

Keyword: Certbot, SSL, HTTPS, Docker, Nginx.

Abstract:

1. Install Certbot
2. Use Certbot to get SSL Certificates
3. Set Nginx config
4. Restart Nginx
5. Automatically renew certificates

Details:

1. Install Certbot

```sh
sudo apt update
sudo apt install certbot
```

2. Get SSL Certificates

```sh
sudo certbot certonly --standalone --email my@gmail.com -d truthai.fun -d api.truthai.fun
```

Execute the above instructions and follow the prompts.
Certbot will start a temporary server to complete the verification (**it will occupy port 80 or 443, so the web server needs to be temporarily closed**), and then Certbot will save the certificate in the form of a file, including the complete certificate chain file and private key file.
Files are saved in the domain name directory under `/etc/letsencrypt/live/`.

Because the Nginx used is in Docker, and the SSL certificate file is in the local machine, so you need to add `/etc/letsencrypt` to the volume when starting the Docker container:

> Since certbot needs port 80 for automatic renewal, only port 443 is used here to start.

```Shell
docker run -d --name realchar-web -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt taokevin1024/realchar-web:latest
```

3. Set Nginx config

```nginx
server {
     listen 80;
     server_name truthai.fun www.truthai.fun;

     # Redirect HTTP to HTTPS
     return 301 https://$host$request_uri;
}

server {
     listen 443 ssl;
     server_name truthai.fun www.truthai.fun;

     # SSL certificate configuration
     ssl_certificate /etc/letsencrypt/live/truthai.fun/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/truthai.fun/privkey.pem;

     # Add SSL configuration (you can adjust it as needed)
     ssl_protocols TLSv1.2 TLSv1.3;
     ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
     ssl_prefer_server_ciphers off;

     location / {
         root /usr/share/nginx/html;
         index index.html index.htm;
         try_files $uri $uri/ /index.html =404;
     }
}

server {
     listen 80;
     server_name api.truthai.fun;

     # Redirect HTTP to HTTPS
     return 301 https://$host$request_uri;
}

server {
     listen 443 ssl;
     server_name api.truthai.fun;

     # SSL certificate configuration
     ssl_certificate /etc/letsencrypt/live/truthai.fun/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/truthai.fun/privkey.pem;

     # Add SSL configuration (you can adjust it as needed)
     ssl_protocols TLSv1.2 TLSv1.3;
     ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
     ssl_prefer_server_ciphers off;

     location / {
        # Change to the IP and port of the API service (Note: nginx is in Docker, the IP needs to be the host, not localhost)
        proxy_pass http://182.160.6.95:8000;
     }
}
```

4. Restart Nginx

The current environment is the Nginx service in Docker, and the container needs to be restarted to restart Nginx:

```Shell
docker restart my_nginx_container
```

If it is the Nginx service of the host machine, use the following command to restart Nginx:

```sh
sudo service nginx restart
```

5. Automatically renew certificates

Let's Encrypt certificates are valid for 90 days by default. In order to automatically renew certificates, you can add Certbot to a cron job:

```sh
sudo crontab -e
```

Execute `which certbot` to view the location.

```Shell
kevin@hw-hk-1:~$ which certbot
/usr/bin/certbot
```

Add the following lines to check and renew certificates:

```sh
0 0 * * * /usr/bin/certbot renew --quiet
```

This will automatically check the certificate and renew it every day at 00:00 AM.

```Shell
sudo crontab -l
```

Check to see if the timing command just added exists.

You can view all installed certificates and their related information on your system by executing `sudo certbot certificates` command.

```Shell
kevin@hw-hk-1:~$ sudo certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
   Certificate Name: truthai.fun
     Domains: truthai.fun api.truthai.fun
     Expiry Date: 2023-11-27 05:26:15+00:00 (VALID: 88 days)
     Certificate Path: /etc/letsencrypt/live/truthai.fun/fullchain.pem
     Private Key Path: /etc/letsencrypt/live/truthai.fun/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Through the above steps, you can add an SSL certificate to your Docker deployment and enable HTTPS access. Please make sure your server firewall allows access to port 443.

References:

1. https://zhuanlan.zhihu.com/p/53407930
2. https://www.qiniu.com/qfans/qnso-69907026

## Server Settings

### install Zsh on Ubuntu

安装和配置 Zsh 以及设置 Powerlevel10k 主题和插件的步骤如下：

1. **安装 Zsh**：

如果您的系统上尚未安装 Zsh，可以通过以下命令安装：

```bash
sudo apt update
sudo apt install zsh
```

2. **设置 Zsh 为默认 Shell**：

安装完成后，您可以将 Zsh 设置为默认的 Shell：

```bash
chsh -s $(which zsh)
```

3. **安装 Oh My Zsh**：

Oh My Zsh 是一个社区驱动的 Zsh 配置框架，使您可以轻松配置和扩展 Zsh。使用以下命令安装 Oh My Zsh：

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

4. **安装 Powerlevel10k 主题**：

Powerlevel10k 是一个受欢迎的 Zsh 主题，可以通过以下步骤安装：

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```

5. **安装自动建议插件**：

安装并启用 Zsh 自动建议插件：

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

6. **配置 Zsh 插件和主题**：

编辑 `~/.zshrc` 文件以进行配置：

```bash
nano ~/.zshrc
```

找到 `ZSH_THEME` 行并将其更改为：

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

在配置文件中添加插件，将以下行添加到文件底部：

```bash
plugins=(git zsh-autosuggestions)
```

7. **应用配置变更**：

保存并关闭 `~/.zshrc` 文件。然后运行以下命令以使更改生效：

```bash
source ~/.zshrc
```

Powerlevel10k 主题将会引导您完成初始化设置。按照屏幕上的提示，根据您的偏好进行选择。

8. **重启终端**：

重启终端以使所有更改生效。您应该会看到新的 Powerlevel10k 主题和自动建议功能。

现在您已经成功安装和配置了 Zsh、Powerlevel10k 主题和插件。享受更丰富的终端体验吧！

## QA

### CORS

> The root cause of the `CORS` error on this machine is the wrong `proxy_pass` setting in the Nginx configuration of the API service.
>
> `Access to fetch at 'http://api.find.truthai.fun/characters' from origin 'http://find.truthai.fun' has been blocked by CORS policy: Response to preflight request doesn't pass access control check: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.`
>
> The `CORS` error is due to the wrong `proxy_pass http://localhost:8000;` configuration of the Nginx of the API service, because the Docker network is not the host network, and Nginx in Docker cannot access other Docker containers using localhost. The host's API service, so it is not properly proxied to the API server, so the server's CORS settings are not used.
>
> `502 Bad Gateway`
>
> The `502` error is due to the Nginx configuration of the API service as a wrong `proxy_pass http://localhost:8000;`, adding `add_header Access-Control-Allow-Origin *;`. Although the CORS problem is solved, it is not proxied to the real API server, so an error 502 is reported.
>
> `The 'Access-Control-Allow-Origin' header contains multiple values '*, *', but only one is allowed.`
>
> The `'*, *'` error is due to the Nginx configuration of the API service being correct `proxy_pass http://182.160.6.95:8000;`, but adding `add_header Access-Control-Allow-Origin *;`. So the CORS of Nginx and the CORS of API service are duplicated.

`realtime_ai_character/main.py` in API Backend Server has set:

```Python
app.add_middleware(
    CORSMiddleware,
    # Change to domains if you deploy this to production
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Correct `nginx.conf` is：

```nginx
server {
     listen 80;
     server_name truthai.fun www.truthai.fun;

     # Redirect HTTP to HTTPS
     return 301 https://$host$request_uri;
}

server {
     listen 443 ssl;
     server_name truthai.fun www.truthai.fun;

     # SSL certificate configuration
     ssl_certificate /etc/letsencrypt/live/truthai.fun/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/truthai.fun/privkey.pem;

     # Add SSL configuration (you can adjust it as needed)
     ssl_protocols TLSv1.2 TLSv1.3;
     ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
     ssl_prefer_server_ciphers off;

     location / {
         root /usr/share/nginx/html;
         index index.html index.htm;
         try_files $uri $uri/ /index.html =404;
     }
}

server {
     listen 80;
     server_name api.truthai.fun;

     # Redirect HTTP to HTTPS
     return 301 https://$host$request_uri;
}

server {
     listen 443 ssl;
     server_name api.truthai.fun;

     # SSL certificate configuration
     ssl_certificate /etc/letsencrypt/live/truthai.fun/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/truthai.fun/privkey.pem;

     # Add SSL configuration (you can adjust it as needed)
     ssl_protocols TLSv1.2 TLSv1.3;
     ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
     ssl_prefer_server_ciphers off;

     location / {
        # Change to the IP and port of the API service (Note: nginx is in Docker, the IP needs to be the host, not localhost)
        proxy_pass http://182.160.6.95:8000;
     }
}
```

### WebSocket

Web Console Error:
`useWebsocket.js:47 WebSocket connection to 'wss://api.truthai.fun/ws/6c6858b4b5674339bf4ed6c5e16e7e61?llm_model=gpt-3.5-turbo-16k&platform=web&use_search=false&use_quivr=false&use_multion=false&character_id=elon_musk&language=en-US&token=' failed: `

API Server Error:
`"GET /ws/92f427a147e243b791a5ea75cd2f7b71?llm_model=gpt-3.5-turbo-16k&platform=web&use_search=false&use_quivr=false&use_multion=false&character_id=elon_musk&language=en-US&token= HTTP/1.0" 404 Not Found`

Solution:
in API Server part of `nginx.conf` add:

```conf
server {
     listen 443 ssl;
     server_name api.truthai.fun;

     # Other Settings

     location / {
        # Change to the IP and port of the API service (Note: nginx is in Docker, the IP needs to be the host, not localhost)
        proxy_pass http://182.160.6.95:8000;
        # The following four lines correctly handle WebSocket connections
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
     }
}
```

### Firebase

Web Console Error:
`SignIn.js:57 Error occurred during sign in. Code: auth/unauthorized-domain, Message: Firebase: Error (auth/unauthorized-domain).`
Info:
`Info: The current domain is not authorized for OAuth operations. This will prevent signInWithPopup, signInWithRedirect, linkWithPopup and linkWithRedirect from working. Add your domain (truthai.fun) to the OAuth redirect domains list in the Firebase console -> Authentication -> Settings -> Authorized domains tab.`

Solution:

1. Visit Firebase Console `https://console.firebase.google.com/`
2. "Create Project"
3. "Build"->"Authentication"->"Sign-in method" Enable Google
4. "Build"->"Authentication"->"Settings" Domains add "truthai.fun"
5. "project overview"->"project settings"->"add app"->copy firebaseConfig code

update `firebaseConfig` to `RealChar/client/web/src/utils
/firebase.js`

> ⚠️ NOTE：You need to change `"` to `'`, and add `,` to the last line, otherwise an error will be reported:

```
Failed to compile.

[eslint]
src/utils/firebase.js
  Line 8:11:   Replace `"AIzaSyBRqFxecZYe87DnYh7gYyzY_goAKmhrpV8"` with `'AIzaSyBRqFxecZYe87DnYh7gYyzY_goAKmhrpV8'`      prettier/prettier
  ...
```

```Javascript
// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: 'AIzaSyBRqFxecZYe87DnYh7gYyzY_goAKmhrpV8',
  authDomain: 'realchar-a58de.firebaseapp.com',
  projectId: 'realchar-a58de',
  storageBucket: 'realchar-a58de.appspot.com',
  messagingSenderId: '329881922764',
  appId: '1:329881922764:web:86620c703c32f2a608a669',
  measurementId: 'G-CN8CGSZV9M',
};
```
