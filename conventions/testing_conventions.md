# Testing Conventions

## Purpose

Defines generic testing conventions for integration test quality, ensuring tests catch real bugs through proper use of real dependencies, strong assertions, and comprehensive edge case coverage.

## Scope

This document covers:
- When to mock vs when to use real dependencies
- Assertion strength requirements
- Edge case testing patterns
- Database state verification
- Error handling test patterns

This document does NOT cover:
- Test types and coverage requirements (see repository-specific testing standards)
- Fixture standards (see repository-specific fixture guidelines)
- Framework-specific patterns (see repository documentation)

## Integration Test Principles

### 1. Use Real Dependencies for Integration Tests

**MUST NOT**: Mock the system under integration in integration tests.

**Why**: Mocking hides bugs in integration points (wrong API calls, incorrect parameters, schema mismatches).

**When to mock**:
- External APIs (payment providers, third-party services)
- File system operations
- Time/date functions (for determinism)
- Infrastructure services (object storage, message queues)

**When NOT to mock**:
- Database queries and operations
- Internal service methods
- Business logic
- Data validation logic

**Generic example**:
```typescript
// ❌ Incorrect - mocked database
it("should find records", async () => {
  vi.spyOn(db, "query").mockResolvedValue([{ id: "1", name: "Test" }]);
  const records = await service.getRecords();
  expect(records.length).toBe(1);
});

// ✅ Correct - real database
it("should find records", async () => {
  // Seed test data
  await db.insert("records", { id: "1", name: "Test" });
  
  // Test actual query
  const records = await service.getRecords();
  expect(records.length).toBe(1);
  expect(records[0].name).toBe("Test");
  
  // Verify database state
  const stored = await db.query("SELECT * FROM records WHERE id = $1", ["1"]);
  expect(stored[0].name).toBe("Test");
});
```

### 2. Use Strong Assertions

**MUST**: Verify correct outcomes, not just absence of errors.

**Why**: Weak assertions allow bugs to pass when operations complete but produce incorrect results.

**Generic patterns**:

```typescript
// ❌ Weak - only checks something happened
expect(result.processed + result.skipped).toBeGreaterThan(0);
expect(result.error).toBeUndefined();
expect(data).toBeDefined();

// ✅ Strong - verifies correct outcome
expect(result.succeeded).toBeGreaterThan(0);
expect(result.failed).toBe(0);
expect(data.length).toBe(expectedCount);
expect(data[0].status).toBe("completed");

// ✅ Even stronger - verifies database state
const dbState = await db.query("SELECT status FROM tasks WHERE id = $1", [taskId]);
expect(dbState[0].status).toBe("completed");
```

### 3. Test Edge Cases Explicitly

**MUST**: Test null, default values, empty collections, and boundary conditions.

**Why**: Edge cases reveal hidden assumptions and common bugs.

**Required edge case categories**:

1. **Null vs non-null**:
   ```typescript
   it("handles null value", async () => { ... });
   it("handles non-null value", async () => { ... });
   it("queries both null and non-null", async () => { ... });
   ```

2. **Default vs actual values**:
   ```typescript
   it("handles default value", async () => { ... });
   it("handles custom value", async () => { ... });
   it("queries both default and custom", async () => { ... });
   ```

3. **Empty vs populated**:
   ```typescript
   it("handles empty collection", async () => { ... });
   it("handles single item", async () => { ... });
   it("handles multiple items", async () => { ... });
   ```

4. **Valid vs invalid**:
   ```typescript
   it("accepts valid input", async () => { ... });
   it("rejects invalid input", async () => { ... });
   it("handles boundary values", async () => { ... });
   ```

### 4. Test Foreign Key Constraints

**MUST**: When tables have foreign key constraints, explicitly test constraint behavior.

**Why**: Foreign key violations often fail silently in application code.

**Required tests**:
```typescript
describe("foreign key constraints", () => {
  it("should allow null (if FK allows null)", async () => {
    const result = await db.insert("table", {
      id: "1",
      foreign_id: null, // Should succeed
    });
    expect(result.error).toBeNull();
  });
  
  it("should reject non-existent reference", async () => {
    const result = await db.insert("table", {
      id: "1",
      foreign_id: "non-existent", // Should fail
    });
    expect(result.error).toBeDefined();
    expect(result.error.code).toBe("23503"); // FK violation (PostgreSQL)
  });
  
  it("should accept valid reference", async () => {
    await db.insert("referenced_table", { id: "ref-1" });
    
    const result = await db.insert("table", {
      id: "1",
      foreign_id: "ref-1", // Should succeed
    });
    expect(result.error).toBeNull();
  });
});
```

### 5. Verify Database State After Operations

**MUST**: Query database to verify actual state after operations.

**Why**: Operations can report success but leave incorrect or incomplete state.

**Pattern**:
```typescript
it("should update record status", async () => {
  // Setup
  await db.insert("records", { id: "1", status: "pending" });
  
  // Operation
  const result = await service.updateStatus("1", "completed");
  expect(result.success).toBe(true);
  
  // Verify database state (REQUIRED)
  const stored = await db.query("SELECT status FROM records WHERE id = $1", ["1"]);
  expect(stored[0].status).toBe("completed");
  
  // Verify no side effects
  const count = await db.query("SELECT COUNT(*) FROM records");
  expect(count[0].count).toBe("1"); // Still just 1 record
});
```

### 6. Test Silent Error Handling

**MUST**: When functions catch errors without throwing, test both success and failure paths.

**Why**: Silent failures (try/catch that logs but doesn't throw) hide bugs.

**Pattern**:
```typescript
describe("error handling", () => {
  it("should succeed with valid data", async () => {
    await service.operation(validData);
    
    // Verify database state (REQUIRED)
    const stored = await db.query("SELECT * FROM table");
    expect(stored.length).toBe(1);
  });
  
  it("should log error without throwing", async () => {
    const logSpy = vi.spyOn(logger, "error");
    
    // Trigger error condition
    await service.operation(invalidData);
    
    // Verify error was logged
    expect(logSpy).toHaveBeenCalled();
    
    // Verify no data was stored (REQUIRED)
    const stored = await db.query("SELECT * FROM table");
    expect(stored.length).toBe(0);
  });
});
```

### 7. Test Complete Workflows

**MUST**: Test end-to-end workflows that verify all steps work together.

**Why**: Individual step tests can pass while the complete workflow fails.

**Pattern**:
```typescript
it("should complete workflow from input to final state", async () => {
  // Step 1: Initial operation
  const input = await service.createInput(data);
  expect(input.id).toBeDefined();
  
  // Verify step 1 database state
  const inputState = await db.query("SELECT status FROM inputs WHERE id = $1", [input.id]);
  expect(inputState[0].status).toBe("created");
  
  // Step 2: Process
  const processResult = await service.process(input.id);
  expect(processResult.success).toBe(true);
  
  // Verify step 2 database state
  const processedState = await db.query("SELECT status FROM inputs WHERE id = $1", [input.id]);
  expect(processedState[0].status).toBe("processed");
  
  // Step 3: Finalize
  const finalResult = await service.finalize(input.id);
  expect(finalResult.success).toBe(true);
  
  // Verify final database state
  const finalState = await db.query("SELECT status FROM inputs WHERE id = $1", [input.id]);
  expect(finalState[0].status).toBe("completed");
  
  // Verify side effects
  const outputs = await db.query("SELECT * FROM outputs WHERE input_id = $1", [input.id]);
  expect(outputs.length).toBeGreaterThan(0);
});
```

## Common Pitfalls

### Pitfall 1: Assuming Success
```typescript
// ❌ Assumes operation succeeded
const result = await service.operation();
expect(result).toBeDefined();

// ✅ Verifies operation succeeded AND state is correct
const result = await service.operation();
expect(result.success).toBe(true);

const dbState = await db.query("SELECT * FROM table WHERE id = $1", [result.id]);
expect(dbState.length).toBe(1);
expect(dbState[0].field).toBe(expectedValue);
```

### Pitfall 2: Mocking Integration Points
```typescript
// ❌ Mocks the system being integrated
vi.spyOn(db, "query").mockResolvedValue([...]);

// ✅ Uses real database
await db.insert(...);
const result = await service.query(...);
```

### Pitfall 3: Weak Workflow Assertions
```typescript
// ❌ Only checks completion
expect(result.processed).toBeGreaterThan(0);

// ✅ Checks correct outcome
expect(result.succeeded).toBeGreaterThan(0);
expect(result.failed).toBe(0);
```

### Pitfall 4: Missing Edge Cases
```typescript
// ❌ Only happy path
it("should process item", async () => {
  const result = await process({ value: "valid" });
  expect(result.success).toBe(true);
});

// ✅ Tests edge cases
describe("edge cases", () => {
  it("handles null value", async () => { ... });
  it("handles empty value", async () => { ... });
  it("handles invalid value", async () => { ... });
  it("handles default value", async () => { ... });
});
```

### Pitfall 5: Not Verifying Database State
```typescript
// ❌ Trusts return value
const result = await service.create(data);
expect(result.id).toBeDefined();

// ✅ Verifies database
const result = await service.create(data);
const stored = await db.query("SELECT * FROM table WHERE id = $1", [result.id]);
expect(stored.length).toBe(1);
expect(stored[0]).toMatchObject(expectedState);
```

## Validation Checklist

Before considering integration test complete:

- [ ] Test uses real database operations (no mocked queries)
- [ ] Assertions verify correct outcomes (not just "no error")
- [ ] Edge cases tested (null, defaults, empty, invalid)
- [ ] Foreign key constraints tested (if applicable)
- [ ] Database state verified after operations
- [ ] Both success and failure paths tested (for error handling)
- [ ] Complete workflow tested (not just individual steps)
- [ ] Test cleanup prevents data leaks
- [ ] Test is deterministic (repeatable results)

## Application to Repositories

**For each repository using foundation:**

1. Create repository-specific testing standards that reference this document
2. Add repository-specific examples (table names, workflows, schemas)
3. Apply these principles to repository's technology stack (database, ORM, etc.)
4. Customize edge case tests for repository's domain (default users, special values, etc.)

**Example repository application**:
```markdown
# Repository Testing Standards

**Reference**: `foundation/conventions/testing_conventions.md` — Generic principles

## Applying to Our Stack

We use PostgreSQL via Supabase. Integration tests MUST:
- Use real Supabase client (no mocked `supabase.from()`)
- Test null vs default UUID for user_id
- Test foreign key constraints to auth.users
- Verify database state after all operations

[Repository-specific examples with actual table names and schemas]
```

## Related Documents

- Repository-specific testing standards (varies by repo)
- Repository-specific fixture standards (varies by repo)
- `foundation/conventions/code_conventions.md` — Code style and patterns
