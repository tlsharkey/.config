#!/usr/bin/env bash
#
# fetch-paper.sh - Locate and download a usable PDF for a paywalled academic
# paper when institutional / university network access is unavailable.
#
# Usage: ./scripts/fetch-paper.sh "<ScienceDirect URL | DOI | paper title>" [output-dir]
#
# Lookup chain (in order):
#   1. Identify paper metadata (title, authors, journal, year, DOI, pages)
#   2. Unpaywall API for an open-access repository copy
#   3. ScienceDirect direct PDF endpoints (/pdf, /pdfft, ?download=true)
#   4. Sci-Hub mirrors (cycle TLDs; parse article page for a .pdf link)
#   5. Validate download is a real PDF; optionally check page count vs expected range
#
# Prints the saved PDF path on success. Exits non-zero if no PDF could be obtained.

set -uo pipefail

INPUT="${1:-}"
OUTDIR="${2:-.}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 '<ScienceDirect URL | DOI | paper title>' [output-dir]" >&2
  exit 1
fi

mkdir -p "$OUTDIR"

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

# ---------- helpers ----------
http_get() {
  curl -s -L --max-time 40 -A "$UA" "$@"
}

urlencode() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
  elif command -v perl >/dev/null 2>&1; then
    perl -MURI::Escape -e 'print uri_escape($ARGV[0], q{^A-Za-z0-9\-\.\~})' "$1"
  else
    printf '%s' "$1"
  fi
}

# Extract a citation_* meta tag's content from HTML.
extract_meta() {
  local html="$1" name="$2"
  printf '%s' "$html" \
    | grep -oiE "<meta[^>]+name=[\"']${name}[\"'][^>]*>" | head -1 \
    | sed -E "s/.*content=[\"']([^\"']+)[\"'].*/\1/" \
    | sed -e 's/&amp;/\&/g; s/&#39;/'"'"'/g; s/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g'
}

# Build a descriptive output filename from metadata.
basename_output() {
  local t="$1" y="$2" a="$3"
  local first_author=""
  first_author="$(printf '%s' "$a" | sed -E 's/;.*//; s/[^A-Za-z0-9]+/_/g; s/^_+|_+$//g')"
  [[ -z "$first_author" ]] && first_author="paper"
  local short_title=""
  short_title="$(printf '%s' "$t" | sed -E 's/[^A-Za-z0-9]+/_/g; s/^_+|_+$//g' | cut -c1-60)"
  [[ -z "$short_title" ]] && short_title="untitled"
  local ypart=""
  [[ -n "$y" ]] && ypart="_${y}"
  echo "${first_author}${ypart}_${short_title}.pdf"
}

# Try downloading a URL; returns 0 if result is a valid PDF saved to $dest.
try_download() {
  local url="$1" dest="$2"
  http_get "$url" -o "$dest" 2>/dev/null
  if file "$dest" 2>/dev/null | grep -qi 'PDF document'; then
    return 0
  fi
  return 1
}

# ---------- normalize input into a DOI if possible ----------
doi=""
title=""
authors=""
journal=""
year=""
firstpage=""
lastpage=""

if [[ "$INPUT" =~ 10\.[0-9]+/.+ ]]; then
  # Looks like a DOI already
  doi="$INPUT"
elif [[ "$INPUT" =~ sciencedirect\.com/(science/article/|pii/) ]]; then
  # ScienceDirect URL: fetch the article page and read citation meta tags
  echo "[*] Fetching ScienceDirect page to identify paper..." >&2
  html="$(http_get "$INPUT")"
  doi="$(extract_meta "$html" "citation_doi")"
  title="$(extract_meta "$html" "citation_title")"
  journal="$(extract_meta "$html" "citation_journal_title")"
  year="$(extract_meta "$html" "citation_date" | grep -oE '[0-9]{4}' | head -1)"
  firstpage="$(extract_meta "$html" "citation_firstpage")"
  lastpage="$(extract_meta "$html" "citation_lastpage")"
  authors="$(printf '%s' "$html" | grep -oiE '<meta[^>]+name=[\"']citation_author[\"'][^>]*>' \
    | sed -E "s/.*content=[\"']([^\"']+)[\"'].*/\1/" | tr '\n' '; ')"
  if [[ -z "$doi" ]]; then
    pii="$(printf '%s' "$INPUT" | grep -oiE 'pii/([A-Za-z0-9]+)' | head -1 | sed -E 's/.*pii\///')"
    echo "[!] ScienceDirect blocked anonymous access (403) and no DOI meta tag was found." >&2
    if [[ -n "$pii" ]]; then
      echo "[!] Paper PII detected: $pii" >&2
      echo "[!] Please re-run with the DOI (e.g. 10.1016/0040-5809(85)90031-0) or the paper title instead." >&2
    else
      echo "[!] Please re-run with the DOI or paper title instead of the ScienceDirect URL." >&2
    fi
    exit 1
  fi
else
  # Treat as a title: try DOI content negotiation via Crossref
  echo "[*] Resolving title via Crossref..." >&2
  encoded="$(urlencode "$INPUT")"
  cr="$(http_get "https://api.crossref.org/works?query.title=${encoded}&rows=1")"
  doi="$(printf '%s' "$cr" | grep -oiE '"DOI"\s*:\s*"[^"]+"' | head -1 | sed -E 's/.*"DOI"\s*:\s*"([^"]+)".*/\1/' | tr -d '\\')"
  title="$(printf '%s' "$cr" | grep -oiE '"title"\s*:\s*\["[^"]+"' | head -1 | sed -E 's/.*"title"\s*:\s*\["([^"]+)".*/\1/')"
  if [[ -z "$doi" ]]; then
    echo "[!] Could not resolve a DOI for the given title." >&2
    exit 1
  fi
fi

# Normalize DOI: Crossref escapes '/' as '\/'; strip backslashes.
doi="$(printf '%s' "$doi" | tr -d '\\')"
doi_enc="$(urlencode "$doi")"
candidate="$OUTDIR/candidate.pdf"

# When only a DOI was given (no title/authors), enrich metadata from Crossref
# so the output filename and page-check are descriptive.
if [[ -n "$doi" && -z "$title" ]]; then
  echo "[*] Enriching metadata from Crossref for DOI $doi..." >&2
  crmeta="$(http_get "https://api.crossref.org/works/${doi_enc}")"
  if [[ -n "$crmeta" ]]; then
    title="$(printf '%s' "$crmeta" | grep -oiE '"title"\s*:\s*\["[^"]+"' | head -1 | sed -E 's/.*"title"\s*:\s*\["([^"]+)".*/\1/' | tr -d '\\')"
    firstpage="$(printf '%s' "$crmeta" | grep -oiE '"first-page"\s*:\s*"[^"]+"' | head -1 | sed -E 's/.*"first-page"\s*:\s*"([^"]+)".*/\1/')"
    lastpage="$(printf '%s' "$crmeta" | grep -oiE '"last-page"\s*:\s*"[^"]+"' | head -1 | sed -E 's/.*"last-page"\s*:\s*"([^"]+)".*/\1/')"
    authors="$(printf '%s' "$crmeta" | grep -oiE '"family"\s*:\s*"[^"]+"' \
      | sed -E 's/.*"family"\s*:\s*"([^"]+)".*/\1/' | tr '\n' '; ')"
  fi
fi

echo "[*] Identified DOI: $doi" >&2
[[ -n "$title" ]] && echo "[*] Title: $title" >&2

# ---------- 2. Unpaywall ----------
echo "[*] Checking Unpaywall for an open-access copy..." >&2
up="$(http_get "https://api.unpaywall.org/v2/${doi_enc}?email=retrieve-paper-pdf@example.org")"
oa_url="$(printf '%s' "$up" | grep -oiE '"url_for_pdf"\s*:\s*"[^"]+"' | head -1 | sed -E 's/.*"url_for_pdf"\s*:\s*"([^"]+)".*/\1/')"
if [[ -n "$oa_url" && "$oa_url" != "null" ]]; then
  echo "[*] Found OA copy via Unpaywall: $oa_url" >&2
  if try_download "$oa_url" "$candidate"; then
    outname="$(basename_output "$title" "$year" "$authors")"
    mv "$candidate" "$OUTDIR/$outname"
    echo "$OUTDIR/$outname"
    exit 0
  fi
fi

# ---------- 3. ScienceDirect direct PDF endpoints ----------
echo "[*] Trying ScienceDirect direct PDF endpoints..." >&2
pii=""
if [[ "$INPUT" =~ sciencedirect\.com/pii/([A-Za-z0-9]+) ]]; then
  pii="${BASH_REMATCH[1]}"
fi
sd_candidates=()
if [[ -n "$pii" ]]; then
  sd_candidates+=("https://www.sciencedirect.com/science/article/pii/${pii}/pdf")
  sd_candidates+=("https://www.sciencedirect.com/science/article/pii/${pii}/pdfft?isDTMRedir=true&download=true")
fi
sd_candidates+=("https://www.sciencedirect.com/science/article/pii/${doi_enc}/pdf")

for url in "${sd_candidates[@]}"; do
  echo "[*]   GET $url" >&2
  if try_download "$url" "$candidate"; then
    echo "[*] Downloaded PDF from ScienceDirect." >&2
    outname="$(basename_output "$title" "$year" "$authors")"
    mv "$candidate" "$OUTDIR/$outname"
    echo "$OUTDIR/$outname"
    exit 0
  fi
done

# ---------- 4. Sci-Hub mirrors ----------
pdf_url=""
mirrors=(st ru ee wf se)
for m in "${mirrors[@]}"; do
  echo "[*] Trying Sci-Hub mirror sci-hub.${m}..." >&2
  sh_html="$(http_get "https://sci-hub.${m}/${doi}")"
  if [[ -z "$sh_html" ]]; then continue; fi
  candidate_url="$(printf '%s' "$sh_html" | grep -oiE "https?://[^\"' ]+\.pdf" | head -1)"
  if [[ -z "$candidate_url" ]]; then
    candidate_url="$(printf '%s' "$sh_html" \
      | grep -oiE "(src|href)=[\"']([^\"' ]+\.pdf[^\"' ]*)[\"']" | head -1 \
      | sed -E "s/^(src|href)=[\"']//; s/[\"']$//")"
  fi
  if [[ -n "$candidate_url" ]]; then
    pdf_url="$candidate_url"
    break
  fi
done

if [[ -z "$pdf_url" ]]; then
  echo "[!] All strategies exhausted; no PDF obtained." >&2
  rm -f "$candidate"
  exit 1
fi

echo "[*] Downloading PDF from $pdf_url" >&2
if ! try_download "$pdf_url" "$candidate"; then
  echo "[!] Downloaded file is not a valid PDF." >&2
  rm -f "$candidate"
  exit 1
fi

# ---------- 5. Optional page-count sanity check ----------
if command -v pdfinfo >/dev/null 2>&1 && [[ -n "${lastpage:-}" && -n "${firstpage:-}" ]]; then
  expected=$(( lastpage - firstpage + 1 ))
  actual="$(pdfinfo "$candidate" 2>/dev/null | grep -iE '^Pages:' | awk '{print $2}')"
  echo "[*] PDF pages: ${actual:-unknown} (expected ~${expected} for pages ${firstpage}-${lastpage})" >&2
fi

outname="$(basename_output "$title" "$year" "$authors")"
mv "$candidate" "$OUTDIR/$outname"
echo "$OUTDIR/$outname"
