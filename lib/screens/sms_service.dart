import 'package:twilio_flutter/twilio_flutter.dart';

class SmsService {
  final String accountSid;
  final String authToken;
  final String fromNumber;
  late final TwilioFlutter twilioFlutter;

  SmsService({
    required this.accountSid,
    required this.authToken,
    required this.fromNumber,
  }) {
    twilioFlutter = TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: fromNumber,
    );
  }

  Future<void> sendSms(String toNumber, String message) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: toNumber,
        messageBody: message,
      );
      print('SMS sent successfully');
    } catch (e) {
      print('Failed to send SMS: $e');
    }
  }
}
