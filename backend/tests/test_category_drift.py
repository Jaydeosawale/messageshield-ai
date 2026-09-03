from mlops.drift.category_drift import (
    calculate_psi,
    classify_drift,
)


def test_identical_distribution_has_zero_psi():
    baseline = {
        "BANKING": 0.50,
        "OTP": 0.50,
    }

    current = {
        "BANKING": 0.50,
        "OTP": 0.50,
    }

    psi = calculate_psi(baseline, current)

    assert psi == 0.0


def test_normal_drift():
    assert classify_drift(0.05) == "NORMAL"


def test_warning_drift():
    assert classify_drift(0.10) == "WARNING"
    assert classify_drift(0.20) == "WARNING"


def test_strong_drift():
    assert classify_drift(0.25) == "DRIFT"
    assert classify_drift(0.50) == "DRIFT"


def test_new_category_is_detected():
    baseline = {
        "BANKING": 1.0,
    }

    current = {
        "BANKING": 0.50,
        "PHISHING": 0.50,
    }

    psi = calculate_psi(baseline, current)

    assert psi > 0.25
