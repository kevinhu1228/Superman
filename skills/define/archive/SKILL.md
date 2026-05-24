# superman:archive

**Goal**: 将已完成的变更移入归档目录，更新规格文档，清理当前 phases/ 工作目录。

**Trigger**: VERIFY 阶段所有检查通过，`superman:git-ship` 完成后调用。

---

## 执行步骤

1. 确认 VERIFY 阶段所有检查已通过（verify/review.md 和 spec-check.md 存在且无未解决项）

2. 创建归档目录：

```
mkdir -p .superman/archive/$(date +%Y-%m-%d)-{feature-name}
```

3. 将 phases/ 下的产物复制到归档目录：

```
cp -r .superman/phases/ .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/requirements.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/decisions.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
```

4. 清理当前工作目录：

```
rm -rf .superman/phases/
rm -f .superman/context/size-classification.md
```

Note: 保留 `requirements.md` 和 `decisions.md` 的累积历史（不删除，只是已归档的内容保留在归档中）

5. 向用户确认归档完成，报告归档路径

## 注意事项

- 归档前必须确认 VERIFY 通过，不得在未完成验证时调用
- 归档路径格式：`.superman/archive/YYYY-MM-DD-{feature-name}/`
- 如 `decisions.md` 不存在（S 级需求未生成），跳过复制，不报错
