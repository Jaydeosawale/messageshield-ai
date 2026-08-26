import os, pandas as pd, joblib, mlflow
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from data_validation import validate_data
data_path=os.getenv("DATA_PATH","data/processed/messages.csv")
df=pd.read_csv(data_path); validate_data(df)
xtr,xte,ytr,yte=train_test_split(df.text,df.label,test_size=.2,random_state=42,stratify=df.label)
model=Pipeline([("tfidf",TfidfVectorizer(ngram_range=(1,2),max_features=20000)),
                ("clf",LogisticRegression(max_iter=1000))])
with mlflow.start_run():
    model.fit(xtr,ytr); score=model.score(xte,yte)
    mlflow.log_metric("accuracy",score)
    mlflow.sklearn.log_model(model,"model")
joblib.dump(model,"models/messageshield.joblib")
print({"accuracy":score})
