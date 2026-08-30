---
name: explore
description: Learning spike for a concept, article, or link
  (/explore <topic or url>). Produces a grounded briefing in chat, an
  interactive concept page under explorations/, and a forced verdict,
  implement now, park, or drop.
disable-model-invocation: true
---

# explore

/explore starts a learning spike. It always ends in one of three
verdicts. Take no implementation action before the verdict is spoken and
answered.

## Input forms

- `/explore <topic>`: a concept, tool, or technique by name.
- `/explore <url>`, or a pasted article: read it first, then name the
  core concept back to the user and continue with that concept. The
  article is the seed, not the authority. Verify its checkable facts per
  the retrieval rules, say where it is out of date, and cite it in the
  briefing and on the page.

## Behavior

1. Ground the facts (retrieval rules below).
2. Read the repo context the concept touches: models, terraform, CI,
   earlier pages in `explorations/`.
3. Give the briefing in chat (briefing shape below).
4. Ask only the 1-2 questions whose answers change the verdict. Discuss.
5. Build the concept page (page procedure below).
6. Force the verdict (verdict rules below).

## Retrieval rules

- Never write a checkable fact from memory. Versions, config keys, API
  shapes, and product names change under you.
- context7 (`resolve-library-id`, then `query-docs`) is the primary source
  for library-shaped facts: dbt configs, macro signatures, adapter
  behavior, YAML schema.
- WebSearch covers conceptual material context7 does not hold.
- If context7 is down, fall back to the official docs site via WebFetch
  and say so in the source line. Ask the user only when no official
  source is reachable.
- If the topic involves a product that renames itself often (dbt does:
  Fusion, Mesh, Semantic Layer), do a live check even when confident.

## Briefing shape

- Fundamentals first: state the general question the concept answers,
  before any repo specifics.
- Then the fit: how the concept fits this lab and what adopting it
  changes, concretely, naming real files. Describe impact and fit, not
  advocacy. "Why it matters" framing is banned; the verdict can be drop.
- Then one comparison question that ties the concept to something the
  user already built here.
- Define each jargon term once, at first use.
- Give a concrete example before the abstract rule.
- At most one "Insight:" callout per section, for the non-obvious point.
- Write the briefing and the page fragment per the `writing` skill.
  Invoke that skill before drafting either.

## Page procedure

1. Write a briefing HTML fragment in the session scratchpad, never in
   the repo: the briefing sections as `<h2>` and
   `<p>` (the sections cover the principle, how the concept fits this
   lab, repo connections naming real files, open questions), at most one
   `<div class="insight">` per section, 2-3 quick-check questions with
   each answer collapsed in `<details><summary>`, and a
   `<p class="source">` line at the bottom. Write every code example as
   `<pre><code class="language-<lang>">` (yaml, sql, python, hcl, ...)
   with the content HTML-escaped; the build script highlights it at
   build time, so an untagged block stays one flat color. The source
   line links every
   source as `<a href="<url>">`, the verified page itself, not a search
   result. Before you link a URL, fetch it and make sure that it
   resolves.
2. Build the page:

   ```text
   python .claude/skills/explore/scripts/build_page.py \
     --briefing <fragment.html> \
     --title "<Concept>" --out explorations/<slug>.html
   ```

3. The result is one self-contained file, styled by the script (Rose
   Pine dark). The build script opens it in the browser. If the host has
   no opener (CI, headless), give the user the path instead. The
   fragment source does not get committed, only the page.

## Verdict

End with exactly one of these. Never end in a hedge.

- Implement now: follow the `flow` skill and start the work.
- Park: add an entry under Parked in `IDEAS.md` with the problem it
  solves, the trigger to reconsider, the source, and the page link.
- Drop: add a one-line entry with the reason under Discarded in
  `IDEAS.md`.
