# MessageShield AI

> Privacy-first AI message safety assistant with ML classification, risk analysis, MLOps, CI/CD, inference monitoring, and category drift detection.

## Overview

MessageShield AI analyzes potentially suspicious messages and provides:

- Message category classification
- Safety classification
- Risk scoring and signals
- Privacy-aware message redaction
- OCR-based message extraction
- Firebase authentication
- Multilingual UI
- Model version tracking
- MLflow experiment tracking
- MLflow Model Registry
- Inference monitoring
- Category drift detection using PSI

The project is designed as a production-oriented AI/ML engineering system, with a focus on model lifecycle management, observability, testing, and controlled deployment.

## Architecture

```text
                    MessageShield AI
                           │
             ┌─────────────┴─────────────┐
             │                           │
        Flutter App                 FastAPI API
             │                           │
             │                    ┌──────┴──────┐
             │                    │             │
             │                  ML Models    PostgreSQL
             │                    │
             │              ┌─────┴─────┐
             │              │           │
             │          Category      Safety
             │              │
             │              ▼
             │        Risk Assessment
             │              │
             └──────────────┤
                            ▼
                    Analysis Result
```

## AI / ML

### Message Classification

The category model uses:

- TF-IDF vectorization
- Unigrams and bigrams
- Logistic Regression
- Stratified train/test split
- Probability-based confidence
- 10 message categories

Current category model V4 evaluation:

| Metric | Score |
|---|---:|
| Accuracy | 0.895 |
| Weighted Precision | ~0.900 |
| Weighted Recall | 0.895 |
| Weighted F1 | ~0.892 |
| Macro F1 | ~0.892 |

### Risk Analysis

The prediction pipeline combines model output with risk signals to produce a final risk level and score.

The original message is preserved separately from the privacy-redacted analysis representation.

## MLOps

MessageShield includes an incremental MLOps lifecycle:

Dataset → Validation → Training → Evaluation → MLflow Tracking → Model Registry → Staging → Production → Inference Monitoring → Drift Detection → Reviewed Feedback → Retraining

### MLflow Tracking

Training runs record:

- Parameters
- Metrics
- Dataset information
- Model artifacts
- Input example
- Model signature

Experiment: `MessageShield-Category`

### Model Registry

Registered category model: `MessageShieldCategoryModel`

The application can load the registered model using the configured MLflow model URI.

The backend also has a local Joblib fallback if Registry loading fails.

### Inference Monitoring

The system records:

- Model name
- Model version
- Prediction category
- Confidence
- Probability distribution
- Safety model metadata
- Risk result
- Timestamp

The admin API exposes model prediction statistics and confidence monitoring.

### Category Drift Detection

Recent category predictions are compared against the training distribution using Population Stability Index (PSI).

| PSI | Status |
|---:|---|
| `< 0.10` | NORMAL |
| `0.10 – < 0.25` | WARNING |
| `>= 0.25` | DRIFT |

The monitor protects against insufficient data and isolates predictions by exact model name and version.

Detailed documentation: [`docs/mlops.md`](docs/mlops.md)

## CI/CD

GitHub Actions validates both backend and frontend changes.

### Backend

- Python setup
- PostgreSQL test service
- Dependency installation
- Automated pytest suite

### Frontend

- Flutter setup
- Dependency installation
- Localization generation
- `flutter analyze`
- `flutter test`

Development and production are separated through Git branches and hosted staging/production environments.

## Deployment

### Staging

develop → Vercel Preview → Render Staging → Staging Database

### Production

main → Vercel Production → Render Production → Production Database

Production infrastructure uses:

- Vercel
- Render
- Neon PostgreSQL
- Firebase
- MLflow / DagsHub

## Authentication

Authentication uses Firebase with backend-issued MessageShield JWTs.

Supported authentication flows include:

- Email/password
- Google Sign-In
- Email verification
- Role-based authorization

Google users can subsequently configure a password for the same Firebase account.

## Privacy and Security

MessageShield includes privacy-aware handling for sensitive message content, including patterns such as:

- OTPs
- Password-like values
- Card-like values

The project is production-oriented but is **not a claim of completed security certification**.

Security documentation: [`docs/security.md`](docs/security.md)

## Testing

The backend currently has **49 passed** tests.

Coverage includes:

- API authentication/authorization
- Analysis services
- Risk assessment
- Category distribution monitoring
- PSI drift detection
- Insufficient-data handling
- Model/version filtering
- Admin monitoring API

Frontend validation includes:

- Flutter analyzer
- Flutter tests
- Localization generation

## Project Structure

```text
messageshield-ai/
├── backend/
│   ├── app/
│   ├── data/
│   ├── mlops/
│   ├── models/
│   └── tests/
├── frontend/
├── docs/
│   ├── architecture.md
│   ├── mlops.md
│   ├── security.md
│   └── responsive_ui.md
├── monitoring/
├── docker-compose.yml
└── README.md
```

## Documentation

- [Architecture](docs/architecture.md)
- [MLOps](docs/mlops.md)
- [Security](docs/security.md)
- [Responsive UI](docs/responsive_ui.md)

## Technology Stack

### Frontend

- Flutter
- Dart
- Firebase Authentication
- Google Sign-In
- Google ML Kit OCR

### Backend

- Python
- FastAPI
- SQLAlchemy
- PostgreSQL
- JWT
- Pytest

### ML / MLOps

- scikit-learn
- TF-IDF
- Logistic Regression
- MLflow
- DagsHub
- Joblib
- PSI-based drift monitoring

### DevOps

- GitHub Actions
- Docker
- Render
- Vercel
- Neon PostgreSQL

## Current Status

MessageShield is actively evolving toward a production-grade AI/ML system.

### Completed

- Authentication and authorization
- Flutter application
- OCR message extraction
- ML classification
- Model evaluation
- MLflow experiment tracking
- MLflow Model Registry
- Staging and production environments
- CI/CD
- Inference monitoring
- Category drift detection
- Automated backend testing

### Planned

- Scheduled drift evaluation
- Automated monitoring jobs
- Reviewed-label performance monitoring
- Feedback collection
- Automated retraining
- Model promotion and rollback
- Monitoring alerts
- Dedicated admin monitoring dashboard

## Roadmap

```text
Current
  │
  ├── ML classification
  ├── MLflow tracking
  ├── Model Registry
  ├── CI/CD
  ├── Inference monitoring
  └── PSI drift detection
       │
       ▼
Next
  │
  ├── Scheduled monitoring
  ├── Feedback collection
  ├── Performance monitoring
  └── Retraining pipeline
       │
       ▼
Future
  │
  ├── Evaluation gates
  ├── Model promotion
  ├── Rollback
  └── Monitoring alerts
```

## Disclaimer

MessageShield is a production-oriented engineering project and does not constitute a guarantee that any analyzed message is safe or malicious.

Security, privacy, model performance, and operational controls should be independently reviewed before use in high-risk environments.
