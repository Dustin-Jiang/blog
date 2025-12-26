---
TITLE: 数据库设计与开发 - 搭建环境
DATE: 2025-02-27T12:00:00
DESCRIPTION: 华为好, 华为美, 华为为我增智慧!
TAGS:
  - study
  - database
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
  gauss:
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

{{% btw %}}
如果你 *不幸* 的是 Docker 用户, 那请自动把本文中的所有 `podman` 命令替换为 `docker`, 然后祝你好运. 
{{% /btw %}}

然后 `podman-compose up -d` 一刀流, 不出意外的话就能启动 OpenGauss 了. 

## pgAdmin

{{% card warning %}}
高版本 pgAdmin 不能很好地与 OpenGauss 一起工作, 不感兴趣可以跳过这一部分. 

Reina [测试后指出](https://ri-nai.github.io/Hugo-Blog/post/2025/02/25/hyper-v%E9%85%8D%E7%BD%AEopeneuler%E4%B8%8Eopengauss/#pgadmin4-%E8%BF%9E%E6%8E%A5-opengauss), pgAdmin v4.30 可以比较正常连接 OpenGauss, 但是我使用的 [elestio/pgadmin](https://hub.docker.com/r/elestio/pgadmin) 镜像没有这么老的版本, 因此测试的时候使用不够旧的旧版本依然无果, 于是转向了不同的技术路线, {{< del >}}走了更多弯路. {{< /del >}}
{{% /card %}}

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
  gauss:
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

## Cloudbeaver

由于 pgAdmin 的兼容问题, 经过搜索 Open Gauss 官网散乱的文档后找到了官方提供的 [JDBC 工具](https://opengauss.org/zh/download/) 以及 [使用方法](https://opengauss.org/zh/blogs/justbk/2020-10-30_dbeaver_for_openGauss.html). 

{{% btw %}}
虽说开源项目嘛, 赚点钱不寒碜; 我个穷学生想不到别的办法了才选择下面的做法, 如果真有生产需要还是希望大家能支持项目开发. 
{{% /btw %}}

比较操蛋的是, Cloudbeaver 虽然支持加载自定义 JDBC, 但是仅限企业版. 官方在仓库中给了一篇 [语焉不详的指南](https://github.com/dbeaver/cloudbeaver/wiki/Adding-new-database-drivers#adding-drivers-in-cloudbeaver-community-edition), 但毕竟没有什么 Java 开发经验, 试了试按着说明修改, 但连怎么编译都没弄明白. 

好在上网冲浪之后找到了这篇 [前人留下的教程](https://zhuanlan.zhihu.com/p/587648719), 作者好心地写了个 [Python 脚本](https://github.com/Danst-bjtu/CloudbeaverTool) 来魔改 Docker 镜像. 

于是二话不说 Fork 了一个, 加上了 OpenGauss 5.0.0 的 JDBC, 然后手搓了一个 Github Action 发布为 [Docker Image](https://github.com/dustin-jiang/CloudbeaverTool-OpenGauss/pkgs/container/cloudbeaver-opengauss). 残念的是作者当年给的方法现在已经没法用了, 在最新版上不会有效果; 好在我也没必要用最新版, 于是找了个发布时间早于作者最后提交时间的镜像版本, 果然能用! 

然后继续改 `docker-compose.yml`. 

```yaml
version: "3"
services:
  gauss:
    ...

  cloudbeaver:
    image: ghcr.io/dustin-jiang/cloudbeaver-opengauss:latest
    restart: unless-stopped
    ports:
      - "8978:8978"
    environment:
      - CB_SERVER_URL=http://localhost:8978
    volumes:
      - ./cloudbeaver/workspace:/opt/cloudbeaver/workspace
```

启动之后应该就能在数据库连接的地方选择 OpenGauss 了, 连接时

- 地址填 `host.containers.internal`;
- 端口为之前配置的主机侧算口, 我这为 `5432`;
- 用户名和密码填入之前在数据库中新建的用户;

{{< btw >}}
暂时还没明白为什么是在这里, 按理说应该在 public 下?
{{< /btw >}}

然后应该就能在 `cloudb` 下面看到数据表了 (如果你 `CREATE TABLE` 了). 