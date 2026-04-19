# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Initial distribution builds

## [Unreleased] — 2026-04-19

### Renamed
- `plugins/smorch-dev/` → `plugins/smorch-builders/` (v1.0.0 → v2.0.0). Previous plugin was misnamed — it's MCP/n8n builder skills, not a dev workflow.

### Archived
- `plugins/smorch-dev-scoring/` → `archive/smorch-dev-scoring-v1.0.0-2026-03-29/`. Scoring functionality absorbed into new `smorch-dev` plugin (github.com/SMOrchestra-ai/smorch-dev) as `smo-scorer` skill with internal calibration.

### Note
The NEW `smorch-dev` plugin is NOT in this dist repo. It lives at `github.com/SMOrchestra-ai/smorch-dev` and ships directly via its own install scripts. This dist repo keeps the legacy/builder plugins only.
