# Bug Fix Workflow

Systematic approach to investigating and fixing bugs.

## 1. Reproduce & Diagnose

### Reproduce the Bug

- [ ] Gather information (steps, environment, error messages)
- [ ] Reproduce locally with exact steps
- [ ] Document reproduction steps
- [ ] Identify affected component

### Find Root Cause

- [ ] Check recent commits (git log, git bisect if needed)
- [ ] Read relevant code and documentation
- [ ] Consider using **systematic-debugging** for structured root cause analysis
- [ ] Use debugger or add logging to understand execution flow
- [ ] Document root cause (not just symptoms)

## 2. Plan the Fix

- [ ] Address root cause, not symptoms
- [ ] Consider alternative solutions and trade-offs
- [ ] If complex, document approach in `.agents/plans/[YYYY-MM-DD-bugfix-description].md`
- [ ] Avoid bundling unrelated refactoring (separate PR if needed)

## 3. Implement Fix

### Write Failing Test First

- [ ] Consider using **test-driven-development** workflow
- [ ] Write test that reproduces the bug
- [ ] Verify test fails before implementing fix

### Implement

- [ ] Consider using **clean-code-writer** for the implementation
- [ ] Make minimal changes to fix root cause
- [ ] Follow existing code patterns and style
- [ ] Add comments explaining the fix if not obvious

## 4. Verify

- [ ] Confirm failing test now passes
- [ ] Run full test suite (check for regressions)
- [ ] Consider using **code-reviewer** to validate the fix
- [ ] Manually test original bug scenario
- [ ] Test edge cases related to the fix

## 5. Close Out

- [ ] Explain root cause and solution
- [ ] Offer to commit and create pull request with clear description
- [ ] Link to original bug report
- [ ] Confirm fix works in target environment
- [ ] Close bug report

### Learn

- How was this bug introduced? Could it have been prevented?
- Are there similar bugs elsewhere in the codebase?
