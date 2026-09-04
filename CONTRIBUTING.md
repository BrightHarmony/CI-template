# Contributing

## 开发流程

1. 从 `main` 创建短生命周期分支。
2. 修改 reusable workflow 时同步更新 fixture、示例和文档。
3. 在本地运行 `bash scripts/validate-repository.sh`。
4. 创建 Pull Request，并说明影响范围、回滚方式和兼容性。

## Review 要求

- 所有变更必须通过 `Template Gate`。
- 至少需要 2 个人工审批。
- `.github/**`、`scripts/**`、`CODEOWNERS` 和安全策略必须由平台团队审批。
- 最新一次可审查 Push 必须由提交者之外的人确认。
- 所有 Review 对话必须解决后才能合并。

不得通过降低权限、跳过测试或移动受保护版本标签来绕过失败的流水线。
