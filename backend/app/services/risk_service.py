from typing import Any


def contains_any(text: str, phrases: list[str]) -> bool:
    return any(phrase in text for phrase in phrases)


def assess_risk(
    message: str,
    category: str,
    confidence: float,
) -> dict[str, Any]:

    text = message.lower().strip()

    score = 0
    signals: list[str] = []

    # =========================================
    # 1. LEGITIMATE / PROTECTIVE CONTEXT
    # =========================================

    protective_phrases = [
        "do not share",
        "don't share",
        "never share",
        "never disclose",
        "do not disclose",
        "don't disclose",
        "keep your otp confidential",
        "keep your pin confidential",
        "keep your password confidential",
        "we will never ask for",
        "no bank will ask for",
        "for your security",
        "beware of fraud",
        "beware of scams",
        "protect yourself from fraud",
        "do not click suspicious links",
        "ignore suspicious messages",
    ]

    has_protective_context = contains_any(
        text,
        protective_phrases,
    )

    if has_protective_context:
        signals.append("protective_security_context")

    # =========================================
    # 2. URL DETECTION
    # =========================================

    url_indicators = [
        "http://",
        "https://",
        "www.",
        "bit.ly",
        "tinyurl",
        "goo.gl",
        "t.co/",
    ]

    has_url = contains_any(
        text,
        url_indicators,
    )

    if has_url:
        score += 2
        signals.append("contains_url")

    # =========================================
    # 3. URGENCY / PRESSURE
    # =========================================

    urgency_words = [
        "urgent",
        "urgently",
        "immediately",
        "act now",
        "action required",
        "limited time",
        "hurry",
        "right now",
        "within 24 hours",
        "within 1 hour",
        "last chance",
        "final warning",
        "without delay",
        "as soon as possible",
    ]

    has_urgency = contains_any(
        text,
        urgency_words,
    )

    if has_urgency and not has_protective_context:
        score += 2
        signals.append("urgency_language")

    # =========================================
    # 4. ACCOUNT / CONSEQUENCE THREATS
    # =========================================

    threat_words = [
        "account blocked",
        "account suspended",
        "account disabled",
        "account closed",
        "account will be blocked",
        "account will be suspended",
        "service will be stopped",
        "service suspended",
        "card blocked",
        "card suspended",
        "kyc expired",
        "kyc will expire",
        "legal action",
        "police action",
        "arrest warrant",
        "you will be arrested",
        "penalty",
        "fine",
    ]

    has_threat = contains_any(
        text,
        threat_words,
    )

    if has_threat and not has_protective_context:
        score += 2
        signals.append("account_or_consequence_threat")

    # =========================================
    # 5. SENSITIVE INFORMATION
    # =========================================

    sensitive_items = {
        "otp": [
            "otp",
            "one time password",
            "one-time password",
            "verification code",
            "security code",
        ],
        "cvv": [
            "cvv",
            "cvc",
            "card security code",
        ],
        "pin": [
            "upi pin",
            "atm pin",
            "debit card pin",
            "credit card pin",
            "mpin",
            "m-pin",
        ],
        "password": [
            "password",
            "passcode",
            "login password",
        ],
        "bank_details": [
            "bank details",
            "account number",
            "bank account number",
            "ifsc code",
        ],
        "card_details": [
            "card number",
            "credit card number",
            "debit card number",
            "card details",
            "expiry date",
        ],
    }

    detected_sensitive_items = []

    for item_name, phrases in sensitive_items.items():
        if contains_any(text, phrases):
            detected_sensitive_items.append(item_name)

    # =========================================
    # 6. REQUEST / DISCLOSURE ACTIONS
    # =========================================

    request_words = [
        "share",
        "send",
        "provide",
        "give",
        "reveal",
        "disclose",
        "forward",
        "tell us",
        "tell me",
        "enter your",
        "submit your",
        "confirm your",
        "verify your",
        "reply with",
        "type your",
    ]

    has_request_action = contains_any(
        text,
        request_words,
    )

    # Dangerous combination:
    # requesting sensitive information
    if (
        detected_sensitive_items
        and has_request_action
        and not has_protective_context
    ):
        score += 4
        signals.append(
            "requests_sensitive_information"
        )

        for item in detected_sensitive_items:
            signals.append(
                f"requests_{item}"
            )

    # =========================================
    # 7. GENUINE OTP DELIVERY CONTEXT
    # =========================================

    otp_delivery_phrases = [
        "your otp is",
        "otp is",
        "your verification code is",
        "verification code is",
        "use this otp",
        "use the otp",
        "do not share this otp",
        "don't share this otp",
        "never share this otp",
    ]

    is_otp_delivery = (
        "otp" in text
        and contains_any(
            text,
            otp_delivery_phrases,
        )
    )

    if is_otp_delivery:
        signals.append(
            "otp_delivery_context"
        )

    # =========================================
    # 8. MONEY / PAYMENT REQUESTS
    # =========================================

    payment_request_words = [
        "transfer money",
        "send money",
        "pay immediately",
        "make payment",
        "pay now",
        "pay the fee",
        "processing fee",
        "registration fee",
        "release fee",
        "transfer the amount",
        "upi payment",
        "scan qr code",
        "scan the qr",
        "pay using upi",
    ]

    has_payment_request = contains_any(
        text,
        payment_request_words,
    )

    if has_payment_request and not has_protective_context:
        score += 3
        signals.append(
            "requests_payment"
        )

    # =========================================
    # 9. FINANCIAL FRAUD PROMISES
    # =========================================

    fraud_promise_words = [
        "guaranteed return",
        "guaranteed profit",
        "double your money",
        "triple your money",
        "earn money quickly",
        "instant profit",
        "risk free investment",
        "risk-free investment",
        "100% return",
        "assured return",
        "lottery winner",
        "you have won",
        "claim your prize",
        "claim your reward",
        "cash prize",
    ]

    if (
        contains_any(text, fraud_promise_words)
        and not has_protective_context
    ):
        score += 3
        signals.append(
            "fraudulent_financial_promise"
        )

    # =========================================
    # 10. SUSPICIOUS LINK ACTION
    # =========================================

    link_action_words = [
        "click here",
        "click the link",
        "open the link",
        "visit the link",
        "tap the link",
        "login here",
    ]

    has_link_action = contains_any(
        text,
        link_action_words,
    )

    if (
        has_url
        and has_link_action
        and not has_protective_context
    ):
        score += 2
        signals.append(
            "requests_link_interaction"
        )

    # =========================================
    # 11. IMPERSONATION LANGUAGE
    # =========================================

    impersonation_words = [
        "rbi",
        "reserve bank",
        "bank security team",
        "customer care",
        "income tax department",
        "police department",
        "cyber crime",
        "government officer",
        "courier company",
        "customs department",
    ]

    has_impersonation = contains_any(
        text,
        impersonation_words,
    )

    # Important:
    # Do NOT mark impersonation alone as scam.
    # Add risk only when combined with another
    # suspicious action.
    if (
        has_impersonation
        and (
            has_request_action
            or has_payment_request
            or has_threat
        )
        and not has_protective_context
    ):
        score += 2
        signals.append(
            "possible_impersonation"
        )

    # =========================================
    # 12. ML CATEGORY CONTRIBUTION
    # =========================================

    suspicious_categories = [
        "OTP_OR_SECURITY",
        "BANKING_OR_FINANCE",
        "SCAM",
        "FRAUD",
    ]

    if (
        category in suspicious_categories
        and not is_otp_delivery
        and not has_protective_context
    ):
        score += 1
        signals.append(
            "suspicious_ml_category"
        )

    # =========================================
    # 13. LOW MODEL CONFIDENCE
    # =========================================

    if confidence < 0.45:
        signals.append(
            "low_model_confidence"
        )

    # =========================================
    # 14. RISK REDUCTION FOR GENUINE CONTEXT
    # =========================================

    if has_protective_context:
        score = max(0, score - 4)

    if is_otp_delivery:
        score = max(0, score - 2)

    # =========================================
    # 15. FINAL RISK DECISION
    # =========================================

    if score >= 6:
     risk = "HIGH"

    elif score >= 3:
     risk = "MEDIUM"

    else:
     risk = "LOW"

    return {
     "risk": risk,
     "risk_score": score,
     "signals": signals,
}