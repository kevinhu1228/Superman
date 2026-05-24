# superman:api-design

**Goal**: 在设计和实现 API 接口时，遵循一致性、可预测性和向后兼容性原则，避免常见 API 设计错误。

**Trigger**: EXECUTE 阶段涉及 API 设计（新建端点、修改接口、设计 SDK）时调用。

---

## REST API 设计原则

### 资源命名

使用复数名词和连字符，过滤条件用查询参数：

- ✅ `/users/{id}/orders` — 复数名词，层级关系清晰
- ✅ `/orders?status=pending` — 过滤用查询参数
- ❌ `/getUser` — 动词命名
- ❌ `/user_orders` — 下划线（REST 用连字符）

### HTTP 方法语义

| 方法 | 用途 | 幂等性 |
|------|------|--------|
| GET | 读取，不修改状态 | ✅ 幂等 |
| POST | 创建资源 | ❌ 非幂等 |
| PUT | 全量替换（需提供完整资源） | ✅ 幂等 |
| PATCH | 部分更新（只提供要改的字段） | ✅ 幂等 |
| DELETE | 删除 | ✅ 幂等 |

### 状态码

- `200 OK` — 成功读取 / 更新
- `201 Created` — 成功创建，含 Location header
- `204 No Content` — 成功删除（无响应体）
- `400 Bad Request` — 客户端输入错误（含错误详情）
- `401 Unauthorized` — 未认证
- `403 Forbidden` — 已认证但无权限
- `404 Not Found` — 资源不存在
- `409 Conflict` — 状态冲突（如重复创建）
- `422 Unprocessable` — 语法正确但业务逻辑失败
- `500 Internal` — 服务端错误（不暴露细节）

### 错误响应格式（统一）

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Email format is invalid",
    "field": "email"
  }
}
```

## 向后兼容原则

**添加是安全的，删除/修改是危险的：**

- ✅ 添加新的可选字段
- ✅ 添加新的端点
- ✅ 添加新的枚举值（需客户端容错）
- ❌ 删除字段（改为 deprecated + 迁移文档）
- ❌ 修改字段类型
- ❌ 修改 URL 路径（改为重定向 + 保留旧路径）

## 版本管理

推荐 URL 版本方式：`/v1/users`，或使用日期 header：`API-Version: 2024-01-01`。

## 接口文档

每个新接口必须在实现前写接口文档（OpenAPI / 注释），包含：
- 请求参数（类型、是否必填、示例）
- 响应格式（成功和错误）
- 认证要求
- 速率限制（若有）

## 与 superman:spec-review 的关系

API 接口定义写在 spec.md 中，`superman:spec-review` 会检查接口定义是否有歧义或矛盾。API 实现必须与 spec.md 中的定义完全一致。
