# DEVLOG

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
