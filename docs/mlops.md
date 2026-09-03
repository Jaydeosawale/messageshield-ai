# MessageShield AI — MLOps

MessageShield AI uses an MLOps workflow to move machine-learning models from
training and evaluation into controlled staging and production deployment,
while tracking model versions and monitoring inference behavior.

## MLOps lifecycle

```text
Dataset
   │
   ▼
Data Validation
   │
   ▼
Model Training
   │
   ├── Evaluation metrics
   │
   ▼
MLflow Tracking
   │
   ▼
MLflow Model Registry
   │
   ▼
Staging
   │
   ▼
Production
   │
   ▼
Inference Monitoring
   │
   ▼
Category Drift Detection
   │
   ▼
Reviewed Feedback
   │
   └──────────────► Retraining
