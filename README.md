# smorch-dist

SMOrchestra compiled plugin distribution — pre-built `.plugin` bundles for team installs.

## Overview

This repository contains compiled `.plugin` files built from [smorch-brain](https://github.com/SMOrchestra-ai/smorch-brain) source. Team members install these bundles directly without needing the full skills registry.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| `eo-microsaas-os.plugin` | EO MicroSaaS OS skills for Entrepreneurs Oasis |
| `eo-scoring-suite.plugin` | EO scoring engines (ICP, GTM, market, strategy) |
| `smorch-dev.plugin` | Engineering and dev tools for SMOrchestra dev team |
| `smorch-gtm-engine.plugin` | GTM automation and outbound campaign tools |
| `smorch-gtm-scoring.plugin` | GTM scoring and evaluation skills |
| `smorch-gtm-tools.plugin` | Operator tools (GHL, Clay, HeyReach, Instantly) |
| `mamoun-personal-branding.plugin` | Personal branding and LinkedIn content tools |
| `smorch-context-brain.plugin` | SMOrchestra business context and project brain |
| `smorch-design.plugin` | Design, UI, and brand asset tools |
| `smorch-dev-scoring.plugin` | Code quality and architecture scoring |

## Installation

Use the one-command installer from the setup guide:

```bash
# macOS
curl -sSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dist/main/scripts/smorch-setup.sh | bash
```

See [setup guides](./guides/) for detailed role-based installation instructions.

## Build

Plugins are built from smorch-brain source. See [smorch-brain](https://github.com/SMOrchestra-ai/smorch-brain) for build instructions.
