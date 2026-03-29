# AGENTS.md

This file describes the AI agent behaviors and constraints for this repository.

## Agent Scope
- Agents may read, modify, and create files within this repository
- Agents must follow conventional commit format: `type(scope): message`
- Agents must not modify CI/CD configuration without human approval
- Agents must not push to `main` or `dev` directly — use PRs

## Commit Types
`feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `style`, `perf`

## Auto-fix Permissions
- Create missing CHANGELOG.md, AGENTS.md, PR/issue templates
- Update repo descriptions and topics
- Create GitHub Releases for orphaned tags

## Restricted Actions
- Branch protection rules (human only)
- Repo renames or archival
- Infrastructure / CI changes
