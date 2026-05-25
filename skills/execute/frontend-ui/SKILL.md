# superman:frontend-ui

**Goal**: Follow engineering discipline in frontend UI development to ensure components are testable, accessible, and have predictable performance, avoiding common frontend pitfalls.

**Trigger**: Invoke during the EXECUTE phase when implementing frontend components, modifying styles, or writing interaction logic.

---

## Component Design Principles

### Single Responsibility

Each component does one thing:

- ✅ `UserAvatar` — displays an avatar
- ✅ `UserCard` — composes Avatar + username + status
- ❌ `UserDashboard` — includes avatar + settings + permissions + notifications (too much)

### Props Design

Define explicit props interfaces; avoid `any` or `object` types:

```typescript
// ✅ explicit props interface
interface ButtonProps {
  label: string;
  variant: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  onClick: () => void;
}
```

### State Management

- **Local state** (UI interaction, temporary values) → `useState` / component state
- **Shared state** (needed by multiple components) → Context / Store
- **Server data** (API responses) → React Query / SWR (automatic caching and revalidation)

Do not mix server data and UI state in the same global store.

## Accessibility

Every interactive element must:

- [ ] `button` has `aria-label` (if there is no text)
- [ ] Images have `alt` attribute (decorative images use `alt=""`)
- [ ] Form `input` is associated with a `label` (`htmlFor` / `aria-labelledby`)
- [ ] Keyboard navigable (logical Tab order, Enter/Space triggers buttons)
- [ ] Color contrast ≥ 4.5:1 (WCAG AA)

## Performance Rules

- Do not compute heavy data in render → use `useMemo` or precompute
- Virtualize lists → use `react-window` or similar for more than 50 items
- Lazy-load images → `loading="lazy"` or Intersection Observer
- Avoid unnecessary re-renders → use `React.memo` judiciously, split parent components

## Testing Strategy

Test behavior, not implementation details:

```typescript
// ✅ test visible behavior
test('shows error message when email is invalid', async () => {
  render(<LoginForm />);
  await userEvent.type(screen.getByLabelText('Email'), 'not-an-email');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
  expect(screen.getByText('Email format is invalid')).toBeInTheDocument();
});
```

## Verifying with Chrome DevTools MCP

After frontend implementation is complete, verify with Chrome DevTools MCP:

1. `navigate_page` → load the target page
2. `take_snapshot` → confirm DOM structure is correct
3. `list_console_messages` → confirm no JS errors
4. `take_screenshot` → visually confirm layout
5. `evaluate_script` → verify key DOM attributes (aria, data-testid)

## Relationship with superman:verification

`superman:verification` observes actual behavior in a real browser; this skill governs engineering discipline during implementation. They complement each other.
