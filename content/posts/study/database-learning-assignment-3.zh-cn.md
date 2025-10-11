---
TITLE: 数据库设计与开发 - 作业3 数据库设计与实现
DATE: 2025-05-20T22:00:00
DESCRIPTION: Delphi - 好, 坏, 丑
TAGS:
  - study
  - opengauss
SERIES: study-database
LICENSE: cc-sa
TOC: true
MATH: true
---

# 作业要求

## 功能需求


- 普通用户
  - 注册登录
  - 预约电脑维修
  - 取消预约
  - 查看公告
- 工作人员
  - 处理预约工单
- 管理员
  - 注册登录
  - 管理工作人员
  - 发布公告
  - 管理场地信息

## 设计说明


1. 普通用户

    - 可选择场地和时间，填写个人信息后，发起预约工单
    - 可查看自己的预约状态。
    - 可取消预约。
    - 可查看公告信息。

2. 工作人员

    - 类似普通用户。
    - 可在系统中修改工单信息（如完成、处理中）。
    - 可根据工单信息决定接受或拒绝预约

3. 管理员

    - 可管理工作人员名单与具体权限
    - 可在系统中修改场地信息和开放时间信息
    - 可管理公告信息

4. 工单

    - 记录预约时间、到达时间、完成时间。

# 数据库设计

## 数据表设计

根据需求分析和功能设计, 设计如下数据表:

{{< img src="/img/study/database-assignment-3/Tables.png" caption="数据表设计" >}}

实体属性说明:

- *clinic_user*: 所有用户的基本信息, 包括普通用户和工作人员
- *worker*: 工作人员信息, 继承自用户
- *admin*: 管理员信息, 继承自工作人员
- *campus*: 校区/场地信息
- *schedule*: 诊所开放时间安排
- *appointment*: 预约工单信息
- *announcement*: 公告信息

## ER 图

针对上述需求分析和功能设计, 根据数据表的设计, 绘制出如下的ER图:

{{< img src="/img/study/database-assignment-3/ER.png" caption="ER图" >}}

在这个ER图中, 各实体间的关系如下:

1. *campus* 与 *schedule* 是一对多关系: 一个校区可以有多个日程安排
2. *campus* 与 *worker* 是一对多关系: 一个校区可以有多个工作人员
3. *worker* 继承自 *clinic_user*: 工作人员是用户的特例
4. *admin* 继承自 *worker*: 管理员是工作人员的特例
5. *clinic_user* 与 *appointment* 是一对多关系: 一个用户可以有多个预约
6. *worker* 与 *appointment* 是一对多关系: 一个工作人员可以处理多个预约
7. *schedule* 与 *appointment* 是一对多关系: 一个日程可以有多个预约
8. *worker* 与 *announcement* 是一对多关系: 一个工作人员可以发布多个公告

关键业务约束:
1. 预约状态 (status) 定义了工单的生命周期
2. 日程安排 (schedule) 的开始时间必须早于结束时间
3. 日程安排的容量 (capacity) 必须为正数
4. 当预约状态达到正在处理时, 系统自动记录到达时间(arrive_time)

## 范式证明

在本节中，将针对数据库设计进行范式证明，分析每个表是否满足第一范式(1NF)、第二范式(2NF)和第三范式(3NF)。

### 第一范式(1NF)

第一范式要求关系模式中的每个属性都是不可再分的原子值。形式化定义为：

对于关系模式 $R(U)$，其中 $U$ 是属性集，若 $\forall A \in U$，$A$ 的域中的所有值都是原子的，则称 $R$ 满足第一范式（1NF）。

令 $D$ 表示数据库模式，$R_i \in D$ 表示数据库中的每个关系模式。对于我们的设计：

-- *campus表* $R_1(\texttt{id}, \texttt{name}, \texttt{address})$: 
  $\forall A \in \{\texttt{id}, \texttt{name}, \texttt{address}\}$，$A$ 的值域中的所有值均为原子值，因此 $R_1$ 满足1NF。

  用户表中所有属性均为原子值，因此 $R_2$ 满足1NF。
-- *clinic_user表* $R_2(\texttt{id}, \texttt{name}, \texttt{school\_id}, \ldots, \texttt{password\_hash})$: 

-- *worker表* $R_3(\texttt{id}, \texttt{campus})$: 
  $\forall A \in \{\texttt{id}, \texttt{campus}\}$，$A$ 的值域中的所有值均为原子值，因此 $R_3$ 满足1NF。

-- *admin表* $R_4(\texttt{id})$: 
  $\forall A \in \{\texttt{id}\}$，$A$ 的值域中的所有值均为原子值，因此 $R_4$ 满足1NF。

-- *announcement表* $R_5(\texttt{id}, \texttt{title}, \texttt{content}, \ldots, \texttt{last\_editor})$: 
  公告表中所有属性均为原子值，因此 $R_5$ 满足1NF。

-- *schedule表* $R_6(\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity})$: 
  $\forall A \in \{\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity}\}$，$A$ 的值域中的所有值均为原子值，因此 $R_6$ 满足1NF。

-- *appointment表* $R_7(\texttt{id}, \texttt{user\_id}, \texttt{worker\_id}, \ldots, \texttt{status})$: 
  预约表中所有属性均为原子值，因此 $R_7$ 满足1NF。

因此，$\forall R_i \in D$，$R_i$ 满足1NF，即整个数据库模式 $D$ 满足第一范式。

### 第二范式(2NF)

第二范式在第一范式的基础上，要求非主属性完全依赖于主键，而不是部分依赖。形式化定义为：

设 $R(U)$ 是满足1NF的关系模式，$K$ 为 $R$ 的候选键，$A \in U$，$A \notin K$ 是非主属性。若对于 $R$ 中的任意非主属性 $A$，$A$ 完全函数依赖于 $R$ 的每个候选键，则称 $R$ 满足第二范式（2NF）。

用函数依赖表示：不存在 $X \subset K$ 和非主属性 $A$ 使得 $X \to A$。

对于我们的数据库模式 $D$：

-- *campus表* $R_1(\texttt{id}, \texttt{name}, \texttt{address})$: 
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K = \{\texttt{name}, \texttt{address}\}$。
  $\forall A \in \{\texttt{name}, \texttt{address}\}$，不存在 $X \subset \{\texttt{id}\}$ 使得 $X \to A$（因为 $\texttt{id}$ 是单属性，不可再分），所以非主属性完全依赖于主键，满足2NF。

  -- *clinic_user表* $R_2(\texttt{id}, \texttt{name}, \texttt{school\_id}, \ldots, \texttt{password\_hash})$: 
  -- *schedule表* $R_6(\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity})$: 
  -- *appointment表* $R_7(\texttt{id}, \texttt{user\_id}, \texttt{worker\_id}, \ldots, \texttt{status})$: 
  对于 $\texttt{campus}$，不存在 $X \subset \{\texttt{id}\}$ 使得 $X \to \texttt{campus}$，满足2NF。

-- *admin表* $R_4(\texttt{id})$: 
  主键 $K = \{\texttt{id}\}$，无非主属性，所以平凡地满足2NF。

-- *announcement表* $R_5(\texttt{id}, \texttt{title}, \texttt{content}, \texttt{publish\_time}, \texttt{expire\_time}, \texttt{priority}, \texttt{last\_editor})$:
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K = \{\texttt{title}, \texttt{content}, \texttt{publish\_time}, \texttt{expire\_time}, \texttt{priority}, \texttt{last\_editor}\}$。
  $\forall A \in \{\texttt{title}, \texttt{content}, \texttt{publish\_time}, \texttt{expire\_time}, \texttt{priority}, \texttt{last\_editor}\}$，不存在 $X \subset \{\texttt{id}\}$ 使得 $X \to A$，满足2NF。

-- *schedule表* $R_6(\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity})$:
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K = \{\texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity}\}$。
  $\forall A \in \{\texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity}\}$，不存在 $X \subset \{\texttt{id}\}$ 使得 $X \to A$，满足2NF。

-- *appointment表* $R_7(\texttt{id}, \texttt{user\_id}, \texttt{worker\_id}, \ldots, \texttt{status})$:
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K$ 包含所有除\texttt{id}外的属性。
  $\forall A$ 在非主属性集合中，不存在 $X \subset \{\texttt{id}\}$ 使得 $X \to A$，满足2NF。

因此，$\forall R_i \in D$，$R_i$ 满足2NF，即整个数据库模式 $D$ 满足第二范式。

### 第三范式(3NF)

第三范式在第二范式的基础上，要求非主属性不传递依赖于主键，即非主属性之间不存在函数依赖关系。形式化定义为：

设 $R(U)$ 是满足2NF的关系模式，若 $R$ 中不存在这样的非主属性 $A$ 和 $B$，使得 $A \to B$（即 $B$ 传递函数依赖于键 $K$），则称 $R$ 满足第三范式（3NF）。

更精确地说，关系模式 $R(U)$ 满足3NF，当且仅当对于 $R$ 中的每个函数依赖 $X \to A$，要么：
1. $X$ 是超键，或者
2. $A$ 是主属性（即 $A$ 包含于某个候选键中）

对于我们的数据库模式 $D$：

- *campus表* $R_1(\texttt{id}, \texttt{name}, \texttt{address})$: 
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  在该表中，$\texttt{id} \to \texttt{name}$，$\texttt{id} \to \texttt{address}$ 是唯一的非平凡函数依赖，且 $\texttt{id}$ 是候选键，因此满足BCNF。

- *clinic_user表* $R_2(\texttt{id}, \texttt{name}, \texttt{school\_id}, \texttt{phone\_number}, \texttt{password\_hash})$: 
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K = \{\texttt{name}, \texttt{school\_id}, \texttt{phone\_number}, \texttt{password\_hash}\}$。
  对于任意 $A, B \in \{\texttt{name}, \texttt{school\_id}, \texttt{phone\_number}, \texttt{password\_hash}\}$ 且 $A \neq B$，
  不存在 $A \to B$ 的函数依赖（例如姓名不能决定学号，学号不能决定密码等），因此满足3NF。

- *worker表* $R_3(\texttt{id}, \texttt{campus})$: 
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K = \{\texttt{campus}\}$。
  只有一个非主属性，不可能存在传递依赖，满足3NF。

- *admin表* $R_4(\texttt{id})$: 
  主键 $K = \{\texttt{id}\}$，无非主属性，所以平凡地满足3NF。

- *announcement表* $R_5(\texttt{id}, \texttt{title}, \texttt{content}, \ldots, \texttt{last\_editor})$:
  主键 $K = \{\texttt{id}\}$，非主属性集合 $U - K$ 包含所有除id外的属性。
  对于任意两个非主属性 $A, B$，不存在 $A \to B$ 的函数依赖（如标题不能决定内容等），满足3NF。

- *schedule表* $R_6(\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity})$:
  主键 $K = \{id\}$，非主属性集合 $U - K = \{\texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity}\}$。
  对于任意 $A, B \in \{\texttt{campus\_id}, date, \texttt{start\_time}, \texttt{end\_time}, capacity\}$ 且 $A \neq B$，
  不存在 $A \to B$ 的函数依赖（例如校区不能决定日期，日期不能决定容量等），因此满足3NF。

- *appointment表* $R_7(id, \texttt{user\_id}, \texttt{worker\_id}, \ldots, status)$:
  主键 $K = \{id\}$，非主属性集合是所有除id外的属性。
  对于任意两个非主属性 $A$ 和 $B$，不存在 $A \to B$ 的函数依赖（如用户ID不能决定工作人员ID等），满足3NF。

因此，$\forall R_i \in D$，$R_i$ 满足3NF，即整个数据库模式 $D$ 满足第三范式。

### BCNF (Boyce-Codd范式)

BCNF是对3NF的进一步强化，要求关系模式中所有决定因素必须是候选键。形式化定义为：

设 $R(U)$ 是满足3NF的关系模式，若对于 $R$ 中的每个非平凡函数依赖 $X \to A$（其中 $A \notin X$），$X$ 都包含某个候选键，则称 $R$ 满足BCNF。

换言之，关系模式 $R(U)$ 满足BCNF，当且仅当对于 $R$ 中的每个函数依赖 $X \to A$，$X$ 必须是 $R$ 的超键。

对于我们的数据库模式 $D$：

-- *campus表* $R_1(\texttt{id}, \texttt{name}, \texttt{address})$: 
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  在该表中，$\texttt{id} \to \texttt{name}$，$\texttt{id} \to \texttt{address}$ 是唯一的非平凡函数依赖，
  且 $\texttt{id}$ 是候选键，因此满足BCNF。

-- *clinic_user表* $R_2(\texttt{id}, \texttt{name}, \texttt{school\_id}, \texttt{phone\_number}, \texttt{password\_hash})$: 
  主键 $K = \{\texttt{id}\}$，由于 $\texttt{school\_id}$ 也被设置为UNIQUE，因此候选键有 $\{\texttt{id}\}$ 和 $\{\texttt{school\_id}\}$。
  所有函数依赖中的决定因素（$\texttt{id}$ 或 $\texttt{school\_id}$）都是候选键，满足BCNF。

-- *worker表* $R_3(\texttt{id}, \texttt{campus})$: 
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  在该表中，$\texttt{id} \to \texttt{campus}$ 是唯一的非平凡函数依赖，
  且 $\texttt{id}$ 是候选键，因此满足BCNF。

-- *admin表* $R_4(id)$: 
  主键 $K = \{\texttt{id}\}$，只有一个属性，平凡地满足BCNF。

-- *announcement表* $R_5(\texttt{id}, \texttt{title}, \texttt{content}, \ldots, \texttt{last\_editor})$:
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  所有非平凡函数依赖的决定因素都是 $\{\texttt{id}\}$，且 $\{\texttt{id}\}$ 是候选键，满足BCNF。

-- *schedule表* $R_6(\texttt{id}, \texttt{campus\_id}, \texttt{date}, \texttt{start\_time}, \texttt{end\_time}, \texttt{capacity})$:
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  所有非平凡函数依赖的决定因素都是 $\{\texttt{id}\}$，且 $\{\texttt{id}\}$ 是候选键，满足BCNF。

-- *appointment表* $R_7(\texttt{id}, \texttt{user\_id}, \texttt{worker\_id}, \ldots, status)$:
  主键 $K = \{\texttt{id}\}$，唯一候选键是 $\{\texttt{id}\}$。
  所有非平凡函数依赖的决定因素都是 $\{\texttt{id}\}$，且 $\{\texttt{id}\}$ 是候选键，满足BCNF。

因此，$\forall R_i \in D$，$R_i$ 满足BCNF，即整个数据库模式 $D$ 满足Boyce-Codd范式。

### 范式设计总结

通过以上严格的数学证明，我们已经验证了本数据库设计完全满足从第一范式到Boyce-Codd范式的所有要求。具体而言：

1. *第一范式(1NF)*: $∀R_i \in D$，$\forall A \in R_i$，$A$ 的值域中的所有值均为原子值，保证了数据的原子性。

2. *第二范式(2NF)*: $∀R_i \in D$，不存在 $X \subset K$ 和非主属性 $A$ 使得 $X \to A$，消除了非主属性对主码的部分依赖。

3. *第三范式(3NF)*: $∀R_i \in D$，不存在非主属性 $A$ 和 $B$ 使得 $A \to B$，消除了非主属性之间的传递依赖。

4. *Boyce-Codd范式(BCNF)*: $∀R_i \in D$，对于 $R_i$ 中的每个非平凡函数依赖 $X \to A$（其中 $A \notin X$），$X$ 都是超键，确保了所有决定因素都是候选键。

这种严格遵循高级范式的设计方法具有以下优势：

- 最小化数据冗余，节省存储空间
- 消除更新异常（插入异常、删除异常、修改异常）
- 提高数据一致性和完整性
- 增强数据库结构的稳定性和扩展性
- 简化查询优化和索引设计

因此，本数据库模式设计不仅理论上满足规范化要求，在实际应用中也能有效支持业务需求，保证系统的可靠性和性能。


# 评分

参考评分标准中的得分要求, 对比实际实现, 总结得分情况如下表所示.

## 得分情况

| 类别 | 要求 | 完成情况 |
|------|------|----------|
| *数据库* | 使用OpenGauss | ✅ |
|  | 至少6张表 | ✅ |
| *前台开发* | 表的增删改查 | ✅ |
|  | 有界面表级联操作 | ✅ |
|  | 有应用程序用户权限管理 | ✅ |
|  | 采用Delphi至少5种组件 | ✅ |
| *数据设计* | 视图 | ✅ |
|  | 动态 SQL | ✅ |
|  | 存储过程/函数 | ✅ |
|  | 触发器 | ✅ |
| *文档* | 功能需求、设计说明 | ✅ |
|  | 含ER图，范式证明 | ✅ |
|  | 使用说明书 | ✅ |
|  | 源代码、可执行文件 | ✅ |
|  | 数据库SQL语句 | ✅ |
|  | 数据库备份 | ✅ |

# 总结与体会

## 项目总结

在本次"电脑诊所管理系统"的设计与实现过程中，我全面应用了数据库设计的理论知识和开发技能，成功构建了一个功能完整、结构合理的数据库应用系统。以下是对项目的总结与体会：

### 数据库设计成果

1. *需求分析与设计*：基于实际业务需求，设计了一个包含7个核心数据表的数据库结构，涵盖用户管理、预约管理、公告管理等功能模块。所有表结构满足第三范式（3NF）甚至更高的BCNF范式，确保了数据库的规范性和高效性。

2. *实体关系设计*：构建了清晰的ER图，准确表达了各实体间的关系，包括一对多关系和继承关系，如：
   - 校区与日程安排的一对多关系
   - 用户与预约的一对多关系
   - 工作人员继承自用户、管理员继承自工作人员的继承关系

3. *高级数据库功能*：成功应用了数据库的多种高级特性，如：
   - 通过视图简化了复杂查询和数据操作
   - 开发了触发器，实现了业务规则的自动化执行
   - 应用索引，优化查询性能

4. *视图的灵活应用*：
   
   创建的多个视图（如appointment_view, worker_view等）大幅简化了前端应用的数据访问逻辑。特别是appointment_view，它通过联接多个表，提供了一个全面的预约信息视图，使得前端应用无需编写复杂的SQL就能获取完整信息。

5. *触发器的有效利用*：
   
   通过触发器实现了业务约束，如自动验证日程安排的时间逻辑（开始时间必须早于结束时间）和容量限制（必须为正数），这种方法将业务规则嵌入数据库层，保证了数据一致性和完整性。

6. *用户权限分级设计*：
   
   系统通过继承关系（普通用户→工作人员→管理员）实现了清晰的权限分级，这种设计既符合业务逻辑，又便于系统权限的管理和扩展。

## 收获与体会

通过本次项目的设计与实现，我深刻体会到数据库设计在软件开发中的核心地位。良好的数据库设计不仅是系统稳定性的基础，也是业务逻辑实现的关键。

首先，数据库范式理论在实践中的应用让我认识到，规范的数据结构设计能有效减少数据冗余，提高数据一致性。在项目中应用第三范式和BCNF范式的过程，使我对数据依赖关系有了更深入的理解。

其次，数据库高级特性（视图、触发器、索引等）的应用让我体会到，数据库不仅是数据存储的场所，更是业务逻辑的重要载体。通过这些特性，可以将许多业务规则和约束直接实现在数据库层面，简化应用程序的设计。

最后，从ER图到物理数据库的转换过程，让我理解了数据库设计的系统性和整体性。一个好的数据库设计应当既满足当前业务需求，又具备面向未来扩展的灵活性。

总的来说，本次项目是理论知识与实践应用的完美结合，不仅巩固了数据库设计的基础知识，也提升了解决实际问题的能力。在未来的工作中，我将继续深化数据库设计与开发的学习，探索更多高级特性的应用，为构建高质量的信息系统打下坚实基础。