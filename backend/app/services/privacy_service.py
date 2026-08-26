import re
OTP=re.compile(r"(?i)\b(?:otp|one[- ]?time password|verification code)\D{0,20}(\d{4,8})\b")
CARD=re.compile(r"\b(?:\d[ -]*?){13,19}\b")
def redact(text:str)->str:
    text=OTP.sub(lambda m:m.group(0).replace(m.group(1),"[OTP_REDACTED]"),text)
    text=CARD.sub("[CARD_REDACTED]",text)
    return text
