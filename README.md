# website

The website for Forkcloser as a whole: what it is, and its projects, each linked to its
site where one exists and to GitHub otherwise. One page, static, no build step, served at
https://www.forkcloser.org/.

## Layout

| Path | What |
|------|------|
| `site/` | The site as served. `forkcloser.css` and `forkcloser.js` are the Forkcloser identity (tokens, chrome, light and dark themes, the theme switch), the same files the project sites carry. No build step, no web fonts, no third-party requests. |
| `site/_headers` | Read by Cloudflare Pages: the response headers, a same-origin Content-Security-Policy, HSTS, and friends. |
| `data/repos.json` | A snapshot of the organisation's repositories, as GitHub lists them. The page's list is tested against it; `just regen` refreshes it. |

## Working on it

Open `site/index.html` in a browser; the page is a plain file and needs no server.

```bash
just lint    # the shared limen baseline: limen, just, aqua, yaml, shell, dockerfile, commits
just test    # external: fail if any page loads a resource from another host
             # csp: fail if the CSP hash in _headers is not the hash of the page's inline snippet
             # repos: fail if the page's list differs from data/repos.json, or a fork is not under Forks
just regen   # refresh data/repos.json from GitHub; just test then says what the page must follow
```

When a repository is created, archived or made private, run `just regen`, read the diff, and
update the list on the page to match; the Forks section follows GitHub's own fork flag.

## Publishing

The site is deployed by Cloudflare Pages from this repository: a push to `main` deploys
`site/` as committed, and every other branch gets a preview. There is no build step and no
deploy workflow here. The Pages project, the custom domain and the DNS record are declared
in [forkcloser/infra](https://github.com/forkcloser/infra), not configured by hand.
