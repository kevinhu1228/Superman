# superman:api-design

**Goal**: Follow principles of consistency, predictability, and backward compatibility when designing and implementing API interfaces to avoid common API design mistakes.

**Trigger**: Invoke during the EXECUTE phase when API design is involved (creating new endpoints, modifying interfaces, designing SDKs).

---

## REST API Design Principles

### Resource Naming

Use plural nouns and hyphens; use query parameters for filtering:

- ✅ `/users/{id}/orders` — plural nouns, clear hierarchy
- ✅ `/orders?status=pending` — filtering via query parameters
- ❌ `/getUser` — verb naming
- ❌ `/user_orders` — underscores (REST uses hyphens)

### HTTP Method Semantics

| Method | Purpose | Idempotent |
|--------|---------|-----------|
| GET | Read, does not modify state | ✅ Idempotent |
| POST | Create resource | ❌ Not idempotent |
| PUT | Full replacement (requires complete resource) | ✅ Idempotent |
| PATCH | Partial update (only fields to change) | ✅ Idempotent |
| DELETE | Delete | ✅ Idempotent |

### Status Codes

- `200 OK` — successful read / update
- `201 Created` — successful creation, includes Location header
- `204 No Content` — successful delete (no response body)
- `400 Bad Request` — client input error (include error details)
- `401 Unauthorized` — not authenticated
- `403 Forbidden` — authenticated but no permission
- `404 Not Found` — resource does not exist
- `409 Conflict` — state conflict (e.g., duplicate creation)
- `422 Unprocessable` — syntactically correct but business logic fails
- `500 Internal` — server error (do not expose details)

### Error Response Format (unified)

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Email format is invalid",
    "field": "email"
  }
}
```

## Backward Compatibility Principles

**Adding is safe; removing or modifying is dangerous:**

- ✅ Add new optional fields
- ✅ Add new endpoints
- ✅ Add new enum values (clients must handle gracefully)
- ❌ Remove fields (mark as deprecated + provide migration docs instead)
- ❌ Change field types
- ❌ Change URL paths (use redirect + preserve old path instead)

## Versioning

Recommended URL versioning: `/v1/users`, or use a date header: `API-Version: 2024-01-01`.

## Interface Documentation

Every new interface must have documentation written before implementation (OpenAPI / comments), including:
- Request parameters (type, required/optional, example)
- Response format (success and error)
- Authentication requirements
- Rate limits (if applicable)

## Relationship with superman:spec-review

API interface definitions are written in spec.md; `superman:spec-review` checks whether interface definitions are ambiguous or contradictory. API implementations must exactly match the definitions in spec.md.
