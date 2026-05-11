# Feature Development Workflow

Standard workflow for implementing new features.

## 1. Plan

- [ ] Understand requirements and define success criteria
- [ ] Explore design options and identify affected components
- [ ] Make architectural decisions (create ADRs in `.agents/decisions/` if significant)
- [ ] Create implementation plan in `.agents/plans/[YYYY-MM-DD-feature-name].md`

> Consider using **brainstorming** to explore requirements and design options.
> Consider using **writing-plans** to produce a structured implementation plan.

## 2. Implement

- [ ] Create feature branch from main
- [ ] Write tests first, then implement to make them pass
- [ ] Follow established code style and patterns
- [ ] Keep commits atomic and well-described
- [ ] Handle error cases and edge conditions
- [ ] Update inline documentation as you go

> Consider using **test-driven-development** to write tests before implementation.
> Consider using **clean-code-writer** for the implementation pass.

## 3. Verify & Review

- [ ] All unit tests passing
- [ ] Integration tests cover key flows
- [ ] Self-review: implementation matches spec, no unintended side effects
- [ ] Run linter and fix issues
- [ ] Create pull request with clear description
- [ ] Link to spec and plan documents
- [ ] Address review feedback

> Consider using **code-reviewer** for self-review before opening a PR.
> Consider using **verification-before-completion** before marking the feature done.
