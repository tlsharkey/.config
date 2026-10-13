# Large Table Test File

This file tests table rendering with long content and many columns.

## Table with Long Cell Content

| Feature | Description | Notes |
|---------|-------------|-------|
| Table wrapping | When enabled, cells with long text wrap to fit the window width instead of extending horizontally. This is particularly useful when you have verbose descriptions or long links in table cells that would otherwise require horizontal scrolling to read. | This is a very long note that should wrap across multiple lines when the table is rendered with wrapping enabled. It demonstrates how the plugin handles content that exceeds the column width. |
| Cell padding | Each cell has padding between the content and the border characters for readability. The default padding is 1 space on each side. | Padding helps make tables less cramped and easier to read. |
| Alignment | Tables support left, right, center, and default alignment using the standard markdown alignment syntax. | Right-aligned numbers are particularly useful for financial data. |

## Table with Many Columns

| ID | Name | Category | Status | Priority | Assigned | Due Date | Progress | Budget | Actual | Variance | Notes |
|----|------|----------|--------|----------|----------|----------|----------|--------|--------|----------|-------|
| 1 | Task Alpha | Backend | In Progress | High | Alice | 2025-12-01 | 60% | $10,000 | $7,500 | -$2,500 | On track |
| 2 | Task Beta | Frontend | Complete | Medium | Bob | 2025-11-15 | 100% | $5,000 | $4,800 | +$200 | Under budget |
| 3 | Task Gamma | Infrastructure | Planning | Low | Carol | 2026-01-10 | 10% | $15,000 | $0 | -$15,000 | Not started |
| 4 | Task Delta | Backend | Blocked | Critical | Dave | 2025-12-15 | 30% | $8,000 | $2,000 | -$6,000 | Waiting for API |
| 5 | Task Epsilon | Testing | In Progress | High | Eve | 2025-11-30 | 45% | $6,000 | $2,700 | -$3,300 | On track |

## Partial/Malformed Table

This table has mismatched column counts (header has 3 columns, delimiter has 1, body rows have 1 and 2 columns).

| some | table | headers |
| --- |
| row 1, col 1 |
| row 2, col 1 | row 2, col 2|

## Table with Very Long Words (URLs, Paths)

| Resource | URL | Description |
|----------|-----|-------------|
| Documentation | https://example.com/very/long/path/to/documentation/that/extends/far/beyond/normal/column/width/limits | Link to comprehensive documentation |
| Repository | https://github.com/some-organization/very-long-repository-name-with-many-words | Main source repository |
| API | https://api.example.com/v2/resources/very-long-endpoint-path/with/many/segments | REST API endpoint |

## Table with Mixed Content

| Component | Status | Details |
|-----------|--------|---------|
| `pipe_table.wrap` | ✅ Enabled | Wraps cells to fit window |
| `min_width` | 3 | Minimum column width |
| `padding` | 1 | Space between content and border |
| `preset` | round | Border style with rounded corners |
| `style` | full | Complete table with borders |
