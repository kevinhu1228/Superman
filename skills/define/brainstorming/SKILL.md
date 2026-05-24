# superman:brainstorming

**Goal**: 通过结构化对话澄清需求，产出用户认可的需求理解，写入 `.superman/context/requirements.md`。

**Trigger**: L/M 级需求完成 size-classify 后，DEFINE 阶段首先调用。

---

## 执行流程

本技能合并 Superpowers brainstorming 框架与 Agent Skills idea-refine（5 问）和 interview-me（访谈式）模式。

### Phase 1: 上下文捕获（实时落盘）

用户说明需求后，**立即**将原文追加到 `.superman/context/requirements.md`：

```
## 需求记录 [{ISO 时间戳}]

**用户原话：**
> {用户原始描述，逐字引用，不做改写}

**AI 理解摘要：** {一句话}
```

### Phase 2: 5 问深挖（Agent Skills idea-refine）

逐一提问，每次一个，等待回答后再问下一个：

1. **目标**：这个改动完成后，谁的什么问题会被解决？
2. **成功标准**：怎么判断它做好了？有什么可以测试/验证的指标？
3. **约束**：有什么不能做的（技术限制、时间、兼容性）？
4. **边界**：这次做什么，明确不做什么？
5. **风险**：最有可能出错的地方是什么？

每个回答立即追加到 `requirements.md`。

### Phase 3: 需求确认

向用户展示整理后的需求摘要，请求确认。确认后继续，不确认则返回 Phase 2。

### Phase 4: 移交

调用 `superman:propose` 创建变更提案目录和规格草稿。
