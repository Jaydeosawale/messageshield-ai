import sys
from pathlib import Path

# Add backend directory to Python path
BACKEND_DIR = Path(__file__).resolve().parent.parent
sys.path.append(str(BACKEND_DIR))

from app.ml.safety_classifier import predict_safety


messages = [
    "Your bank account will be blocked. Update KYC immediately.",
    "Share the OTP sent to your phone to receive your refund.",
    "Enter your UPI PIN to receive cashback.",
    "Your package has been delivered successfully.",
    "Your OTP is 482910. Do not share it with anyone.",
    "Let's meet tomorrow at 6 PM.",
]


print("\n" + "=" * 70)
print("MESSAGE SHIELD V5 SAFETY CLASSIFIER TEST")
print("=" * 70)


for i, message in enumerate(messages, 1):

    result = predict_safety(message)

    print("\n" + "-" * 70)
    print(f"TEST #{i}")

    print("\nMESSAGE:")
    print(message)

    print("\nSAFETY LABEL:")
    print(result["safety_label"])

    print("\nCONFIDENCE:")
    print(
        f"{result['confidence']:.4f} "
        f"({result['confidence'] * 100:.2f}%)"
    )

    print("\nPROBABILITIES:")

    for label, probability in result["probabilities"].items():
        print(
            f"{label}: "
            f"{probability:.4f} "
            f"({probability * 100:.2f}%)"
        )


print("\n" + "=" * 70)
print("TEST COMPLETE")
print("=" * 70)
