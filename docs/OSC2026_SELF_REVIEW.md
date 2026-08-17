# OSC 2026 项目自查报告

## 总体判断

`moonbarcode` 是一个有效的 MoonBit 项目，定位为纯 MoonBit 原生的一维条码生成、校验与渲染工具库。项目已具备 README、许可证、CI、CLI、测试和 mooncakes 发布记录，适合作为 MoonBit 应用生态/基础组件方向提交。

当前主要风险是提交历史偏少：本地检查时原始历史为 8 个提交，低于申报材料建议的 10-20 个有效 commits。后续应继续以真实功能、文档、测试和发布维护形成有意义提交，不应使用空提交或无意义拆分。

## 提交前需要处理的问题

- Gitlink 仓库尚未在本地 remote 中体现。提交申报前需要导入 Gitlink，并确认 GitHub 与 Gitlink 默认分支均指向包含主要代码、README、LICENSE、CI 的分支。
- 项目核心 MoonBit 源码约 1789 行，不含测试；含测试约 2316 行。低于章程 4-10k 有效 MoonBit 行数参考范围，建议在申报书中强调项目边界清晰、条码标准覆盖、CLI/渲染/测试完整性，并继续补充 ITF-14、UPC-E、补充码等实质功能。
- README 中“库用法（开发中）”仍偏占位，后续应补成当前真实 API 的最小可运行示例。

## 需要进一步确认的问题

- Gitlink 仓库链接是什么，是否已经从 GitHub 完整同步。
- 申报人 GitHub/mooncakes 账号是否就是 `fan-ere`，与 `moon.mod` 的包命名空间一致。
- 项目是否完全原创；若编码表、测试样例或生成脚本参考了外部规范或项目，应在 README 或专门文档中说明来源、许可证和参考范围。
- 是否要将版本从 `0.1.0` 提升到 `0.1.1` 后再次发布到 mooncakes.io；当前 `0.1.0` 已存在，重复发布会被拒绝。

## 建议改进

- 补充 `docs/spec-sources.md`，说明 EAN/UPC、Code 39、Code 93、Code 128、GS1、ISBN/ISSN/GTIN 的参考资料范围。
- 增加更多边界测试：非法字符、校验位错误、Code 128 子集切换、GS1 FNC1、空输入、超长输入。
- 增加示例输出文件或截图，展示 SVG / ASCII / ANSI 效果。
- 在 CI 中保留多目标 check/test/build，并在发布前运行 `moon publish --dry-run`。

## 已检查的证据

- `moon.mod`：包名为 `fan-ere/moonbarcode`，许可证为 `Apache-2.0`，仓库为 `https://github.com/fan-ere/moonbarcode`。
- `moon check`：通过。
- `moon test`：46 个测试全部通过。
- `moon check --deny-warn`：通过。
- `moon test --deny-warn`：46 个测试全部通过。
- `moon fmt --check .`：通过。
- `moon info`：通过且没有留下 git diff。
- `moon publish --dry-run`：包校验和提取后检查通过，但服务端返回 `0.1.0` 版本已存在。
- `git remote show origin`：远程默认分支为 `main`，本地 `main` 已跟踪 `origin/main`。
- `git rev-list --count HEAD`：原始历史为 8 个提交，均在 2026-04-29 之后。

## 可选环境建议

- 当前 MoonBit 工具链版本满足要求：`moon 0.1.20260807`，`moonc v0.10.7`。
- 当前环境未发现 `moonbitlang/skills` 本地技能目录。后续开发 MoonBit 项目时，建议安装以获得更贴近 MoonBit 包结构、测试和工具链的辅助。
