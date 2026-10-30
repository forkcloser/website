# This file is the project's own — add recipes below. Keep the import: it
# mounts every shared limen task under `just do ...`.
import '.limen/just/main.just'

lint: do::lint::default
fix: do::fix::default
test: external csp repos
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

# The list on the page is the organisation's repositories: every public,
# non-archived one that is a project appears once, under Forks when GitHub
# says it is a fork, and nothing appears that is not there. data/repos.json
# is the committed snapshot the test reads, so the lane runs offline; `just
# regen` refreshes it, and a repository created or archived since fails here
# until the page follows. The repositories that serve or provision the
# organisation (the profile, the infrastructure, the sites themselves) are
# not projects and are left out by name.
repos:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "test: repos" >&2
    # Not projects: the organisation's own plumbing, and testbin, test-only builds of C
    # tools that nothing ships or supports for another use.
    meta='^(\.github|infra|testbin|website|website-.*)$'
    # jq's Windows build ends raw lines with CRLF; the page side never does.
    want=$(jq -r --arg meta "$meta" '.[] | select(.private | not) | select(.archived | not) | select(.name | test($meta) | not) | .name' data/repos.json | tr -d '\r' | sort)
    # A fork is what its UPSTREAM.md says it is (`upstream` in the snapshot: fork,
    # repackaging, port), not what GitHub flags: a fork made by clone and push has no flag,
    # and a repackaging or a port carries an UPSTREAM.md without being a fork.
    forks=$(jq -r --arg meta "$meta" '.[] | select(.private | not) | select(.archived | not) | select(.upstream == "fork") | select(.name | test($meta) | not) | .name' data/repos.json | tr -d '\r' | sort)
    packagings=$(jq -r --arg meta "$meta" '.[] | select(.private | not) | select(.archived | not) | select(.upstream == "repackaging") | select(.name | test($meta) | not) | .name' data/repos.json | tr -d '\r' | sort)
    shown=$(grep -oE 'data-repo="[^"]+"' site/index.html | sed 's/data-repo="//; s/"$//' | sort)
    # The Forks section is the markup between its id and the next section.
    shown_forks=$(sed -n '/<section id="forks"/,/<\/section>/p' site/index.html | grep -oE 'data-repo="[^"]+"' | sed 's/data-repo="//; s/"$//' | sort)
    shown_packagings=$(sed -n '/<section id="packagings"/,/<\/section>/p' site/index.html | grep -oE 'data-repo="[^"]+"' | sed 's/data-repo="//; s/"$//' | sort)
    [ "$(printf '%s\n' "$shown" | uniq -d | wc -l)" -eq 0 ] || { echo "test: a repository is listed twice: $(printf '%s\n' "$shown" | uniq -d | tr '\n' ' ')" >&2; exit 1; }
    # What GitHub's flag still knows that the file does not: a forked repository that never
    # got its UPSTREAM.md. Every flagged fork must carry a class.
    unrecorded=$(jq -r '.[] | select(.private | not) | select(.archived | not) | select(.fork and .upstream == "") | .name' data/repos.json | tr -d '\r')
    [ -z "$unrecorded" ] || { echo "test: forked on GitHub but without an UPSTREAM.md: $(printf '%s\n' "$unrecorded" | tr '\n' ' ')" >&2; exit 1; }
    if [ "$want" != "$shown" ]; then
        echo "test: the page's list differs from data/repos.json (< snapshot, > page):" >&2
        diff <(printf '%s\n' "$want") <(printf '%s\n' "$shown") >&2 || true
        exit 1
    fi
    if [ "$forks" != "$shown_forks" ]; then
        echo "test: the Forks section differs from the repositories whose UPSTREAM.md says Fork of (< snapshot, > page):" >&2
        diff <(printf '%s\n' "$forks") <(printf '%s\n' "$shown_forks") >&2 || true
        exit 1
    fi
    if [ "$packagings" != "$shown_packagings" ]; then
        echo "test: the Packagings section differs from the repositories whose UPSTREAM.md says Repackaging of (< snapshot, > page):" >&2
        diff <(printf '%s\n' "$packagings") <(printf '%s\n' "$shown_packagings") >&2 || true
        exit 1
    fi
    echo "test: the page lists the $(printf '%s\n' "$want" | wc -l | tr -d ' ') project repositories, $(printf '%s\n' "$forks" | wc -l | tr -d ' ') forks and $(printf '%s\n' "$packagings" | wc -l | tr -d ' ') packagings" >&2

# Refresh the committed snapshot of the organisation's repositories from
# GitHub; `just test` then says what the page must follow.
regen:
    #!/usr/bin/env bash
    set -euo pipefail
    gh repo list forkcloser --limit 200 --json name,isArchived,isPrivate,isFork,homepageUrl \
        --jq 'sort_by(.name) | map({name, fork: .isFork, archived: .isArchived, private: .isPrivate, homepage: (.homepageUrl // "")})' > data/repos.json
    # upstream: what the repository's UPSTREAM.md says it is, by its opening words (the
    # book's three classes: Fork of, Repackaging of, Port of); empty when there is none.
    # GitHub's fork flag misses a fork made by clone and push. One request per repository.
    # Only a 404 (no UPSTREAM.md) is an empty class; any other failure (rate limit, auth)
    # aborts, since swallowing it would record a fork as none and the test would then
    # demand it leave the Forks section. The file is fetched raw: no --jq, no base64.
    errfile=$(mktemp "${TMPDIR:-/tmp}/regen.XXXXXX")
    trap 'rm -f "$errfile"' EXIT
    for name in $(jq -r '.[].name' data/repos.json | tr -d '\r'); do
        if body=$(gh api -H 'Accept: application/vnd.github.raw+json' "repos/forkcloser/$name/contents/UPSTREAM.md" 2>"$errfile"); then
            kind=$(printf '%s\n' "$body" | grep -m1 -oE '^(Fork|Repackaging|Port) of' | tr -d '\r' | awk '{print tolower($1)}' || true)
        elif grep -q 'HTTP 404' "$errfile"; then
            kind=''
        else
            echo "regen: reading $name's UPSTREAM.md failed:" >&2; cat "$errfile" >&2; exit 1
        fi
        jq -c --arg name "$name" --arg kind "$kind" 'map(if .name == $name then . + {upstream: $kind} else . end)' data/repos.json > data/repos.json.tmp && mv data/repos.json.tmp data/repos.json
    done
    jq -r '.[] | "\(.name)\t\(if .fork then "flagged" else "" end) \(.upstream)\(if .archived then " archived" else "" end)\(if .private then " private" else "" end)"' data/repos.json
