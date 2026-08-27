import logging
import re


logger = logging.getLogger(__name__)


def assess_risk(
    message: str,
    category: str,
    confidence: float,
    safety_label: str,
    safety_confidence: float,
):
    """
    Combine:

    1. Safety ML model
    2. Category ML model
    3. Rule-based security signals
    4. Critical scam pattern detection
    5. Risk overrides

    Returns final risk level and score.
    """

    message_lower = message.lower()

    signals = []

    risk_score = 0

    detected_flags = set()


    # ==================================================
    # 1. SAFETY MODEL SIGNAL
    # ==================================================

    if safety_label == "SCAM":

        safety_score = int(
            safety_confidence * 50
        )

        risk_score += safety_score

        detected_flags.add(
            "SCAM"
        )

        signals.append({
            "type": "SAFETY_MODEL",
            "message": (
                "Safety model detected potential scam"
            ),
            "score": safety_score,
        })

    else:

        signals.append({
            "type": "SAFETY_MODEL",
            "message": (
                "Safety model classified message as safe"
            ),
            "score": 0,
        })


    # ==================================================
    # 2. CATEGORY RISK SIGNAL
    # ==================================================

    risky_categories = {
        "PHISHING": 20,
        "IMPERSONATION": 20,
        "INVESTMENT": 15,
        "OTP": 15,
        "PAYMENT": 15,
        "BANKING": 10,
        "JOB": 15,
    }

    category_score = 0

    if category in risky_categories:

        category_score = int(
            risky_categories[category]
            * confidence
        )

        risk_score += category_score

        detected_flags.add(
            category
        )

        signals.append({
            "type": "CATEGORY",
            "message": (
                f"Potentially risky category detected: "
                f"{category}"
            ),
            "score": category_score,
        })


    # ==================================================
    # 3. URL DETECTION
    # ==================================================

    url_pattern = (
        r"(https?://\S+|www\.\S+)"
    )

    if re.search(
        url_pattern,
        message_lower,
    ):

        risk_score += 15

        detected_flags.add(
            "URL"
        )

        signals.append({
            "type": "URL",
            "message": (
                "Message contains a link"
            ),
            "score": 15,
        })


    # ==================================================
    # 4. URGENCY DETECTION
    # ==================================================

    urgency_words = [
        "urgent",
        "immediately",
        "immediate",
        "now",
        "today",
        "quickly",
        "within",
        "avoid closure",
        "will be blocked",
        "suspended",
        "final warning",
    ]

    detected_urgency = [
        word
        for word in urgency_words
        if word in message_lower
    ]

    if detected_urgency:

        risk_score += 10

        detected_flags.add(
            "URGENCY"
        )

        signals.append({
            "type": "URGENCY",
            "message": (
                "Message uses urgency or pressure"
            ),
            "keywords": detected_urgency,
            "score": 10,
        })


    # ==================================================
    # 5. OTP REQUEST DETECTION
    # ==================================================

    otp_request_patterns = [
        "share the otp",
        "send the otp",
        "provide the otp",
        "tell me the otp",
        "forward the otp",
        "share otp",
        "send otp",
        "provide otp",
        "tell me otp",
        "share the verification code",
        "send the verification code",
        "provide the verification code",
        "share the code",
        "send the code",
    ]

    detected_otp_request = any(
        pattern in message_lower
        for pattern in otp_request_patterns
    )

    if detected_otp_request:

        risk_score += 25

        detected_flags.add(
            "OTP_REQUEST"
        )

        signals.append({
            "type": "OTP_REQUEST",
            "message": (
                "Message requests an OTP or "
                "verification code"
            ),
            "score": 25,
        })


    # ==================================================
    # 6. UPI PIN REQUEST DETECTION
    # ==================================================

    upi_pin_patterns = [
        "enter your upi pin",
        "share your upi pin",
        "provide your upi pin",
        "tell us your upi pin",
        "enter upi pin",
        "share upi pin",
        "provide upi pin",
    ]

    detected_upi_request = any(
        pattern in message_lower
        for pattern in upi_pin_patterns
    )

    if detected_upi_request:

        risk_score += 25

        detected_flags.add(
            "UPI_PIN_REQUEST"
        )

        signals.append({
            "type": "UPI_PIN_REQUEST",
            "message": (
                "Message requests a UPI PIN"
            ),
            "score": 25,
        })


    # ==================================================
    # 7. PAYMENT REQUEST DETECTION
    # ==================================================

    payment_patterns = [
        "pay now",
        "processing fee",
        "redelivery fee",
        "re-delivery fee",
        "delivery fee",
        "registration fee",
        "joining fee",
        "verification fee",
        "pay a fee",
        "pay rs",
        "pay ₹",
        "transfer money",
        "send money",
        "make payment",
        "pay the fee",
    ]

    detected_payment_request = any(
        pattern in message_lower
        for pattern in payment_patterns
    )

    if detected_payment_request:

        risk_score += 15

        detected_flags.add(
            "PAYMENT_REQUEST"
        )

        signals.append({
            "type": "PAYMENT_REQUEST",
            "message": (
                "Message requests money or payment"
            ),
            "score": 15,
        })


    # ==================================================
    # 8. REWARD / PRIZE DETECTION
    # ==================================================

    reward_patterns = [
        "you have won",
        "congratulations",
        "cashback",
        "reward",
        "prize",
        "guaranteed returns",
        "guaranteed profit",
        "risk free investment",
        "double your money",
        "exclusive opportunity",
    ]

    detected_reward = any(
        pattern in message_lower
        for pattern in reward_patterns
    )

    if detected_reward:

        risk_score += 10

        detected_flags.add(
            "REWARD"
        )

        signals.append({
            "type": "REWARD_OR_PRIZE",
            "message": (
                "Message contains reward, prize, "
                "or guaranteed return language"
            ),
            "score": 10,
        })


    # ==================================================
    # 9. CRITICAL RISK COMBINATIONS
    # ==================================================

    critical_patterns = []


    # --------------------------------------------------
    # SCAM + OTP REQUEST
    # --------------------------------------------------

    if (
        "SCAM" in detected_flags
        and "OTP_REQUEST" in detected_flags
    ):

        critical_patterns.append(
            "SCAM + OTP_REQUEST"
        )


    # --------------------------------------------------
    # SCAM + UPI PIN REQUEST
    # --------------------------------------------------

    if (
        "SCAM" in detected_flags
        and "UPI_PIN_REQUEST" in detected_flags
    ):

        critical_patterns.append(
            "SCAM + UPI_PIN_REQUEST"
        )


    # --------------------------------------------------
    # SCAM + PAYMENT + URGENCY
    # --------------------------------------------------

    if (
        "SCAM" in detected_flags
        and "PAYMENT_REQUEST"
        in detected_flags
        and "URGENCY"
        in detected_flags
    ):

        critical_patterns.append(
            "SCAM + PAYMENT_REQUEST + URGENCY"
        )


    # --------------------------------------------------
    # SCAM + URL
    # --------------------------------------------------

    if (
        "SCAM" in detected_flags
        and "URL" in detected_flags
    ):

        critical_patterns.append(
            "SCAM + URL"
        )


    # --------------------------------------------------
    # SCAM + INVESTMENT + GUARANTEED RETURN
    # --------------------------------------------------

    if (
        "SCAM" in detected_flags
        and category == "INVESTMENT"
        and "REWARD" in detected_flags
    ):

        critical_patterns.append(
            "SCAM + INVESTMENT + "
            "GUARANTEED_RETURN"
        )


    # ==================================================
    # 10. APPLY CRITICAL OVERRIDE
    # ==================================================

    critical_override = False

    if critical_patterns:

        critical_override = True

        risk_score = max(
            risk_score,
            70,
        )

        signals.append({
            "type": "CRITICAL_PATTERN",
            "message": (
                "Critical scam pattern detected"
            ),
            "patterns": critical_patterns,
            "score": 0,
        })


    # ==================================================
    # 11. CAP RISK SCORE
    # ==================================================

    risk_score = min(
        risk_score,
        100,
    )


    # ==================================================
    # 12. DETERMINE FINAL RISK LEVEL
    # ==================================================

    if critical_override:

        risk = "HIGH"

    elif risk_score >= 70:

        risk = "HIGH"

    elif risk_score >= 40:

        risk = "MEDIUM"

    else:

        risk = "LOW"


    # ==================================================
    # 13. LOG RESULT
    # ==================================================

    logger.info(
        "Risk assessment completed | "
        "risk=%s | score=%s | critical=%s",
        risk,
        risk_score,
        critical_override,
    )


    # ==================================================
    # 14. RETURN RESULT
    # ==================================================

    return {
        "risk": risk,
        "risk_score": risk_score,
        "signals": signals,
        "critical_override": critical_override,
        "critical_patterns": critical_patterns,
    }