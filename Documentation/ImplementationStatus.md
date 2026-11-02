# 实施状态

本文件是本仓库唯一的进度账本。`doc/` 下是上游历史文档，可能已过时，不作为当前事实。

## 当前交接

| 项 | 值 |
| --- | --- |
| 分支 | `feat/human-pacing`（从 `feat/engineering-baseline` 切出，`main` 未改动） |
| 起点 HEAD | `3042bd40b46bcccf3db11a684420a6a79a4edbaf`（上游 Duster-Cule/UnipusHelperPro，2026-10-26「Update README.md」） |
| 当前 HEAD | 以 `git rev-parse HEAD` 为准；上一个已推送基线是 `89c073189b1b69ecf4cb3a625554cfe96a83fe90` |
| 版本线 | `1.0.3`（`pom.xml:9`，本次未改） |
| 最近一次 CI run | [#41376445981](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376445981)：`CI` / job `build` = **success**，31 秒（2026-11-02T02:12:18Z → 02:12:49Z），head `5e8a19f` |
| 构建产物 | jar 本地 327081 字节 / CI 327068 字节；`target/lib` 16 个文件 / 9522131 字节。artifact `unipus-jar` id `13111810515`，9037310 字节，sha256 `b241c68a7f1f1e8c1eedc7ce68cc7d1d06dc40a37f90790bae10a0a14faf4b78` |
| 任务状态 | Task 0：工程底座 = implemented；Task 1：启动脚本 = completed（用户实测通过）；Task 2：人类作答节奏 = implemented（**未做运行时验证**） |
| 下一步 | 学习时长无法由提交接口写入（见「学习时长实测结论」），是否改用「官方播放器在线」路线由规划方决定；不要自行推 `main`、打 tag、发 release。 |

## 任务表

状态只有两档：

- `implemented`：代码/文件 + CI 通过 + 产物齐备，规划方可以验收并推进。
- `completed`：用户在真机或本机实际使用验证过之后才可授予。

| Task | 状态 | 证据 |
| --- | --- | --- |
| Task 0：工程底座 | implemented | `AGENTS.md`、`VERSIONING.md`、`.github/workflows/ci.yml`、`scripts/verify-baseline.sh`（本地退出码 0）、`Documentation/ImplementationStatus.md`；CI run [#41376445981](https://github.com/FaHits/UnipusHelperPro/actions/runs/41376445981) success，artifact `unipus-jar` id `13111810515`（9037310 字节，含 jar 与 `lib/`）。**未做任何运行时验证**。 |
| Task 1：启动脚本 | completed | 新增 `run.bat`（111 行、纯 ASCII、CRLF）与 `.gitattributes`（`*.bat text eol=crlf`）。根因：上游 `run.bat` 是 UTF-8 无 BOM + LF，中文 cmd 按 GBK 读导致行边界塌陷。用户 2026-11-02 在本机双击实测：「现在已经修好了，我实际测试是可以用的」。 |
| Task 2：人类作答节奏 | implemented | 新增 `src/main/java/org/unipus/unipus/TimingPolicy.java`，`Learn.java:340` 在提交前按题型随机等待（`task.waitForCooldown` 复用，可暂停/可中断）。`mvn -B -DskipTests package` 退出码 0。**未做运行时验证**（没有在 GUI 里跑完一个单元）。 |

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

## 学习时长实测结论（2026-11-02，真实账号，只读/可选单元）

上游 README 说「提交请求不会记录学习时长」，实测把它拆成了三条可复核的子结论：

1. **提交接口不写时长，与快慢无关。** 在可选单元 Unit 5（`required=false`）上连续做对照：立即提交 → 单元 `duration` 保持 0；先等 120 秒再提交 → 仍然是 0。判定依据是 `course/api/v2/course_progress/{instance}/{unit}/{openId}/default` 的 `rt.duration_time` 与 `rt.leafs[*].duration`，提交前后都是 0，只有 `state.pass` 从 0 变 1（任务确实被判定完成）。
2. **在提交 body 里塞 `duration` 无效。** 在 payload 末尾追加 `"duration":30` 提交，返回 `code=0` 表示接受请求，但叶子节点 `duration` 仍为 0。
3. **找不到可写的时长端点。** 对 `course_progress/.../default`（JSON 与 form 两种 body）、`.../duration`、课程级 `course_progress/{instance}/{openId}/default`、`course/api/v3/newExploration/progress` 逐个 POST，全部 `http=404`。说明时长由官方播放器（`ucontent.unipus.cn` 内的 WebView，`flag` 里的 `sdk` 位）自己上报，答案提交链路里没有这个入口。

因此：**「按人类节奏等待」能解决秒提交与提交冷却，但不能增加学习时长**。要让时长真实增长，只能让官方播放器保持打开（类似浏览器油猴脚本 `uxudjs/UnipusAIAutoPlayer` 的做法），那是另一条实现路线，需要规划方决策。

参考基线：该账号「新视野大学英语（第四版）读写教程1」的单元时长现状为 Unit 1 = 2574 秒（本人真实学习）、Unit 2 = 6 秒、Unit 3 = 0 秒、Unit 4 = 7 秒，总计 2587 秒——正好对上「机器人做完但几乎没有时长」的现象。

## 未验证项

以下是截至 Task 2 仍未验证的项（Task 1 的启动脚本由用户实测通过，已为 `completed`）：

1. 程序能启动（本机 PID/标题/日志已确认），但**登录、拉课程、答题、提交这一整条主链路没有在 GUI 里完整走过一遍**；Task 2 的节奏等待只在 API 层验证，没有观察过界面上的「等待 → 提交」过程。
2. GUI 在 JDK 25 + flatlaf 3.6.1 下的渲染与交互（字体、缩放、主题）只截过空态主窗口，其他面板、弹窗、F6/F12 调试窗口未点过。
3. `target/unipusHelperPro-1.0.3.jar` + `target/lib/` 这套结构在本机用 `java -jar` 与 `run.bat` 都能启动（用户实测），但分发给他人后的路径/空格/JDK 组合未验证。
4. `run.sh` 仍未补（Linux/macOS 启动脚本），`.gitattributes` 只保证了 `*.bat` 的换行。
5. CI 只在 `ubuntu-latest` 上验证编译与打包，Windows 行为未在 CI 覆盖。
6. 网络相关功能：登录、课程列表、单元进度、答案拉取、提交都在真实账号上跑通过（见「学习时长实测结论」），但**多课程批量、断点续跑、异常重试**未验证。
7. 构建产物不可复现：同一个提交在本机 JDK 25.0.4 上打出的 jar 是 327081 字节，CI 的 JDK 25.0.5 上是 327068 字节（差 13 字节）。不声明可复现构建，也不做字节级对比。

## 发现的问题（只记录，未修改）

1. `src/main/java/org/unipus/util/WebUtils.java:30` 硬编码协议签名常量 `SECRET`（40 位十六进制字符串，本文不复制其值，避免被自己的凭据门禁拦住）。它是上游客户端协议常量，不是用户凭据，因此 `scripts/verify-baseline.sh` 的凭据扫描只覆盖入库的非源码文本文件，不把源码常量算作失败项。是否处理由规划方决定。
2. `README.md` 的 Releases 链接指向上游 `Duster-Cule/UnipusHelperPro/releases/latest`，本 fork 发布后应改指本仓库。
3. `README.md` 让用户运行 `run.bat` / `run.sh`，但仓库里没有这两个文件，也没有打 zip 的脚本。
4. `README.md` 里 `doc/CheckCurrentTask.md` 的链接指向 `Duster-Cule/UnipusHelper`（少了一个 `Pro`）。
5. 本机默认 `JAVA_HOME` 是 JDK 21，直接 `mvn package` 会因 `maven.compiler.target=25` 失败；构建需显式用 JDK 25（见 `AGENTS.md:82`）。
6. `target/lib` 会把 `junit-4.13.2` 与 `hamcrest-core-1.3` 一起复制进去（`maven-dependency-plugin` 的默认行为），分发包会比必要的大约多 400 KB。本项目不做测试，但按红线未改 `pom.xml`。
