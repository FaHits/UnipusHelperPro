# AI 开发协作规则

本文件适用于整个仓库（本地路径 `E:\Ai_Agent\Unipus`；`FaHits/UnipusHelperPro`，上游 `Duster-Cule/UnipusHelperPro` 的 fork）。任何 AI 在本仓库开始工作前，必须先读本文件，并按「强制启动流程」确认状态。

聊天记录不是长期事实来源。后续窗口只以仓库内文档、Git 状态和实际构建结果为准。

## 强制启动流程

1. 确认当前目录、Git 分支（应为 `feat/<name>`，不是 `main`）和工作树状态。
2. 读 `Documentation/ImplementationStatus.md` 的「当前交接」块，确认当前允许执行的任务。
3. 读 `VERSIONING.md`，不要擅自改 `pom.xml` 的 `<version>`。
4. 当前用户指令与本文档冲突时，先执行当前用户指令，并在同一任务里同步更新交接文档。
5. 只做任务书里写明的范围；任务书没写的，按「不在范围」处理，写进交付报告的「未验证项」或「发现的问题」，不要顺手做。

## 事实优先级

冲突时按此顺序：

1. 当前用户明确指令与任务书。
2. 本文件。
3. `Documentation/ImplementationStatus.md` 的当前任务和阻塞状态。
4. `VERSIONING.md`。
5. `doc/` 下的上游历史文档（可能已过时，不作为当前事实）。
6. 历史聊天或压缩摘要。

## 沟通

- 面向用户的叙述默认简体中文；代码、命令、日志、标识符保持英文。
- 先给结论与影响，再给行动与证据；没有对应内容就省略。
- 具体、简单的词，不写套话、免责声明、未经请求的对比和重复总结。
- 技术细节只保留对理解结论、判断风险或复现结果有用的部分；命令可复制，路径带行号，字节数给具体数字。

## 单任务规则

- 一次只执行一个任务，不顺手实现后续功能，不预判下一步。
- 不向用户要授权、要范围、要方向；边界以任务书为准。
- 不添加新依赖、新插件、测试框架；不重构与当前任务无关的代码。
- 不覆盖或回滚其他窗口、用户留下的未提交改动。
- 同一分支同一时间只允许一个窗口写入。
- 改动前如用户要求，先用中文说明会改哪些区域、验收标准是什么，得到认可后再动手。
- 发现输入异常（数据截断、字段缺失、凭据位数不符）要当场指出，不要攒到最后汇报。

## 验证方式

这是一个 Windows 平台的 Java Swing GUI 程序（flatlaf + rsyntaxtextarea），不是服务端程序。

- 本项目不做自动化测试，也不引入测试框架。`pom.xml:145` 的 `<skipTests>true</skipTests>` 是既定选择，不要「顺手修好」，也不要为「有测试」而写测试。
- 验证 = `mvn -B -DskipTests package` 成功 + `scripts/verify-baseline.sh` 静态自检通过 + 用户在本机 Windows 上运行确认。
- 构建成功不等于程序能跑。凡是没有在实际机器上点击验证过的行为，一律写入报告的「未验证项」，不要用构建结论替代运行时结论。
- 本机或 CI 的 Java 版本必须满足 `maven.compiler.target=25`；JDK 21 编译会直接失败。

## 完成标准

一个任务只有同时满足以下条件才算完成：

- 任务书要求的文件与改动已落地，且没有越界改动（`src/main/**` 业务代码与 `pom.xml` 的版本/依赖/编译器/surefire 配置不得无故变动）。
- `scripts/verify-baseline.sh` 退出码为 0。
- `Documentation/ImplementationStatus.md` 已写入分支、HEAD、构建结果、产物字节、CI run 与未验证项。
- 交付报告自带可复核证据：提交哈希（40 位）、命令、字节数、CI run id、逐项状态矩阵。

## 版本与发布

- 版本号唯一来源是 `pom.xml` 的 `<version>`，规则见 `VERSIONING.md`。
- 标签只在规划方决定发布时创建，必须指向通过 CI 构建的提交。
- 执行方不推 `main`、不打 tag、不发 release，除非任务书明确要求。

## 提交与同步

任务收尾时：

1. 运行 `git status --short` 与 `git diff --check`。
2. 只暂存本任务涉及的文件，禁止 `git add .`。
3. 提交信息使用 `feat(...)`/`fix(...)`/`docs(...)`/`chore(...)`/`ci(...)` 前缀。
4. 推送到 fork 的当前分支：`git push origin HEAD:<当前分支>`。
5. 用 `git ls-remote origin refs/heads/<当前分支>` 确认远端与本地 HEAD 一致。
6. 推送后才发现内容有误时，只能追加修复提交；不得对已推送历史使用 `--amend`、`rebase` 或 force push。
7. 普通 `git push` 被拒时停止并报告，不要改用 force。

## 工具

- 搜索文件或文本优先 `rg`、`rg --files`；独立的读取和查询尽量批量执行。
- 构建用 `mvn -B`（非交互日志），需要 JDK 25：本机为 `C:\Program Files\Eclipse Adoptium\jdk-25.0.4.7-hotspot`。
- 只有存在真正独立的工作流时才用子 Agent；共享状态、连续决策和简单任务由当前 Agent 直接做完。

## 目录约定

- `src/main/java/org/unipus/{ui,unipus,web,util,log,exceptions}`：上游业务代码，非任务书明确要求不改。
- `doc/`：上游历史文档与图片，保持原样。
- `Documentation/`：本线自己的工程文档（状态账本、规则）。`Documentation/Handoffs/` 只在本地保留，已被 `.gitignore` 忽略，不入库。
- `scripts/`：可复现的验证脚本。
