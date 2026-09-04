# GitHub Ruleset 配置

审批人数和分支保护不属于 Workflow YAML。请在组织级 Ruleset 中统一配置，或在每个仓库的 `Settings → Rules → Rulesets` 中配置。

仓库提供以下可导入的安全默认配置：

- `config/rulesets/business-main.json`
- `config/rulesets/research-main.json`
- `config/rulesets/template-main.json`
- `config/rulesets/release-tags.json`

配置默认都是 `evaluate`，防止工作流首次运行前锁死默认分支。观察状态名称正确后，再在 GitHub 中切换为 `active`。

也可以使用已具备仓库 Administration 写权限的 GitHub CLI 导入：

```bash
gh api --method POST repos/OWNER/REPOSITORY/rulesets \
  --input config/rulesets/template-main.json
```

导入前应确认仓库中不存在同名 Ruleset，避免重复创建。

## 普通业务仓库

目标：默认分支 `main`。

启用以下规则：

- Require a pull request before merging
- Required approvals: `1`
- Require review from Code Owners
- Require approval of the most recent reviewable push
- Require conversation resolution before merging
- Require status checks to pass before merging
- Block force pushes
- Restrict deletions

Required Status Checks：

- `CI / CI Gate`
- `Security / Security Gate`
- 存在 Dockerfile 时增加 `Container / Container Gate`

如果仓库使用 Merge Queue，启用 Require merge queue，并确认入口工作流包含 `merge_group: checks_requested`。

## Research 仓库

导入 `config/rulesets/research-main.json`：

- Required approvals: `1`
- Require review from Code Owners
- Code Owner 的批准计入这 1 个批准，不额外要求第二人
- Required Status Check: `Research CI / Research Gate`
- 不配置数据库集成检查；PR Gate 保持完全离线

## 中央 CI 模板仓库

目标：默认分支 `main`。

在上述配置基础上调整：

- Required approvals: `2`
- Required Status Check: `Template Gate`
- 平台团队必须作为 `.github/**`、`scripts/**`、`CODEOWNERS` 的 Required Reviewer
- Bypass list 默认为空；紧急账号只允许 Pull Request 模式 bypass，并保留审计记录

## Release Tag

导入 `config/rulesets/release-tags.json`，保护 `v*` Tag：

- 只接受 `v1.2.3` 或 `v1.2.3-rc.1` 形式。
- 禁止删除已经发布的版本 Tag。
- 禁止移动已经发布的版本 Tag。

如果组织要求只有 Release Team 可以创建 Tag，请在 GitHub UI 中为该 Ruleset 增加 Restrict creations，并为 Release Team 配置最小 bypass；模板不预填团队 ID，避免引用错误团队。

## Code Owner 注意事项

`.github/CODEOWNERS` 中配置多个 Owner 时，其中任意一个 Owner 的审批通常即可满足 Code Owner 要求。如果需要“平台团队和安全团队各一人”，应在 Ruleset 中为对应路径分别设置 Required Reviewer team 和审批数量。

## 组织推广

1. 先建立 Evaluate 模式的组织 Ruleset，观察受影响仓库。
2. 修正缺少工作流或状态名称不一致的项目。
3. 将 Ruleset 切换到 Active。
4. 定期审查 bypass、失败率、平均反馈时间和例外数量。
