---
TITLE: 数据库设计与开发 - 搭建环境
DATE: 2025-02-27T12:00:00
DESCRIPTION: 华为好, 华为美, 华为为我增智慧!
TAGS:
  - study
  - opengauss
SERIES: study-database
LICENSE: cc-sa
---

# 在开始之前

众所周知, 在某河北埋土大专, 计算机学院的老师都掌握着一门名为 ==鸡爪流== 的独门武功: 

- 作为门派秘典, PPT 这种九阴真经级别, 祖上传下来的经典自然是不容亵渎的; 
- 武林秘诀只能传授给聪明人, 领悟不透恩师妙语点拨的榆木脑袋只能靠边站了;
- 对弟子高要求, 人人要有明知山有史, 偏往史山行的精神;

而显然, ==赵小林== 老师便是鸡爪流的集大成者, 作为 *有幸* 选上由他教授的 [数据库设计与开发](https://bit101.cn/course/7089) 课程, 作为学生的我发自内心感受到由衷的 *喜悦*. 

第一节课老师介绍的课程要点包括但不限于: 

- *必须* 使用 ==最伟大最光荣最爱国最正确最具技术实力最能推动中华民族伟大复兴最能带领中华民族站上世界舞台之上== 的华为公司开发的 [Open Gauss](https://opengauss.org/) 数据库;
- *自愿* 使用由著名计算机软件巨头 Borland 于 2002 年推出的 [Delphi 7.0](https://winworldpc.com/product/delphi/70), 兼容从 Windows 98 往后的每一个 Windows 版本, 主打一个 *超强兼容性* ! 当然, 这是 *自愿* 选择, {{< del >}}只是不选就没有总分里的 10 分罢了{{< /del >}};

# 配置环境

亲爱的赵小林老师给出的是不知哪年配置好流传下来的 CentOS 镜像和 ==最伟大最光荣最爱国最正确最具技术实力最能推动中华民族伟大复兴最能带领中华民族站上世界舞台之上== 的华为公司开发的 Open Euler 镜像. 

望着 [CentOS End of Life](https://www.redhat.com/zh/topics/linux/centos-linux-eol) 的公告, 回忆起 `yum` 带来的苦痛, 看着放在脚边的鞋盒 NAS, 我毅然决然地在自己的 Debian 12 上配起了 Open Gauss. 

## Open Gauss

{{< btw >}}
Yes, Docker sucks, and LONG LIVE containerd!
{{< /btw >}}

作为在容器化大潮下从社会大学摸爬滚打成长起来的 Linux 用户, 第一选择自然而然是用 Podman 配置 Open Gauss 服务. 

经过 10 秒钟的 DockerHub 搜索后, 找到了上次更新在两年前的 [官方镜像](https://hub.docker.com/r/opengauss/opengauss) 和明显更新的很勤快的 [EnmoTech 镜像](https://hub.docker.com/r/enmotech/opengauss). 出于对 ==最伟大最光荣最爱国最正确最具技术实力最能推动中华民族伟大复兴最能带领中华民族站上世界舞台之上== 的华为公司的信任, 在官方镜像上浪费了 50 甚至 40 分钟后, 我选择了明显更像样的 EnmoTech 镜像. 

于是为了用人见人爱的 Docker Compose, 自己写了个 `docker-compose.yml`:

```yaml
version: "3"
services:
  guass:
    image: enmotech/opengauss:5.0.0
    privileged: true
    restart: always
    user: root
    ports:
      - "5432:5432"
    environment:
      GS_PASSWORD: <YOUR-PASSWORD-HERE>
    volumes:
      - ./data:/var/lib/lib/opengauss
```

{{< btw >}}
如果你 *不幸* 的是 Docker 用户, 那请自动把本文中的所有 `podman` 命令替换为 `docker`, 然后祝你好运. 
{{< /btw >}}

然后 `podman-compose up -d` 一刀流, 不出意外的话就能启动 OpenGauss 了. 

## pgAdmin

到此为止, 要访问刚搭建好的数据库, 只能 `podman exec -it <CONTAINER_ID> /bin/bash` 进入容器内部, 然后

```shell
su - omm
gsql postgres
```

{{< btw >}}
为什么默认数据库叫做 postgres 呢? 绝对是因为我们 Open Gauss 做了大量兼容性设计, 1000% 兼容 PostgresQL 的所有操作, {{< del >}}绝对不是因为 Open Gauss 是从 PostgresQL 改出来的 {{< /del >}}. 
{{< /btw >}}

连接上镜像默认创建的名为 `postgres` 的数据库. 显然这过于麻烦了, 那么有没有更方便的连接方案呢?

有的, 你好有的. 得益于 Open Gauss 对 Postgres 的 *超绝兼容性*, 为 Postgres 设计的知名面板 [pgAdmin](https://www.pgadmin.org) 能非常正常的使用. 

先还是直接进入容器内部, 连接上数据库, 在 `gsql` 的 Prompt 下输入

```sql
CREATE USER <DATABASE_USERNAME> WITH SYSADMIN password "<DATABASE_USER_PASSWORD>";
```

为 pgAdmin 连接创建一个用户. 如果提示需要先修改初始用户 `omm` 的密码, 按提示进行即可. 

之后打开刚才的 `docker-compose.yml`, 加入 `pgadmin` 的配置. 

```yaml
version: "3"
services:
  guass:
    ...

  pgadmin:
    image: elestio/pgadmin:REL-9_0
    restart: always
    environment:
        PGADMIN_DEFAULT_EMAIL: <YOUR-EMAIL-HERE>
        PGADMIN_DEFAULT_PASSWORD: <YOUR-PASSWORD-HERE>
        PGADMIN_LISTEN_PORT: 8080
    ports:
        - "18080:8080"
    volumes:
        - ./pgadmin/servers.json:/pgadmin4/servers.json
```

不要忘记先按照 [官方文档的格式](https://www.pgadmin.org/docs/pgadmin4/development/import_export_servers.html#json-format) 建立好 `./pgadmin/servers.json` 这个文件, 不然会炸 ()

```json
{
  "Servers": {
    "1": {
      "Name": "OpenGaussServer",
      "Group": "OpenGauss",
      "Port": 5432,
      "Username": "<DATABASE_USERNAME>",
      "Host": "host.containers.internal",
      "SSLMode": "prefer",
      "MaintenanceDB": "postgres"
    }
  }
}
```

然后照例 `podman-compose up -d` 启动, 不出意外的话在你的 `localhost:18080` 上就能访问到 pgAdmin 面板了. 之后填入先前为 pgAdmin 创建的用户密码, 应该就能登录到数据库中了. 