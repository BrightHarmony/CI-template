# Agent Review 扩展约定

Agent Review 当前未启用，不存在占位成功任务，也没有 `Agent Review` Required Check。

未来接入时应作为独立 reusable workflow，而不是写进测试或发布工作流：

```text
CI Gate → Agent Review → 人工 Review
```

建议约束：

- 初期只发表评论，不计入人工审批人数。
- 使用独立 GitHub App 或最小权限 Token。
- 权限限制为 `contents: read` 和必要的 PR 评论权限。
- 不允许访问发布、部署或云平台凭据。
- PR 内容、注释和代码都视为不可信输入。
- 不执行 Agent 根据 PR 内容生成的命令。
- 仅高置信度 P0/P1 可以在成熟阶段转为阻断状态。
- 修改 Agent workflow、prompt 或忽略规则时必须由平台 Code Owner 人工审批。

为了避免浪费成本，正式 Agent Review 可在 `CI Gate` 成功后运行；Draft PR 可以另外提供不阻断的早期反馈。
