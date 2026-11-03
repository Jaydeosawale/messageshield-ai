import unittest
from app.services.risk_service import assess_risk


def check(message):
    return assess_risk(message, 'OTP', .9, 'SAFE', .95)


class DetectionRegressionTest(unittest.TestCase):
    def test_direct_secret_requests_override_missed_model_detection(self):
        for message in ['Please share the OTP', 'send otp immediately', 'share your upi pin', 'Ｓｅｎｄ ｏｔｐ', 's\u200bend otp']:
            with self.subTest(message=message):
                self.assertEqual(check(message)['risk'], 'HIGH')

    def test_legitimate_warnings_do_not_count_as_secret_requests(self):
        for message in ['Never share otp with anyone.', 'Do not share the OTP.', "Don't send otp to anybody."]:
            with self.subTest(message=message):
                self.assertNotIn('OTP_REQUEST', {x['type'] for x in check(message)['signals']})

    def test_warning_does_not_cancel_separate_malicious_instruction(self):
        for message in ['Never share otp. Send otp to me.', 'Do not share otp but send otp to our agent.', 'Never share otp\nsend otp to me']:
            self.assertEqual(check(message)['risk'], 'HIGH')

    def test_substrings_do_not_trigger_urgency(self):
        self.assertNotIn('URGENCY', {x['type'] for x in check('Your account is known to us.')['signals']})

    def test_ordinary_code_sharing_is_not_an_otp_request(self):
        self.assertNotIn('OTP_REQUEST', {x['type'] for x in check('Please share the code for our project.')['signals']})

    def test_entering_pin_in_payment_app_is_not_alone_critical(self):
        self.assertFalse(check('Enter your UPI PIN in your banking app to pay the merchant.')['critical_override'])
