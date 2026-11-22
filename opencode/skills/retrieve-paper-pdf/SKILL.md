---
name: Retrieve Paper PDF
description: Locate and download a usable PDF for a paywalled academic paper (e.g. a ScienceDirect/Elsevier PII link) when you don't have institutional or university network access.
---

# Retrieve Paper PDF

Use this skill whenever you need a PDF of a specific paper but cannot reach it through the publisher's site (paywall, bot detection, no university VPN, away from your regular machine, etc.).

The problem this solves: publisher sites block anonymous PDF downloads, Unpaywall often reports "closed" with no repository copy, and a single Sci-Hub mirror is frequently down. This skill chains several lookup strategies in order and verifies the result is a real, complete PDF before saving it.

## What it does, in order

1. **Identify the paper** — resolves a ScienceDirect URL, a DOI, or a title into metadata (title, authors, journal, year, DOI, page range) by fetching the article page and reading its `citation_*` meta tags (or resolving the DOI).
2. **Unpaywall API** — checks `api.unpaywall.org/v2/<doi>` for an open-access repository copy (fast, no download if one exists).
3. **ScienceDirect direct PDF endpoints** — tries `/pdf`, `/pdfft`, and `?download=true` variants (usually blocked without a session, but worth one attempt).
4. **Sci-Hub mirrors** — cycles through several Sci-Hub TLDs (`.st`, `.ru`, `.ee`, `.wf`, `.se`), parses the article page for a `.pdf` link, and downloads it.
5. **Validate** — confirms the download begins with `%PDF-`, optionally checks the page count against the expected page range, then saves it with a descriptive filename (`<Author1>_<Author2>_<Year>_<short title>.pdf`).

## How to use

```bash
# From the skill directory:
./scripts/fetch-paper.sh "https://www.sciencedirect.com/science/article/abs/pii/0040580985900310"

# By DOI (most reliable input):
./scripts/fetch-paper.sh "10.1016/0040-5809(85)90031-0"

# By title (resolved via Crossref):
./scripts/fetch-paper.sh "A model for the dynamics of an annual plant population"

# Choose output directory:
./scripts/fetch-paper.sh "<URL|DOI|title>" ~/Downloads/papers
```

The script prints the path of the saved PDF on success.

### Input preference

- **DOI** (e.g. `10.1016/0040-5809(85)90031-0`) — most reliable; metadata (title, authors, pages) is enriched from Crossref automatically.
- **Title** — resolved to a DOI via Crossref, then processed like a DOI lookup.
- **ScienceDirect URL** — best-effort only. Elsevier blocks anonymous fetches with a 403, so the `citation_*` meta tags (which carry the DOI) usually aren't visible. When that happens the script prints the PII and asks you to supply the DOI or title instead.

## Example

Input:
```
10.1016/0040-5809(85)90031-0
```

Resolved paper:
- Holsinger, K.E. & Roughgarden, J. (1985). *A model for the dynamics of an annual plant population.* Theoretical Population Biology, 28: 288–313. DOI: 10.1016/0040-5809(85)90031-0

Outcome: Unpaywall reports `closed` (no OA copy); ScienceDirect direct endpoints are blocked; a Sci-Hub mirror yields a valid 26-page PDF (matching pages 288–313), saved as:

```
Holsinger_A_model_for_the_dynamics_of_an_annual_plant_population.pdf
```

## Notes

- Sci-Hub mirrors are inherently flaky — a mirror that works one minute may be down the next. The script cycles through several TLDs (`.st`, `.ru`, `.ee`, `.wf`, `.se`) and reports exhaustion only if all fail. Re-running often succeeds on a different mirror.
- If every strategy fails, the script exits non-zero. The metadata step (when it runs) surfaces author names; consider emailing the corresponding author directly as a fallback.
- Never redistribute the PDF beyond your own personal use; this skill is for personal access to a paper you are entitled to obtain.

`~/.config/opencode/skills/retrieve-paper-pdf/scripts/fetch-paper.sh`

## Requirements

- `curl`, `grep`, `sed`, `file` (standard on most Linux/macOS)
- `python3` or `perl` (for URL-encoding; the script falls back to raw input if neither is present)
- `pdfinfo` (from poppler-utils) — optional; only used for the page-count sanity check

## Rules for the agent

- Always run `scripts/fetch-paper.sh` with the paper identifier; do not hand-construct download URLs.
- Prefer a DOI over a URL or title when available (most reliable).
- If every strategy fails, report which ones were tried and suggest the user email the corresponding author directly (the metadata step surfaces author names/emails where available).
- Never redistribute the PDF beyond the user's own use; this skill is for personal access to a paper you are entitled to obtain.
