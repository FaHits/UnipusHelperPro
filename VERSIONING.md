# 版本规范

本项目的版本号唯一来源是 `pom.xml` 的 `<version>`。本文只规定取值与命名规则，不改版本号本身；改版本号是规划方的决定。

## 版本号

采用语义化版本 `MAJOR.MINOR.PATCH`，与上游 `Duster-Cule/UnipusHelperPro` 的版本线对齐。

- 当前线：`1.0.3`（上游最后一个发布版本，`pom.xml:9`）。
- `MAJOR`：出现不兼容变更或稳定公开重写时递增，例如 `1.0.3 -> 2.0.0`。
- `MINOR`：增加向后兼容的功能时递增，例如 `1.0.3 -> 1.1.0`。
- `PATCH`：修复缺陷、调整文案、只改工程底座或文档时递增，例如 `1.0.3 -> 1.0.4`。
- `0.x` 期间约定同 `MINOR` 递增特性、`PATCH` 递增修复；达到稳定边界后再进 `1.0.0`。
- 版本号只写纯数字，不带分支名、日期、`beta`、`fork` 之类后缀。

## Git 标签

- 正式版本标签格式：`v<version>`，例如 `v1.0.4`。
- 标签必须指向通过 CI（`.github/workflows/ci.yml`）构建的提交，不接受只在本地构建过的提交。
- 上游历史标签 `v1.0.0`、`v1.0.1`、`v1.0.2`、`v1.0.3` 保持原样，不移动、不重打。
- 本 fork 自己的版本从头叠加在上游线之上，不复用上游已占用的标签名。

## 构建产物命名

- 主 JAR：`unipusHelperPro-<version>.jar`（由 `pom.xml` 的 `artifactId` 与版本决定，当前为 `unipusHelperPro-1.0.3.jar`）。
- 依赖目录：`lib/`（`maven-dependency-plugin` 的 `copy-dependencies` 输出到 `target/lib`，打包分发时与 JAR 同级）。
- 可分发 zip：`UnipusHelperPro-v<version>.zip`，内含 `unipusHelperPro-<version>.jar`、`lib/` 与启动脚本。此命名与上游 README 的下载名保持一致，方便用户沿用习惯。

## 发布流程

1. 规划方确认版本号，执行方改 `pom.xml` 的 `<version>` 并通过 CI。
2. 该提交打 annotated 标签 `v<version>` 并推送。
3. 用同一提交的 CI 产物组 zip，发布到本仓库（`FaHits/UnipusHelperPro`）的 Releases，不指向上游仓库。
4. 在 `Documentation/ImplementationStatus.md` 记录版本、标签、CI run 与产物字节数。

本次（工程底座）不发布、不打标签、不改 `pom.xml` 的 `<version>`。
