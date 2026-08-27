import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v7.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v8.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V8 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW GENERAL EXAMPLES
# ==========================================================

new_general_messages = [

    # ------------------------------------------------------
    # PERSONAL CONVERSATION
    # ------------------------------------------------------

    "Hi, how are you doing today?",
    "Good morning, have a nice day.",
    "Good night, sleep well.",
    "Can we talk later?",
    "Please call me when you are free.",
    "I will call you after work.",
    "Let us meet this weekend.",
    "Are you available this evening?",
    "I am on my way home.",
    "I will reach there soon.",
    "Please let me know when you arrive.",
    "I reached home safely.",
    "See you tomorrow.",
    "Talk to you soon.",
    "Take care and stay safe.",
    "Thank you for your help.",
    "Sorry, I missed your call.",
    "I will reply later.",
    "Can you send me the details?",
    "Please remind me tomorrow.",
    "What time should we meet?",
    "I am running a little late.",
    "The meeting has been postponed.",
    "Let's have lunch tomorrow.",
    "Can we reschedule our appointment?",
    "I will be there at 6 PM.",
    "Please wait for me.",
    "I have sent you the document.",
    "Did you receive my message?",
    "Let me know your decision.",

    # ------------------------------------------------------
    # FAMILY AND FRIENDS
    # ------------------------------------------------------

    "Happy birthday! Hope you have a wonderful day.",
    "Congratulations on your success.",
    "Wishing you a happy anniversary.",
    "Have a safe journey.",
    "Welcome back home.",
    "How is everyone at home?",
    "Please give my regards to your family.",
    "I hope you are feeling better today.",
    "We had a great time yesterday.",
    "Let's plan a trip together.",
    "Are you coming to the party?",
    "The family dinner is at 8 PM.",
    "Please bring your friend along.",
    "I will see you at the celebration.",
    "Thank you for inviting me.",
    "It was nice meeting you.",
    "Please wish her happy birthday from me.",
    "We should catch up sometime.",
    "I miss talking with you.",
    "Let's meet for coffee tomorrow.",

    # ------------------------------------------------------
    # WORK AND DAILY LIFE
    # ------------------------------------------------------

    "The meeting starts at 10 AM tomorrow.",
    "Please join the meeting on time.",
    "I have completed the assigned task.",
    "Can you review the document?",
    "Please send the report by evening.",
    "The project deadline is next Friday.",
    "I will share the update shortly.",
    "Let's discuss this in tomorrow's meeting.",
    "The presentation has been prepared.",
    "Please check your email for the details.",
    "The office will be closed tomorrow.",
    "I am working from home today.",
    "Can we schedule a quick call?",
    "Please confirm your availability.",
    "The interview has been moved to Monday.",
    "Your appointment is confirmed for 3 PM.",
    "The doctor is available tomorrow morning.",
    "Your reservation has been confirmed.",
    "The class starts at 9 AM.",
    "Don't forget to attend the session.",

    # ------------------------------------------------------
    # NEUTRAL NOTIFICATIONS
    # ------------------------------------------------------

    "Your electricity service will undergo maintenance tomorrow.",
    "Water supply will be temporarily unavailable this morning.",
    "The school will remain closed due to heavy rain.",
    "Your train is scheduled to arrive at 7 PM.",
    "The bus will depart in ten minutes.",
    "Your table reservation is confirmed.",
    "The event starts at 6 PM today.",
    "Your library books are due next week.",
    "The maintenance work has been completed.",
    "Your internet service is now restored.",
    "The building lift is under maintenance.",
    "The weather is expected to be cloudy today.",
    "The road is closed due to construction.",

]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 83

print()
print(
    f"New GENERAL examples: "
    f"{len(new_general_messages)}"
)

if len(new_general_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new GENERAL examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

duplicates = []

for message in new_general_messages:

    normalized = message.strip().lower()

    if normalized in existing_messages:
        duplicates.append(message)


if duplicates:

    print()
    print("Duplicate messages found:")

    for message in duplicates:
        print(f"- {message}")

    raise ValueError(
        "New examples contain duplicates "
        "already present in the dataset."
    )


# ==========================================================
# ADD NEW DATA
# ==========================================================

for message in new_general_messages:

    data.append(
        {
            "message": message,
            "category": "GENERAL",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

general_count = sum(
    1
    for item in data
    if item["category"] == "GENERAL"
)

print()
print(
    f"Final GENERAL count: "
    f"{general_count}"
)

if general_count != 100:
    raise ValueError(
        "Expected final GENERAL count "
        "to be exactly 100."
    )


# ==========================================================
# SAVE DATASET
# ==========================================================

with open(
    OUTPUT_PATH,
    "w",
    encoding="utf-8",
) as file:

    json.dump(
        data,
        file,
        indent=4,
        ensure_ascii=False,
    )


print()
print(
    f"Total dataset examples: "
    f"{len(data)}"
)

print()
print("Dataset saved to:")
print(OUTPUT_PATH)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)