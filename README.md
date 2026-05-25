# Presidio Analyzer — Custom Build

Extends Microsoft's Presidio Analyzer with 7 custom secret-detection recognizers.

## What's different from the base image

| Feature | Base image | This image |
|---|---|---|
| Custom recognizers | None | 7 custom patterns merged at build time |
| Connection strings | Basic pattern only | URL, SQL Server OLEDB, SSH, HTTP basic auth |
| Deduplication | None | Skips recognizers already in base image |
| Idempotent restarts | No | Yes — safe to restart |

## Quick start

```bash
# Build locally
docker build -t presidio-analyzer:local .

# Run
docker run --rm -p 3000:3000 presidio-analyzer:local

# Test (requires hurl — brew install hurl)
hurl --test tests/
```

## Testing

Install hurl: `brew install hurl` (macOS) or see https://hurl.dev

Start the container:
```bash
docker run --rm -p 3000:3000 presidio-analyzer:local
```

Run all tests:
```bash
hurl --test --variable base_url=localhost:3000 tests/
```

Run a specific test file:
```bash
hurl --test --variable base_url=localhost:3000 tests/aws-credentials.hurl
```

### Test files

| File | Coverage |
|---|---|
| `health.hurl` | `/health` endpoint |
| `aws-credentials.hurl` | AWS access key, secret key |
| `github-tokens.hurl` | GitHub PAT, fine-grained PAT, OAuth tokens |
| `openai-keys.hurl` | OpenAI `sk-` keys, Anthropic `sk-ant-` keys |
| `private-keys.hurl` | RSA, EC, OPENSSH private key blocks |
| `jwt-tokens.hurl` | JWT with 3 base64 segments |
| `connection-strings.hurl` | URL, SQL Server OLEDB, SSH, HTTP basic auth |
| `pii.hurl` | Email, phone, person names |
| `financial.hurl` | Credit cards, IBAN, IP addresses |
| `negative-cases.hurl` | Near-miss strings that should NOT detect |

### Score thresholds

Tests use conservative thresholds (`>= 0.6` minimum) to avoid flakiness. Calibrate by running tests against a live container and adjusting if legitimate detections are missed.

## API reference

Standard Presidio analyzer API at `http://localhost:3000`:

```bash
curl -X POST http://localhost:3000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "AKIAIOSFODNN7EXAMPLE", "language": "en"}'
```

### Health check

```bash
curl http://localhost:3000/health
```

## Custom entity types

| Entity | Pattern | Score |
|---|---|---|
| `AWS_ACCESS_KEY` | `AKIA` + 16 alphanumeric chars | 0.9 |
| `AWS_SECRET_KEY` | 40-char AWS secret key (boundary-checked) | 0.7 |
| `GITHUB_TOKEN` | `ghp_`/`gho_`/`ghu_`/`ghs_`/`ghr_` + 36–255 chars | 0.85 |
| `OPENAI_API_KEY` | `sk-` + 32+ alphanumeric chars | 0.9 |
| `PRIVATE_KEY` | PEM private key blocks (RSA, EC, OPENSSH, DSA) | 0.95 |
| `JWT_TOKEN` | `eyJ...` JWT with 3 dot-separated base64 segments | 0.7 |
| `CONNECTION_STRING` | URL, SQL Server OLEDB, SSH, HTTP basic auth | 0.75–0.85 |

## Connection string patterns

| Pattern | Example |
|---|---|
| URL-format | `postgres://user:pass@host` |
| SQL Server OLEDB | `Server=...;User Id=...;Password=...;` |
| SSH | `ssh user@host` or `ssh://user@host` |
| HTTP basic auth | `https://user:pass@host/path` |

## Adding new recognizers

Edit `recognizers.yaml` and rebuild. No Python or Dockerfile changes needed for pattern-only additions:

```yaml
custom_recognizers:
  - name: MyCustomRecognizer
    type: custom
    supported_entity: MY_ENTITY_TYPE
    supported_language: en
    patterns:
      - name: my_pattern
        regex: 'your-regex-here'
        score: 0.8
```

## CI/CD

### Tag-based builds

Tags matching `presidio-analyzer-v*` trigger a GitHub Action build and push to `ghcr.io/cusk/presidio-analyzer`:

```bash
git tag presidio-analyzer-v1.0.0
git push --tags
```

### Automated upstream rebuilds

A scheduled workflow checks daily for changes to the upstream base image (`mcr.microsoft.com/presidio-analyzer`). If a new version is detected, it rebuilds the image, runs the hurl test suite, and pushes to `ghcr.io/cusk/presidio-analyzer:latest`.

## Architecture

```
mcr.microsoft.com/presidio-analyzer:latest
  /app/presidio_analyzer/conf/
  default_recognizers.yaml
                  │ (read at build time)
                  ▼
  Dockerfile RUN step
  Merges recognizers.yaml (idempotent)
                  │ writes
                  ▼
  /app/custom_recognizers.yaml
  (baked into image — no runtime script)
```

- Base `default_recognizers.yaml` is never modified
- `RECOGNIZER_REGISTRY_CONF_FILE` env var points analyzer at the merged file
- Gunicorn control socket disabled via `GUNICORN_CMD_ARGS=--no-control-socket`

## Notices

This project builds on [Microsoft Presidio](https://github.com/microsoft/presidio), licensed under MIT.
See [NOTICES.md](NOTICES.md) for full attribution.