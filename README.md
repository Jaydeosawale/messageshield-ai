# MessageShield AI
Production-style starter for a privacy-first message safety assistant.

## Quick start
1. Copy `.env.example` to `.env`.
2. `docker compose up --build`
3. Backend: http://localhost:8000/docs
4. MLflow: http://localhost:5000

## Included
- FastAPI + SQLAlchemy + Alembic-ready layout
- PostgreSQL + Redis
- JWT auth, user/admin roles
- Privacy redaction for OTP/password/card-like patterns
- Message category/risk baseline API
- Flutter starter UI
- ML training/evaluation scripts + MLflow
- Docker Compose
- Kubernetes manifests
- Prometheus/Grafana placeholders

## Important
This is a production-oriented foundation, not a claim of completed security certification.
Before public deployment: complete threat modeling, secrets manager, email verification,
rate limiting, external URL reputation provider, security review, backups, observability,
and legal/privacy review.
