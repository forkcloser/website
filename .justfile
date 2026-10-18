# This file is the project's own — add recipes below. Keep the import: it
# mounts every shared limen task under `just do ...`.
import '.limen/just/main.just'

lint: do::lint::default
fix: do::fix::default
test: external csp
# The security workflow runs `just security`.
security: do::security::default

# The pages must load nothing from elsewhere: no web fonts, no CDN scripts,
# no hotlinked images. Every load is a request to a third party on each
# visit, and an unpinned dependency on that party's continued behaviour —
# the same objection the projects these sites describe make about binaries.
# Matched per line, which is how these pages are written; a `canonical` or
# `og:` link is a declaration, not a load, and is not matched.
external:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "test: external" >&2
    shopt -s nullglob
    files=(site/*.html site/*.css)
    [ ${#files[@]} -gt 0 ] || { echo "test: nothing under site/ to check" >&2; exit 1; }
    pattern='<link[^>]*rel="(stylesheet|preconnect|preload|modulepreload|icon|manifest)"[^>]*href="https?://'
    pattern="$pattern"'|<link[^>]*href="https?://[^>]*rel="(stylesheet|preconnect|preload|modulepreload|icon|manifest)"'
    pattern="$pattern"'|<(script|img|iframe|source|video|audio|object|embed)[^>]*src="https?://'
    pattern="$pattern"'|@import[^;]*https?://|url\(["'"'"']?https?://'
    # grep exits 1 on no match (the pass) and 2 on a read error (a failure).
    status=0
    grep -nE "$pattern" "${files[@]}" > "${TMPDIR:-/tmp}/external.$$" || status=$?
    hits="${TMPDIR:-/tmp}/external.$$"
    if [ "$status" -eq 0 ]; then
        cat "$hits" >&2
        rm -f "$hits"
        echo "test: the site loads resources from elsewhere (listed above)" >&2
        exit 1
    fi
    rm -f "$hits"
    [ "$status" -eq 1 ] || exit "$status"
    echo "test: no external resource loads" >&2

# The Content-Security-Policy in site/_headers allows one inline script, the
# theme snippet in the page head, by the hash of its exact bytes. Recompute
# the hash from the page and fail if the header carries another: a changed
# snippet would otherwise ship blocked, and the page would paint in the
# wrong theme with nothing in the build to say so.
csp:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "test: csp" >&2
    snippet=$(grep -oE '<script>[^<]*</script>' site/index.html | sed -e 's/^<script>//' -e 's,</script>$,,')
    [ "$(printf '%s\n' "$snippet" | wc -l)" -eq 1 ] || { echo "test: expected exactly one inline script in site/index.html" >&2; exit 1; }
    want="sha256-$(printf '%s' "$snippet" | openssl dgst -sha256 -binary | base64)"
    grep -qF "'$want'" site/_headers || { echo "test: site/_headers does not allow the page's inline snippet; its hash is $want" >&2; exit 1; }
    echo "test: the CSP hash matches the inline snippet" >&2
