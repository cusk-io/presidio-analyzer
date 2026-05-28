# Presidio Analyzer — Custom Build

Extends Microsoft's Presidio Analyzer with 7 custom secret-detection recognizers.

## What's different from the base image

| Feature             | Base image         | This image                                  |
| ------------------- | ------------------ | ------------------------------------------- |
| Custom recognizers  | None               | 7 custom patterns merged at build time      |
| Connection strings  | Basic pattern only | URL, SQL Server OLEDB, SSH, HTTP basic auth |
| Deduplication       | None               | Skips recognizers already in base image     |
| Idempotent restarts | No                 | Yes — safe to restart                       |

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

Install hurl: `brew install hurl` (macOS) or see <https://hurl.dev>

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

| File                      | Coverage                                    |
| ------------------------- | ------------------------------------------- |
| `health.hurl`             | `/health` endpoint                          |
| `aws-credentials.hurl`    | AWS access key, secret key                  |
| `github-tokens.hurl`      | GitHub PAT, fine-grained PAT, OAuth tokens  |
| `openai-keys.hurl`        | OpenAI `sk-` keys, Anthropic `sk-ant-` keys |
| `private-keys.hurl`       | RSA, EC, OPENSSH private key blocks         |
| `jwt-tokens.hurl`         | JWT with 3 base64 segments                  |
| `connection-strings.hurl` | URL, SQL Server OLEDB, SSH, HTTP basic auth |
| `pii.hurl`                | Email, phone, person names                  |
| `financial.hurl`          | Credit cards, IBAN, IP addresses            |
| `negative-cases.hurl`     | Near-miss strings that should NOT detect    |

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

| Entity              | Pattern                                           | Score     |
| ------------------- | ------------------------------------------------- | --------- |
| `AWS_ACCESS_KEY`    | `AKIA` + 16 alphanumeric chars                    | 0.9       |
| `AWS_SECRET_KEY`    | 40-char AWS secret key (boundary-checked)         | 0.7       |
| `GITHUB_TOKEN`      | `ghp_`/`gho_`/`ghu_`/`ghs_`/`ghr_` + 36–255 chars | 0.85      |
| `OPENAI_API_KEY`    | `sk-` + 32+ alphanumeric chars                    | 0.9       |
| `PRIVATE_KEY`       | PEM private key blocks (RSA, EC, OPENSSH, DSA)    | 0.95      |
| `JWT_TOKEN`         | `eyJ...` JWT with 3 dot-separated base64 segments | 0.7       |
| `CONNECTION_STRING` | URL, SQL Server OLEDB, SSH, HTTP basic auth       | 0.75–0.85 |

## Connection string patterns

| Pattern          | Example                                |
| ---------------- | -------------------------------------- |
| URL-format       | `postgres://user:pass@host`            |
| SQL Server OLEDB | `Server=...;User Id=...;Password=...;` |
| SSH              | `ssh user@host` or `ssh://user@host`   |
| HTTP basic auth  | `https://user:pass@host/path`          |

## Examples

```bash
# AWS credentials
curl -s -X POST http://localhost:3000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "AKIAIOSFODNN7EXAMPLE", "language": "en"}'
# → AWS_ACCESS_KEY (score 0.9)

# GitHub token
curl -s -X POST http://localhost:3000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "GH_TOKEN=ghp_abcdefghijklmnopqrstuvwxyz1234567890", "language": "en"}'
# → GITHUB_TOKEN

# Connection string (URL-format)
curl -s -X POST http://localhost:3000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "postgres://adminuser:MySecretPass@db.example.com:5432/mydb", "language": "en"}'
# → CONNECTION_STRING (score 0.85)

# JWT token
curl -s -X POST http://localhost:3000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc", "language": "en"}'
# → JWT_TOKEN
```

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
        regex: "your-regex-here"
        score: 0.8
```

## CI/CD

### Tag-based builds

Tags matching `dockertag-*` trigger a build and push to `ghcr.io/cusk-io/presidio-analyzer`. The prefix is stripped from the tag:

```bash
git tag dockertag-v1.0.0
git push --tags
# pushes ghcr.io/cusk-io/presidio-analyzer:v1.0.0
```

### Branch-based builds

Every push to any branch triggers a build and push as `ghcr.io/cusk-io/presidio-analyzer:<branch-name>`. The `main` branch additionally pushes to `latest`.

## Architecture

Base image `mcr.microsoft.com/presidio-analyzer:latest` is extended at build time by merging `recognizers.yaml` into `/app/custom_recognizers.yaml`. The `RECOGNIZER_REGISTRY_CONF_FILE` env var points the analyzer at the merged file.

- Base `default_recognizers.yaml` is never modified
- Gunicorn control socket disabled via `GUNICORN_CMD_ARGS=--no-control-socket`

## Notices

This project builds on [Microsoft Presidio](https://github.com/microsoft/presidio), licensed under MIT.
See [NOTICES.md](NOTICES.md) for full attribution.

