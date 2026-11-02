# 实施状态

本文件是本仓库唯一的进度账本。`doc/` 下是上游历史文档，可能已过时，不作为当前事实。

## 当前交接

| 项 | 值 |
| --- | --- |
| 分支 | `feat/engineering-baseline`（从 `main` 切出，`main` 未改动） |
| 起点 HEAD | `3042bd40b46bcccf3db11a684420a6a79a4edbaf`（上游 Duster-Cule/UnipusHelperPro，2026-10-26「Update README.md」） |
| 当前 HEAD | `5e8a19fde93bbe4d9adc533028067ac27cd19c28`（已是远端分支最新内容提交；本文件所在提交只更新文档本身，HEAD 以 `git rev-parse HEAD` 为准） |
| 版本线 | `1.0.3`（`pom.xml:9`，本次未改） |
| 最近一次 CI run | [#41376445981](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376445981)：`CI` / job `build` = **success**，31 秒（2026-11-02T02:12:18Z → 02:12:49Z），head `5e8a19f` |
| 构建产物 | jar 本地 327081 字节 / CI 327068 字节；`target/lib` 16 个文件 / 9522131 字节。artifact `unipus-jar` id `13111810515`，9037310 字节，sha256 `b241c68a7f1f1e8c1eedc7ce68cc7d1d06dc40a37f90790bae10a0a14faf4b78` |
| 任务状态 | Task 0：工程底座 = implemented（**未做任何运行时验证**） |
| 下一步 | 等规划方下一条需求。不要自行开始功能开发、不推 `main`、不打 tag、不发 release。 |

## 任务表

状态只有两档：

- `implemented`：代码/文件 + CI 通过 + 产物齐备，规划方可以验收并推进。
- `completed`：用户在真机或本机实际使用验证过之后才可授予。

| Task | 状态 | 证据 |
| --- | --- | --- |
| Task 0：工程底座 | implemented | `AGENTS.md`、`VERSIONING.md`、`.github/workflows/ci.yml`、`scripts/verify-baseline.sh`（本地退出码 0）、`Documentation/ImplementationStatus.md`；CI run [#41376445981](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376445981) success，artifact `unipus-jar` id `13111810515`（9037310 字节，含 jar 与 `lib/`）。**未做任何运行时验证**。 |

## CI 记录

| run | head | 结论 | 说明 |
| --- | --- | --- | --- |
| [#41376357990](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376357990) | `80fe070` | failure | 首次推送。门禁拦下了本账本里复制的那段协议常量字样（`ImplementationStatus.md:49`），`verify-baseline.sh` 退出码 1，artifact 未上传。 |
| [#41376445981](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376445981) | `5e8a19f` | success | 删掉常量字样后通过。job `build` 31 秒；`openjdk version "25.0.5"`；`Apache Maven 3.10.0`；jar 327068 字节；`target/lib` 16 文件 / 9522131 字节；artifact `unipus-jar` id `13111810515`。 |

## 本线自己新增的约定

- 验证方式：`bash scripts/verify-baseline.sh`（`--no-build` 可跳过构建，CI 里复用上一步产物）。脚本做三件事：`mvn -B -DskipTests package`、产物字节统计、静态自检（入库文本无凭据模式 / `target/` 与日志未入库 / `.gitignore` 覆盖规则）。
- 不做自动化测试：这是 Windows 平台的 Swing GUI 程序，`pom.xml:145` 的 `<skipTests>true</skipTests>` 是既定选择。`junit` 依赖留在 `pom.xml` 里不动，但不写测试。
- `Documentation/Handoffs/` 的规则：该目录只在本机保留，已在 `.gitignore` 末尾追加忽略规则，**不入库、不在 GitHub 上显示**。里面每次交接写一份 `YYYY-MM-DD-<topic>.md`，记录现状、约定和下次从哪里继续；内容可以比本文件随意，但不得写入账号、密码、Cookie、Token、真实课程数据。
- 发布规则见 `VERSIONING.md`：标签 `v<version>`、分发 zip 名 `UnipusHelperPro-v<version>.zip`。本次不发布。

## 未验证项

本任务只建立了工程底座，未运行过程序，以下全部未验证：

1. 程序能否在本机 Windows 上启动、登录、答题、提交——一条都没有实际点过。构建成功不等于程序能跑。
2. GUI 在 JDK 25 + flatlaf 3.6.1 下的渲染与交互（字体、缩放、主题）未验证。
3. `target/unipusHelperPro-1.0.3.jar` + `target/lib/` 这套目录结构在真实机器上用 `java -jar` 启动是否正常（`Class-Path` 前缀为 `lib/`，需要与 lib 目录同级运行）。
4. 上游 README 提到但不存在的 `run.bat` / `run.sh` 启动脚本没有补，也没有验证任何启动方式。
5. CI 只在 `ubuntu-latest` 上验证编译与打包，Windows 行为未在 CI 覆盖。
6. 网络相关功能（U校园接口、答案拉取、提交请求）完全未验证；上游协议可能早已失效。
7. 构建产物不可复现：同一个提交在本机 JDK 25.0.4 上打出的 jar 是 327081 字节，CI 的 JDK 25.0.5 上是 327068 字节（差 13 字节）。本任务不声明可复现构建，也不做字节级对比。

## 发现的问题（只记录，未修改）

1. `src/main/java/org/unipus/util/WebUtils.java:30` 硬编码协议签名常量 `SECRET`（40 位十六进制字符串，本文不复制其值，避免被自己的凭据门禁拦住）。它是上游客户端协议常量，不是用户凭据，因此 `scripts/verify-baseline.sh` 的凭据扫描只覆盖入库的非源码文本文件，不把源码常量算作失败项。是否处理由规划方决定。
2. `README.md` 的 Releases 链接指向上游 `Duster-Cule/UnipusHelperPro/releases/latest`，本 fork 发布后应改指本仓库。
3. `README.md` 让用户运行 `run.bat` / `run.sh`，但仓库里没有这两个文件，也没有打 zip 的脚本。
4. `README.md` 里 `doc/CheckCurrentTask.md` 的链接指向 `Duster-Cule/UnipusHelper`（少了一个 `Pro`）。
5. 本机默认 `JAVA_HOME` 是 JDK 21，直接 `mvn package` 会因 `maven.compiler.target=25` 失败；构建需显式用 JDK 25（见 `AGENTS.md:82`）。
6. `target/lib` 会把 `junit-4.13.2` 与 `hamcrest-core-1.3` 一起复制进去（`maven-dependency-plugin` 的默认行为），分发包会比必要的大约多 400 KB。本项目不做测试，但按红线未改 `pom.xml`。
