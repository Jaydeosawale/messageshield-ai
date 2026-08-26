from app.ml.classifier import predict_message


messages = [
    "Your OTP is 789456. Do not share this code.",
    "Your bank account has been debited Rs 500.",
    "Huge discount! Buy now and save 50 percent.",
    "Hi, let's meet tomorrow for lunch.",
]


for message in messages:
    result = predict_message(message)

    print("\nMESSAGE:")
    print(message)

    print("PREDICTION:")
    print(result)