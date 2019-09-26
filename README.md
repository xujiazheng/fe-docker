## x-docker

一个前段开发使用的docker容器

## 使用方法

```bash
# 安装
npm install xu-docker

# 运行
./node_modules/.bin/xu-docker

# 默认是docker 8080端口映射到本机8080端口，可以自定义
./node_modules/.bin/xu-docker -d "-p 80:80"

# 进入容器后，就可以执行webpack服务了
npm run dev

```