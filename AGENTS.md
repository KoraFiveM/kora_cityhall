# kora_cityhall agent guide

`kora_cityhall` is the Kora city services resource. Its clerk peds let players buy ID cards and licences and apply for jobs, and the server grants pending starter items. It provides `qb-cityhall`. Layout: `fxmanifest.lua`, `shared/config.lua` (Config), `client/client.lua` (peds, blips, target, NUI app), `server/server.lua` (purchases, job applications, starter items, `AddCityJob` export), `locales/`, `tests/` (Lua tests and kora_qa feature file), `docs/`.

## Documentation

User-facing documentation lives in `docs/` (Markdown, published via the Kora Docusaurus site, kora_docs_next). Read `docs/index.md` first; it has the overview and a documentation map. Layout: `index.md` (hub), `installation.md` (install steps, dependencies), `how-to-use.md` (player flow, purchase/job/starter-item flows, architecture), `api/` (`index.md`, `exports.md` for `AddCityJob`, `configuration.md` for every `Config` option and locale keys), and topic pages `items.md`, `events.md`, `database.md`, `compatibility.md`, `troubleshooting.md`. The resource has no commands, so there is no `commands.md`. Update the page that owns the topic instead of adding duplicates.

When you add, change, or remove a feature, config option, command, export, event, item, permission, or database table/column, update the matching page in `docs/` in the same change. Keep docs accurate to the code; do not document behaviour that does not exist.

Docs rules: plain Markdown with `title`/`sidebar_position` front matter (no `id`/`slug`), relative links only between docs pages, assets inside `docs/`, fenced code blocks with a language, and no raw `<`, `>`, `{`, `}` outside code (pages are parsed as MDX). The release version comes from `fxmanifest.lua`'s `version` field.

## Shared contribution standards

Read [CONTRIBUTING.md](CONTRIBUTING.md) before editing. Humans and agents follow
the same Kora standards and self-contained local Lua checks. Preserve the domain
constraints above and in module guides; record policy conflicts explicitly.

Copyright © 2026 Kora Framework (new contribution guidance).
