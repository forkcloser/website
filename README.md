# website

The website for Forkcloser as a whole: what it is, and its projects, each linked to its
site where one exists and to GitHub otherwise. One page, static, no build step.

## Layout

| Path | What |
|------|------|
| `site/` | The site as served. `forkcloser.css` and `forkcloser.js` are the Forkcloser identity (tokens, chrome, light and dark themes, the theme switch), the same files the project sites carry. No build step, no web fonts, no third-party requests. |
| `site/_headers` | Read by Cloudflare Pages: the response headers, a same-origin Content-Security-Policy, HSTS, and friends. |

## Working on it

Open `site/index.html` in a browser; the page is a plain file and needs no server.

```bash
just lint    # the shared limen baseline: limen, just, aqua, yaml, shell, dockerfile, commits
just test    # external: fail if any page loads a resource from another host
             # csp: fail if the CSP hash in _headers is not the hash of the page's inline snippet
```

## Publishing

The site is deployed by Cloudflare Pages from this repository: a push to `main` deploys
`site/` as committed, and every other branch gets a preview. There is no build step and no
deploy workflow here. The Pages project, the custom domain and the DNS record are declared
in [forkcloser/infra](https://github.com/forkcloser/infra), not configured by hand.
