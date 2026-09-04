# GitHub CI Template

面向 GitHub 组织的可复用 CI 工作流。业务仓库只保留触发条件和少量参数，测试、安全扫描、容器构建和发布逻辑集中维护在本仓库。

## 合并门禁

普通业务仓库的默认合并条件：

1. `CI / CI Gate` 通过。
2. `Security / Security Gate` 通过。
3. 至少 1 个人工审批。
4. 受保护目录必须得到 Code Owner 审批。
5. 所有 Review 对话已解决。
6. 最新一次可审查 Push 已被其他人审批。

本模板仓库影响所有接入项目，应使用更严格的规则：至少 2 个人工审批，其中至少 1 人来自平台团队。

Agent Review 当前不启用，也不计入合并条件。扩展约定见 [docs/agent-review.md](docs/agent-review.md)。

## 提供的工作流

| 工作流 | 用途 | 推荐触发 |
| --- | --- | --- |
| `ci-node.yml` | Node.js 安装、lint、类型检查、测试、构建和聚合 Gate | PR、merge queue |
| `ci-python.yml` | uv 锁定安装、Python 矩阵、lint、类型检查、离线测试、构建和可选仓库策略 | PR、merge queue |
| `security.yml` | Dependency Review、CodeQL、Trivy 文件系统扫描和聚合 Gate | PR、merge queue |
| `build-container.yml` | 无发布权限的容器构建与镜像扫描 | PR、merge queue |
| `publish-container.yml` | 在主干测试通过后构建并推送完整 commit SHA 镜像、SBOM、provenance 和 attestation | `main` |
| `release-container.yml` | 将已存在的 commit 镜像晋级为语义化版本 | `v*` Tag |

所有第三方 Action 都固定到完整 commit SHA，并由 Dependabot 维护。

## 业务仓库接入

复制 `examples/consumer-ci.yml` 到业务仓库的 `.github/workflows/ci.yml`，再完成以下替换：

- 把 `YOUR_ORG/ci-template` 换成中央模板仓库地址。
- 把 `PINNED_TEMPLATE_SHA` 换成已发布版本对应的完整 commit SHA。
- 按项目修改 Node.js 版本、工作目录和命令。
- 如果项目包含 Dockerfile，保留容器构建 Job；否则删除它。

Release 接入参考 `examples/consumer-release.yml`。

Python Research 仓库参考 `examples/consumer-python-research.yml`。中央工作流负责通用 Python 验证，研究仓库通过 `metadata_command` 和 `policy_command` 注入元数据、谱系、历史不可变等领域规则。PR CI 不应连接正式数据库；需要数据库的集成测试保留为开发者本地显式命令。

私有中央仓库还需要在 GitHub 的 Actions 设置中允许组织内其他仓库调用 reusable workflows。

## 仓库初始化清单

1. 将 `.github/CODEOWNERS` 中的 `@YOUR_ORG/platform-team` 替换为真实团队。
2. 按 [docs/rulesets.md](docs/rulesets.md) 导入 `config/rulesets/template-main.json` 和 `config/rulesets/release-tags.json`，验证后将 Ruleset 从 Evaluate 切换为 Active。
3. 启用 Dependency Graph、Dependabot alerts、Secret scanning 与 Push protection（取决于 GitHub 套餐）。
4. 将本仓库发布为 `v0.1.0`，业务仓库使用该版本的完整 commit SHA。
5. 先接入 2 个试点仓库，再推广到整个组织。

## 本地验证

```bash
bash scripts/validate-repository.sh
npm --prefix tests/fixtures/node ci
npm --prefix tests/fixtures/node test
UV_CACHE_DIR=/tmp/ci-template-uv-cache uv sync --directory tests/fixtures/python --frozen --no-install-project
UV_CACHE_DIR=/tmp/ci-template-uv-cache uv run --directory tests/fixtures/python python -m unittest discover -s tests -v
```

完整治理策略见 [docs/governance.md](docs/governance.md)。
