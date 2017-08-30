# Twitter Function Image

This function exemplifies an authentication in Twitter API and get latest tweets of an account.

## Requirements

- Functions API
- fn 
- Configure a [Twitter App](https://apps.twitter.com/) and [configure Customer Access and Access Token](https://dev.twitter.com/oauth/overview/application-owner-access-tokens).

## Development

### 构建本地镜像

```
# 修改func.yaml文件，将name改成你自己的镜像名称。
# build it

fn build

```
### 本地测试
```
fn run
```

### 上传到镜像仓库

```
docker push <镜像名>
```

## 在平台运行

### 首先设置必须的环境变量

```
# Set your Function server address
# Eg. api.faas.pro

FUNCAPI=YOUR_FUNCTIONS_ADDRESS

# 以下信息在 apps.twitter.com 申请和获取 (Requirements)[#Requirements]
CUSTOMER_KEY="XXXXXX"
CUSTOMER_SECRET="XXXXXX"
ACCESS_TOKEN="XXXXXX"
ACCESS_SECRET="XXXXXX"
```

### Running with Functions

创建应用

```
curl -X POST --data '{
    "app": {
        "name": "twitter",
        "config": { 
            "CUSTOMER_KEY": "'$CUSTOMER_KEY'",
            "CUSTOMER_SECRET": "'$CUSTOMER_SECRET'", 
            "ACCESS_TOKEN": "'$ACCESS_TOKEN'",
            "ACCESS_SECRET": "'$ACCESS_SECRET'"
        }
    }
}' http://$FUNCAPI/v1/apps
```

创建路由

```
curl -X POST --data '{
    "route": {
        "image": "<镜像名>",
        "path": "/tweets",
    }
}' http://$FUNCAPI/v1/apps/twitter/routes
```

#### 云端运行试试？

```
curl -X POST --data '{"username": "zengqingguo"}' http://$FUNCAPI/r/twitter/tweets
```