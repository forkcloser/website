# forkcloser.org — site copy

The text of https://www.forkcloser.org/, one section per heading, in page order. Each claim
carries its source in a `(src: …)` parenthesis, to strip when set: the organisation's
GitHub description, the profile README in forkcloser/.github, or a repository's own
README or UPSTREAM.md on `main` as of 2026-10-18. Repository names are exact, as GitHub
lists them.

## Hero

**h1:** Forks, ports, packagings and Go replacements of open-source libraries and tools,
for performance and correctness.
(src: Apostasie's wording, 2026-10-18, tightened; the organisation description on GitHub,
"A collection of forks and ports focused on performance and correctness"; the four kinds
are the list below: eight forks, one port (godolint), two packagings, and the Go
replacements compress, dot, hermetic, taciturn and xos)

**Under it, two sentences:** Each fork stands in for the project it comes from, with bugs
fixed, hot paths made faster and hostile input contained; what differs from upstream is
listed change by change, and upstream keeps its credit and its licence. Beside the forks,
upstream programs built for the platforms their official builds miss, and a few tools of
our own.
(src: Apostasie's wording, 2026-10-18; no claim that the changes are upstream-mergeable,
since some are alignment with our own lint baseline and library replacements, per
Apostasie; the licence fact is each fork's LICENSE, upstream's, as the book's mandatory
files chapter requires for inherited code; blake3 README, "switching is a change of import path"; xz
README, "Stability"; erofs README, "About this fork"; each fork's UPSTREAM.md, "Changes
upstream does not have"; forkcloser/.github profile README, "Packagings" and "Own
projects")

The differences list is deliberately not the headline: it is what lets a careful reader
believe the first sentence, not why anyone would switch.

Words kept off the page on purpose: toolchain, rig, fleet, pin, aqua, limen, the book. A
visitor knows none of them; where one was needed it is said in plain terms (a program
"built from its own sources", a tool "installed as one versioned binary").

## The list

**Grouped, three groups, alphabetical within each.** The one question a reader has at each
name on a site about forks is whose code it is: upstream's with changes of ours, upstream's
as we build it, or ours. Those are the three groups, and they are the three classes the
organisation already keeps its repositories in (src: forkcloser/.github profile README,
"Forks", "Packagings", "Rewrites"; farcloser/limen book/forks.md, which separates a code
fork from a repackaging). Flat and alphabetical would put `curl`, a packaging of upstream's
own builds, between two forks whose code differs from upstream, and the reader would have to
open each to learn which is which. By kind (tools, libraries) would split `go-graphviz` from
`dot`, which exist for each other.

Each entry: name, one line, link. The link is the project's site where one exists, else the
repository on GitHub. Two sites exist today, godolint.forkcloser.org and
taciturn.forkcloser.org (both answer 200 as of 2026-10-18); every other link is GitHub.

Left out: `.github`, `infra`, `website`, `website-godolint`, `website-taciturn`. They
serve or provision the organisation and are not things a reader would install or import;
the two site repositories are reached through the sites they serve, and this page is the
`website` repository's own output. No argument for including them.

### Forks

Upstream's code with fixes and features of ours. Each repository's UPSTREAM.md says where
it forked, what it has taken from upstream since, and what it has that upstream does not,
change by change.
(src: the UPSTREAM.md header and tables in each repository below; the standard is
farcloser/limen book/forks.md)

- **blake3** — A fork of lukechampine/blake3, the BLAKE3 hash in Go with AVX2 and AVX-512
  routines and the `bao` verified-streaming encoding; the fork corrects XOF seeking and
  `bao` bounds, and validates key and size instead of panicking.
  https://github.com/forkcloser/blake3
  (src: README.md, first paragraphs; UPSTREAM.md, "Fork of", "Changes upstream does not
  have")
- **erofs** — A fork of erofs/go-erofs: EROFS filesystem images read and created through
  the standard `fs.FS` interface, in pure Go; hardened against untrusted images, corrected
  on several on-disk paths, and faster to read.
  https://github.com/forkcloser/erofs
  (src: README.md, "About this fork")
- **git-validation** — A fork of vbatts/git-validation, which checks a range of commits
  for a DCO sign-off, a subject under 90 characters and no trailing whitespace; here it is
  released as binaries, with its dependencies trimmed and its checks unchanged, and long
  flags take two dashes (`--run`, `--range`).
  https://github.com/forkcloser/git-validation
  (src: README.md, "usage", the default rule set; UPSTREAM.md, "Changes upstream does not
  have", four rows in review on 2026-10-18 for pull requests 7, 8, 12 and 16)
- **go-graphviz** — A fork of goccy/go-graphviz: Go bindings for Graphviz, with Graphviz
  compiled to WebAssembly and run on wazero, no C toolchain and no system Graphviz; the
  fork builds the WebAssembly reproducibly from sources fixed by digest, and types the
  bridge's errors.
  https://github.com/forkcloser/go-graphviz
  (src: README.md, "About this fork"; UPSTREAM.md, "Changes upstream does not have";
  forkcloser/.github profile README, the go-graphviz entry)
- **go-licenses** — A fork of google/go-licenses, which reports and checks the licences of
  a Go package's dependency tree; the fork removes the `report` and `csv` commands and the
  vendored pkgsite behind them, so the tool makes no HTTP request, and is released as
  binaries.
  https://github.com/forkcloser/go-licenses
  (src: README.md, first paragraph; UPSTREAM.md, "Changes upstream does not have"; pull
  request 15, the `cmd/` path and binaries, due in the table per the Forks session)
- **grid-clock-screensaver** — A fork of chrstphrknwtn/grid-clock-screensaver: a word
  clock screensaver for macOS, a 16 × 15 grid of letters whose lit ones read out the time,
  ported to modern macOS; macOS 14 or later, Apple silicon.
  https://github.com/forkcloser/grid-clock-screensaver
  (src: README.md, first paragraph and "Requirements")
- **xz** — A fork of ulikunitz/xz: xz streams read and written in pure Go; the fork
  decodes faster, reads the blocks of a multi-block archive in parallel, and bounds what an
  archive built to break a decoder can make it do.
  https://github.com/forkcloser/xz
  (src: README.md, first paragraphs, `ParallelReader`; forkcloser/.github profile README,
  the xz entry; UPSTREAM.md)
- **yamlfmt** — A fork of google/yamlfmt: a YAML formatter, command line and library, with
  LF line endings by default, path-aware excludes and preserved comment columns.
  https://github.com/forkcloser/yamlfmt
  (src: the repository description on GitHub; README.md, first lines; UPSTREAM.md,
  "Changes upstream does not have")

### Packagings

Upstream programs, unchanged: built or imported from upstream's own sources at a reviewed
commit, for the platforms where no official build fits. (src: forkcloser/.github profile
README, "Packagings"; the curl and openssh READMEs, first paragraphs)

- **curl** — curl with dependable TLS 1.3 for every platform, from curl-for-win, the curl
  project's own reproducible-build system: the Windows packages imported and
  sigstore-verified, Linux and macOS built by curl-for-win's scripts at the same commit.
  https://github.com/forkcloser/curl
  (src: README.md, first paragraphs)
- **openssh** — OpenSSH for macOS with security keys built in, which Apple's build lacks:
  the client set, the agent as a user LaunchAgent, and a server off by default and
  user-scoped when on, built against LibreSSL's libcrypto with libfido2 linked statically,
  as one relocatable package.
  https://github.com/forkcloser/openssh
  (src: README.md, first paragraph and "What the package is")

### Own projects

Our own code, under our own licence: tools written where nothing existing did the job, or
none came as one versioned binary you can install and verify. (src: forkcloser/.github
profile README, "Own projects"; the dot and godolint READMEs on why each exists)

- **compress** — Compression and archiving in pure Go: a streaming library for zstd,
  gzip, xz, lz4 and bzip2, and the `tar`, `xz`, `gzip`, `zstd`, `zip` and `unzip` commands
  built on it, released as binaries for Linux, macOS and Windows.
  https://github.com/forkcloser/compress
  (src: README.md, first paragraph; the v0.2.0 release assets: darwin_arm64, linux_amd64,
  linux_arm64, windows_amd64, windows_arm64)
- **dot** — A Graphviz `dot` command as one static Go binary, on go-graphviz's WebAssembly
  engine: no Graphviz installation, no C toolchain, no system packages.
  https://github.com/forkcloser/dot
  (src: README.md, first paragraph)
- **godolint** — A port of hadolint to Go: the same rules, codes, severities and messages,
  as a library and a command-line tool.
  https://godolint.forkcloser.org/
  (src: README.md, "godolint? hadolint?"; the site's own description at
  https://godolint.forkcloser.org/)
- **hermetic** — The aqua tool manager as one self-contained binary, with an install root,
  a project directory and a `bin` of its own, so the tool versions a project fixes never
  depend on whatever aqua the shell has.
  https://github.com/forkcloser/hermetic
  (src: README.md, first paragraph; the repository description on GitHub)
- **taciturn** — An ssh-agent for keys in the Mac's Secure Enclave, with a per-key policy
  and an audit log, for unattended sessions.
  https://taciturn.forkcloser.org/
  (src: README.md, first paragraph; the repository description on GitHub)
- **xos** — The standard library's `os` with `FILE_SHARE_DELETE` on Windows: files another
  process can rename or delete while this one holds them, and a rename that replaces a file
  readers hold open; call for call the same otherwise.
  https://github.com/forkcloser/xos
  (src: README.md, first paragraph)

## Footer

The Designer's: the site's licence and the organisation's GitHub link. The site is
documentation, so its licence is CC BY-SA 4.0, the book's licence for documentation (src:
farcloser/limen book/mandatory-files.md, "Content"); each project keeps its own licence,
stated on its own page. No warranty line; the licences say it. No reporting line; each
link lands on a repository with its own issue tracker.

## Metadata

- `<title>`: Forkcloser
- `<meta name="description">` and `og:description`: Forks, ports, packagings and Go
  replacements of open-source libraries and tools, for performance and correctness; every
  fork lists what differs from upstream, change by change. (src: the hero above)
