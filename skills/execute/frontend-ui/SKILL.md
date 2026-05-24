# superman:frontend-ui

**Goal**: 在前端 UI 开发中遵循工程纪律，确保组件可测试、可访问、性能可预期，避免常见前端陷阱。

**Trigger**: EXECUTE 阶段涉及前端组件实现、样式修改、交互逻辑时调用。

---

## 组件设计原则

### 单一职责

每个组件只做一件事：

- ✅ `UserAvatar` — 显示头像
- ✅ `UserCard` — 组合 Avatar + 用户名 + 状态
- ❌ `UserDashboard` — 包含头像 + 设置 + 权限 + 通知（太多）

### Props 设计

定义明确的 props interface，避免 `any` 或 `object` 类型：

```typescript
// ✅ 明确的 props interface
interface ButtonProps {
  label: string;
  variant: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  onClick: () => void;
}
```

### 状态管理

- **本地状态**（UI 交互、临时值）→ `useState` / 组件内 state
- **共享状态**（多组件需要）→ Context / Store
- **服务端数据**（API 响应）→ React Query / SWR（自动缓存和重验证）

禁止将服务端数据和 UI 状态混在同一个全局 store。

## 可访问性（Accessibility）

每个交互元素必须：

- [ ] `button` 有 `aria-label`（若无文本）
- [ ] 图片有 `alt` 属性（装饰图用 `alt=""`）
- [ ] 表单 `input` 关联 `label`（`htmlFor` / `aria-labelledby`）
- [ ] 键盘可导航（Tab 顺序逻辑，Enter/Space 触发按钮）
- [ ] 颜色对比度 ≥ 4.5:1（WCAG AA）

## 性能规则

- 不在 render 中计算重型数据 → 使用 `useMemo` 或预计算
- 列表使用虚拟化 → 超过 50 项使用 `react-window` 或类似库
- 图片懒加载 → `loading="lazy"` 或 Intersection Observer
- 避免不必要的 re-render → 合理使用 `React.memo`，父组件拆分

## 测试策略

测试行为，不测试实现细节：

```typescript
// ✅ 测试可见行为
test('shows error message when email is invalid', async () => {
  render(<LoginForm />);
  await userEvent.type(screen.getByLabelText('Email'), 'not-an-email');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
  expect(screen.getByText('Email format is invalid')).toBeInTheDocument();
});
```

## 使用 Chrome DevTools MCP 验证

前端实现完成后，用 Chrome DevTools MCP 验证：

1. `navigate_page` → 加载目标页面
2. `take_snapshot` → 确认 DOM 结构正确
3. `list_console_messages` → 确认无 JS 错误
4. `take_screenshot` → 视觉确认布局
5. `evaluate_script` → 验证关键 DOM 属性（aria, data-testid）

## 与 superman:verification 的关系

`superman:verification` 负责在真实浏览器中观察实际行为，本技能负责实现时的工程纪律。两者互补。
