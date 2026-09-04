# CI 与 Review 治理策略

## 门禁模型

确定性检查、人工审查和仓库规则各自负责不同问题：

- CI 负责证明代码可以安装、检查、测试和构建。
- Security Gate 负责依赖变化、静态分析、Secret、配置和漏洞检查。
- 人工 Reviewer 负责需求正确性、架构判断、风险和可维护性。
- Ruleset 负责保证任何人都不能绕过上述条件直接写入 `main`。

Agent Review 当前不启用，也不能替代人工 Reviewer。

## 审批等级

### 普通业务仓库

- 至少 1 个人工审批。
- 受 CODEOWNERS 管理的目录需要 Owner 审批。
- 最新一次可审查 Push 需要由提交者之外的人确认。

### 高风险仓库或目录

以下内容建议至少 2 个人工审批：

- 身份认证、授权、支付和密钥处理。
- 数据库迁移和不可逆数据操作。
- 基础设施、生产部署和网络策略。
- `.github/workflows/**`、`CODEOWNERS` 和 CI 模板。

### Research 仓库

- 至少 1 个人工审批；Code Owner 的审批可以直接计入这一票。
- 业务规则、清算引擎、数据读取、migration、dataset 和 schema 应由 CODEOWNERS 覆盖。
- PR Gate 只执行离线、确定性验证，不读取正式数据库。
- 数据库集成测试没有受控 Runner 时只允许开发者本地显式执行，不创建会永久跳过或长期失败的 Required Check。
- 已进入主干的 RUN 记录保持追加式管理；规则变化必须增加版本化黄金案例。

### 中央 CI 模板仓库

- 至少 2 个人工审批。
- 至少 1 位平台 Code Owner。
- 必须通过 `Template Gate`。
- 不允许管理员日常 bypass。

## Required Check 命名

业务仓库只依赖稳定的聚合检查：

- `CI / CI Gate`
- `Security / Security Gate`
- 如果启用容器检查：`Container / Container Gate`

不要把 CodeQL 矩阵中的单个语言任务或其他动态任务直接设为 Required Check。

中央模板仓库使用：

- `Template Gate`

Research 仓库使用一个稳定聚合检查：

- `Research CI / Research Gate`

## 合并策略

- 默认使用 Squash merge，保持一个 PR 对应一个可回滚提交。
- 高并发仓库建议启用 Merge Queue。
- 使用 Merge Queue 时，入口工作流必须监听 `merge_group`。
- Release Tag 必须来自已进入 `main` 的提交。
- Tag 发布只晋级已有 commit 镜像，不重新构建。

## 失败处理

- 测试失败：修改代码或测试，不允许改成 `continue-on-error` 绕过。
- 安全误报：使用带负责人、原因和失效日期的最小范围例外。
- 模板回归：业务仓库回退到上一个已知正常的完整模板 SHA。
- 紧急修复：仍需通过 Required Checks 和至少 1 位 Code Owner，事后补第二次审查。
