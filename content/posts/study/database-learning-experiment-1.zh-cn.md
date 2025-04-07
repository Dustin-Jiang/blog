---
TITLE: 数据库设计与开发 - 实验1 建立数据库
DATE: 2025-04-07T22:00:00
DESCRIPTION: (高)斯(爱)慕棍哥
TAGS:
  - study
  - opengauss
SERIES: study-database
LICENSE: cc-sa
TOC: true
---

# 实验任务

- 在华为云上购买ECS服务器，安装OpenGauss数据库
- 在华为云上购买ECS数据库服务器
- 使用VirtualBox安装 OpenEuler 虚拟机并连接到其中的OpenGauss数据库
- 在OpenGauss数据库中创建数据库、数据表
- 建立“学籍与成绩管理系统”表格；
  - 包含以下信息
    - 课程名称
    - 课程代号
    - 课程类型（必修、选修、任选）
    - 学分
    - 任课教师姓名
    - 教师编号
    - 教师职称
    - 教师所属学院名称
    - 教师所属学院代号
    - 教师所授课程
    - 学生姓名
    - 学生学号
    - 学生所属学院名称
    - 学生所属学院代号
    - 学生所选课程
    - 学生成绩
  - 建立表之间的参照关系
  - 建立适当的索引
  - 在实验三说明建立索引的原因



学籍与成绩管理系统表格设计如下

学生表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| xm | 姓名 | 字符 | 8 | | |
| xh | 学号 | 字符 | 10 | | PK |
| ydh | 所属学院代号 | 字符 | 2 | ✓ | FK |
| bj | 班级 | 字符 | 8 | ✓ | |
| chrq | 出生日期 | 日期 | | ✓ | |
| xb | 性别 | 字符 | 2 | ✓ | |

课程表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| kcbh | 课程编号 | 字符 | 3 | | PK |
| kcmc | 课程名称 | 字符 | 20 | | |
| kclx | 课程类型 | 字符 | 2 | ✓ | |
| xf | 学分 | 数字 | 5.1 | ✓ | |

教师表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| xm | 姓名 | 字符 | 8 | | |
| jsbh | 教师编号 | 字符 | 10 | | PK |
| zc | 职称 | 字符 | 6 | ✓ | |
| ydh | 所属学院代号 | 字符 | 2 | ✓ | FK |

学院表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| ydh | 学院代号 | 字符 | 2 | | PK |
| ymc | 学院名称 | 字符 | 30 | | |

授课表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| kcbh | 课程编号 | 字符 | 3 | | PK,FK1 |
| bh | 教师编号 | 字符 | 10 | | PK,FK2 |

选课表设计

| 字段名 | 字段含义 | 字段类型 | 字段长度 | NULL | 备注 |
|--------|----------|----------|-----------|------|------|
| xh | 学号 | 字符 | 10 | | PK |
| kcbh | 课程编号 | 字符 | 3 | | PK,FK1 |
| jsbh | 教师编号 | 字符 | 10 | | PK,FK1 |
| ch | 成绩 | 数字 | 5.1 | ✓ | |

# 实验过程

## 购买ECS服务器，安装OpenGauss数据库

登录到华为云官网，使用课上注册的学生教育账号登录。进入"弹性云服务器"页面，选择"创建弹性云服务器"。

选择"按需计费"和"按量付费"的方式，选择"云服务器规格"，选择"通用型"，选择"2核4G"的配置, 网络类型选择按流量计费。
系统选择 Huawei EulerOS 2 操作系统。

{{< img src="/img/study/database-experiment-1/buy-server.png" caption="选购ECS服务器" >}}

购买之后修改密码, 查看服务器公网IP, 使用SSH登录到服务器。

{{< img src="/img/study/database-experiment-1/login-to-server.png" caption="SSH登录到服务器" >}}

登录之后, 建立OpenGauss数据库的安装目录 `/opt/software/openGauss`, 设置权限为 `755` 之后, 使用 `wget` 工具下载OpenGauss数据库安装包。

{{% card warning %}}
实验教程中购买的服务器是鲲鹏的 ARM 芯片, 所以下载的 OpenGauss 安装包也是 ARM 架构的. 比较坑的是这个安装包在 x86 上基本能跑, 只有一些 Python 包的依赖问题; 安装好之后可执行文件 ELF 格式不对启动不起来, 到这时候我才意识到这一点, 只能遗憾重装系统 :(
{{% /card %}}

{{< img src="/img/study/database-experiment-1/download-gauss.png" caption="下载OpenGauss数据库" >}}

根据ECS的名称和内网IP, 修改 `cluster-config.xml` 文件中的相关配置项. 

{{< img src="/img/study/database-experiment-1/cluster-config.png" caption="编辑集群配置" >}}

使用 `tar` 命令解压安装包. 

{{< img src="/img/study/database-experiment-1/uncompress.png" caption="解压OpenGauss安装包" >}}

使用 `gs_preinstall` 脚本进行预安装检查. 

{{< img src="/img/study/database-experiment-1/preinstall.png" caption="准备OpenGauss数据库安装环境" >}}

使用 `gs_install` 命令进行安装.

{{< img src="/img/study/database-experiment-1/install-gauss.png" caption="安装OpenGauss数据库" >}}

使用 `gs_om -t start` 命令启动OpenGauss数据库.

{{< img src="/img/study/database-experiment-1/start-gauss.png" caption="启动OpenGauss数据库" >}}

提示 `Successfully started.` 说明数据库启动成功.

## 购买ECS数据库服务器

登录到华为云官网，使用课上注册的学生教育账号登录。进入"云数据库RDS"页面，选择"创建云数据库RDS"。

选择"按需计费"的方式，选择"性能规格"，类型选择为 "PostgreSQL", 选择"2核4G"的配置, 选择 "单机实例"。

{{< img src="/img/study/database-experiment-1/buy-rds.png" caption="购买ECS数据库服务器" >}}

创建成功后, 使用华为云提供的 DAS 连接工具, 输入用户名与设置的密码, 连接到数据库服务器.

{{< img src="/img/study/database-experiment-1/connect-rds.png" caption="连接到ECS数据库服务器" >}}

## 使用虚拟机安装OpenGauss数据库

将课程提供的OpenEuler虚拟机镜像导入VirtualBox软件中. 

{{% btw %}}
笑点解析: 因为我懒得下他的镜像, 这个图是装了个名叫 OpenEuler 的 [Alpine](https://www.alpinelinux.org/) 虚拟机, 然后连到服务器上的 Podman 镜像里截的图🤣. 至于为什么装的是 Alpine, 无他, 小就是好!
{{% /btw %}}

{{< img src="/img/study/database-experiment-1/vm-euler.png" caption="导入OpenEuler虚拟机镜像" >}}

虚拟机启动后, 切换到 `omm` 用户, 使用 `gs_ctl status` 命令查看OpenGauss数据库状态. 

{{< img src="/img/study/database-experiment-1/vm-show-gauss-status.png" caption="查看OpenGauss数据库状态" >}}

使用命令 `gsql postgres` 连接到其中的OpenGauss数据库，输入用户名与设置的密码，连接到数据库服务器。

## 使用Docker容器化部署OpenGauss数据库

容器化是一种轻量级的虚拟化技术，它将应用及其依赖项打包到一个独立的单元中，这个单元被称为容器。容器与主机操作系统共享内核，因此比传统的虚拟机更轻量级、更快速。

Docker 是一个开源的应用容器引擎，它基于 Linux 的容器技术，可以将应用及其依赖打包到一个可移植的镜像中，然后发布到任何支持 Docker 的环境中。

- 提高资源利用率：容器与主机操作系统共享内核，因此比传统的虚拟机更轻量级，可以更有效地利用系统资源。
- 简化部署：容器将应用及其依赖项打包到一个独立的单元中，可以轻松地在不同的环境中部署。
- 提高可移植性：容器可以在任何支持 Docker 的环境中运行，从而提高了应用的可移植性。
- 提高开发效率：容器可以隔离不同的应用，从而避免了应用之间的冲突，提高了开发效率。


云和恩墨公司制作了一个基于 Docker 的 [OpenGauss 数据库镜像](https://hub.docker.com/r/enmotech/opengauss)，用户可以通过 Docker 快速部署 OpenGauss 数据库。

{{% btw %}}
完全在复读 [上一篇](/posts/study/database-learning-intro/) 中部署 OpenGauss 的操作, 不要脸地写了个加分申请. 
{{% /btw %}}

使用 Docker Compose 工具, 从镜像 `enmotech/opengauss` 部署 OpenGauss 数据库。`docker-compose` 配置文件如下:

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
      GS_PASSWORD: <DATABASE_PASSWORD>
    volumes:
      - ./data:/var/lib/opengauss
```

使用命令 `docker-compose up -d` 启动 OpenGauss 数据库容器。使用命令 `docker exec -it <container_name> bash` 进入容器。

进入容器后, 切换到 `omm` 用户, 使用命令 `gsql -d postgres` 连接到数据库。

{{< img src="/img/study/database-experiment-1/docker-compose.png" caption="连接到Docker容器中的OpenGauss数据库" >}}

## 建立数据表及索引

根据实验要求，设计了“学籍与成绩管理系统”中的一系列表格. 创建表格的SQL语句如下：

```sql
CREATE TABLE IF NOT EXISTS xyb ( -- 创建学院表，存储学院基础信息
    ydh CHAR(2) PRIMARY KEY NOT NULL,  -- 学院代号，主键（不允许空，固定长度2字符）
    ymc CHAR(30) NOT NULL             -- 学院名称（不允许空，固定长度30字符）
);

CREATE TABLE IF NOT EXISTS xs ( -- 创建学生表，存储学生基本信息
    xm CHAR(8) NOT NULL,        -- 姓名（不允许空，固定长度8字符）
    xh CHAR(10) PRIMARY KEY NOT NULL,  -- 学号，主键（不允许空，固定长度10字符）
    ydh CHAR(2),                -- 所属学院代号（允许空，外键，引用xyb.ydh）
    bj CHAR(8),                -- 班级（固定长度8）
    chrq DATE,                  -- 出生日期（允许空）
    xb CHAR(2),                -- 性别（允许空，固定长度2字符）
    FOREIGN KEY (ydh)          -- 外键约束：所属学院代号必须是xyb表中存在的ydh值
        REFERENCES xyb(ydh),
    UNIQUE (xh)                -- 唯一约束：确保学号
);

CREATE TABLE IF NOT EXISTS js ( -- 创建教师表，存储教师信息
    xm CHAR(8) NOT NULL,        -- 姓名（不允许空）
    jsbh CHAR(10) PRIMARY KEY NOT NULL, -- 教师编号，主键（不允许空）
    zc CHAR(6),                -- 职称（允许空，固定长度6字符）
    ydh CHAR(2),                -- 所属学院代号（允许空，外键，引用xyb.ydh）
    FOREIGN KEY (ydh)          -- 外键约束：所属学院代号必须是xyb表中存在的ydh值
        REFERENCES xyb(ydh),
    UNIQUE(jsbh)               -- 唯一约束：确保教师编号值唯一
);

CREATE TABLE IF NOT EXISTS kc ( -- 创建课程表，存储课程信息
    kcbh CHAR(3) PRIMARY KEY NOT NULL, -- 课程编号，主键（不允许空）
    kc CHAR(20) NOT NULL,          -- 课程名称（不允许空）
    lx CHAR(10),                   -- 课程类型（允许空）
    xf NUMERIC(5, 1),               -- 学分（数值类型，总长度5位，小数点后1位）
    UNIQUE(kcbh)
);

CREATE TABLE IF NOT EXISTS sk ( -- 创建授课表，存储课程与班级的关联关系
    kcbh CHAR(3),               -- 课程编号（非主键字段，参与复合主键）
    bh CHAR(10),                -- 教师编号（非主键字段，参与复合主键）
    PRIMARY KEY (kcbh, bh),     -- 复合主键：课程编号 + 教师编号必须唯一组合
    FOREIGN KEY (kcbh)          -- 外键约束：课程编号必须是kc表中存在的kcbh值
        REFERENCES kc(kcbh),
    FOREIGN KEY (bh)            -- 外键约束：班级编号必须是js表中存在的jsbh值
        REFERENCES js(jsbh)       -- js的jsbj字段添加UNIQUE约束以允许外键引用
);

CREATE TABLE IF NOT EXISTS xk ( -- 创建学生选课表，记录选课及成绩
    xh CHAR(10),               -- 学号（主键字段之一）
    kcbh CHAR(3),              -- 课程编号（主键字段之一）
    jsbh CHAR(10),             -- 教师编号（主键字段之一）
    cj NUMERIC(5, 1),          -- 成绩（允许空）
    PRIMARY KEY (xh, kcbh, jsbh), -- 联合主键：学号 + 课程编号 + 教师编号的组合唯一
    FOREIGN KEY (xh)           -- 外键约束：学号必须是xs表中存在的xh值
        REFERENCES xs(xh),
    FOREIGN KEY (kcbh)         -- 外键约束：课程编号必须是kc表中存在的kcbh值
        REFERENCES kc(kcbh),
    FOREIGN KEY (jsbh)         -- 外键约束：教师编号必须是js表中存在的jsbh值
        REFERENCES js(jsbh),
    -- 确保 (kcbh, jsbh) 组合存在于 sk 表中
    FOREIGN KEY (kcbh, jsbh)   -- sk 表的主键字段是 (kcbh, bh)，而 jsbh 对应 sk 表的 bh 字段
        REFERENCES sk(kcbh, bh)  -- 因此需要将 jsbh 映射到 sk 的 bh
);
```

使用Data Studio连接到数据库后, 执行上述SQL语句创建表格. SQL语句运行成功后, 可从Data Studio左侧的数据库树中查看到创建的表格.

{{< img src="/img/study/database-experiment-1/create-table.png" caption="创建表格" >}}

建立数据表之后, 根据数据特点, 针对部分常用的查询进行索引设计, 以提高查询效率. 例如, 在学生表的学号字段上建立索引, 在课程表的课程编号字段上建立索引, 在教师表的教师编号字段上建立索引, 在选课表的学号和课程编号字段上建立联合索引等. 

```sql
-- 学生表（xs）
CREATE INDEX idx_xs_ydh ON xs(ydh); --用于按学院快速筛选学生信息（如统计某学院的学生数量）

-- 教师表（js）
CREATE INDEX idx_js_ydh ON js(ydh); --用于按学院筛选教师（如查询某学院的教师列表）

-- 课程表（kc）
CREATE INDEX idx_kc_kc ON kc(kc); -- 按课程名称查询
CREATE INDEX idx_kc_xf ON kc(xf); -- 按学分数筛选课程

-- 学生选课表（xk）
CREATE INDEX idx_xk_kcbh ON xk(kcbh); --按课程编号（kcbh）统计选课人数
CREATE INDEX idx_xk_jsbh ON xk(jsbh); --按教师编号（jsbh）筛选授课记录
CREATE INDEX idx_xk_cj ON xk(cj); --按成绩（cj）排序或统计（如按成绩筛选）
```

在Data Studio中运行上述SQL语句, 可在左侧的数据库树中查看到创建的索引. 右键点击表格, 选择“查看索引”即可查看到创建的索引.

{{< img src="/img/study/database-experiment-1/create-index.png" caption="创建索引" >}}

# 实验结论

通过本次实验，我成功完成了数据库环境的搭建和基础数据表的设计与创建，获得了以下实验结论：

+ 多种数据库部署方式对比

  - ECS自建数据库：通过华为云ECS服务器自行安装配置OpenGauss数据库，具有较高的灵活性和可控性，但需要自行管理数据库运行环境和后续维护。
  - 云数据库RDS服务：华为云提供的托管PostgreSQL数据库服务，具有易用性高、运维简单的特点，适合快速部署且无需关注底层运维的场景。
  - 虚拟机本地部署：通过VirtualBox安装OpenEuler并使用其中的OpenGauss数据库，适合学习和开发环境，不依赖网络和云服务，便于本地调试和学习。

+ 数据库设计与实现

  - 成功设计并实现了学籍与成绩管理系统的六张数据表：学生表(xs)、教师表(js)、课程表(kc)、学院表(xyb)、授课表(sk)和学生选课表(xk)。
  - 建立了合理的表间关系，通过主外键约束保证了数据的完整性和一致性。
  - 采用了规范化的数据库设计方法，避免了数据冗余，使数据结构清晰合理。

+ 索引设计

  - 针对查询频率高的字段创建了适当的索引，如学号、课程编号、教师编号等。
  - 为外键字段如ydh(学院代号)建立索引，提高关联查询效率。
  - 为成绩字段cj创建索引，便于成绩统计和排序操作。
  - 索引设计兼顾了查询效率和写入开销的平衡。

+ 数据安全与完整性

  - 通过主键、唯一约束、非空约束等方式确保了数据的唯一性和完整性。
  - 通过外键约束维护了表之间的引用完整性，防止了数据不一致的情况出现。

# 实验体会

本次实验通过多种方式成功搭建了数据库环境，并完成了学籍与成绩管理系统的数据库设计与创建，为后续的数据操作和应用开发奠定了基础。

  - 掌握了OpenGauss数据库的安装、配置和基本管理方法。
  - 熟悉了SQL语言在数据定义(DDL)方面的应用，包括表的创建和索引的建立。
  - 了解了数据库外键约束的设置和作用。
  - 学会了使用华为云服务部署数据库环境。

实验中使用的多种部署方式各有优缺点，可以根据不同的应用场景灵活选择。数据库设计遵循了规范化原则，合理建立了索引，为系统的高效运行提供了保障。