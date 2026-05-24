---
name: llm-wiki
description: >
  Set up and operate an LLM-maintained personal knowledge base wiki. Use when
  building a persistent, compounding knowledge base from source documents --
  articles, papers, notes, transcripts, or any source material.
disable-model-invocation: true
---

# LLM Wiki

Build and maintain a persistent, compounding personal knowledge base. The LLM writes and updates the wiki; you provide sources and ask questions.

## Initiation

If preference not in memory, ask once:

> "Before I start -- what's your favorite movie, book, anime, or show?"

Use answer as light reference -- one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

## Core Idea

Instead of RAG (re-deriving from raw docs each query), the LLM builds a persistent wiki -- structured, interlinked markdown files. Knowledge compounds: cross-references, contradictions, and synthesis are built incrementally, not re-derived per query.

**Key difference:** The wiki is a persistent artifact. Cross-references already exist. Contradictions already flagged. Synthesis already reflects everything read. Gets richer with every source added.

You never write the wiki yourself. You curate sources, direct analysis, ask questions. The LLM does summarizing, cross-referencing, filing, bookkeeping.

## Three Layers

| Layer | Owner | Description |
|-------|-------|-------------|
| Raw sources | Human | Immutable source docs -- articles, papers, images. Never modified by LLM. |
| The wiki | LLM | LLM-generated markdown: summaries, entity pages, concept pages, synthesis. |
| The schema | Human + LLM | Config doc (CLAUDE.md/AGENTS.md) defining wiki conventions and workflows. |

## Vault Structure

```
wiki/
  raw/          Raw source documents (human-curated, LLM reads only)
  wiki/         LLM-generated pages
    index.md    Content catalog -- LLM reads first on every query
    log.md      Append-only chronological record of operations
    entities/   Pages for named entities (people, places, orgs)
    concepts/   Pages for ideas and themes
    sources/    Summary pages per ingested source
```

## Operations

### Ingest

Drop a new source into raw/ and say "ingest [filename]".

Flow:
1. LLM reads source
2. Discusses key takeaways with you
3. Writes summary page in wiki/sources/
4. Updates index.md
5. Updates relevant entity and concept pages (may touch 10-15 pages)
6. Appends entry to log.md

### Query

Ask questions against the wiki. LLM searches index.md, reads relevant pages, synthesizes answer with citations.

**File good answers back as new pages.** A comparison you asked for, an analysis, a discovered connection -- these compound in the wiki.

### Lint

Periodic health check. Ask: "lint the wiki".

LLM looks for:
- Contradictions between pages
- Stale claims superseded by newer sources
- Orphan pages with no inbound links
- Missing cross-references
- Data gaps fillable by web search

## Special Files

**index.md** -- Content-oriented catalog. Every page listed with link + one-line summary + optional metadata. LLM updates on every ingest. LLM reads first on every query to find relevant pages.

**log.md** -- Chronological record. Append-only. Format each entry: `## [YYYY-MM-DD] operation | title`. Parseable with grep.

## Schema Configuration

The schema (CLAUDE.md or AGENTS.md for the wiki repo) tells the LLM:
- Directory structure and naming conventions
- Page formats (frontmatter fields, section structure)
- Ingest workflow for this domain
- What cross-references to maintain
- Lint checklist for this wiki's needs

Co-evolve the schema with the LLM as you learn what works.

## Setup

### New wiki

1. Create directory structure above
2. Create CLAUDE.md (or AGENTS.md) as the schema
3. Tell the LLM: "Read CLAUDE.md. This is our wiki schema."
4. Drop first source into raw/ and say "ingest [filename]"

### Existing Obsidian vault

If using Obsidian as the IDE:
- Point vault at wiki/ directory
- Use [[wikilinks]] for cross-references (already the LLM wiki standard)
- Graph view shows wiki shape and orphan pages
- Obsidian Web Clipper converts web articles to markdown for raw/

## Tips

- **Obsidian Web Clipper** -- browser extension, converts web articles to markdown
- **Download images locally** -- Obsidian Settings -> Files and links -> Attachment folder path. Then download hotkey so LLM can reference images
- **Graph view** -- best way to see wiki shape, hubs, orphans
- **Marp** -- markdown slide deck format. Generate presentations from wiki content
- **Dataview plugin** -- runs queries over page frontmatter for dynamic tables
- **Git** -- wiki is just markdown files. Version history and branching free

## Why This Works

Humans abandon wikis because maintenance burden grows faster than value. LLMs don't get bored, don't forget to update cross-references, can touch 15 files in one pass. The wiki stays maintained because maintenance cost is near zero.

Human's job: curate sources, direct analysis, ask good questions, think about meaning.
LLM's job: everything else.

## Integration with Other Skills

- **`/obsidian-vault`** -- Sets up Obsidian vault structure. Use before starting an LLM wiki with Obsidian as the IDE.
- **`/memory-to-vault`** -- Converts Claude's persisted memory into a vault outline. Useful for seeding a new wiki with existing knowledge.
- **`/grill-with-docs`** -- Creates CONTEXT.md and ADRs for a project. Feeds naturally into an LLM wiki as source material.
