import 'package:url_launcher/url_launcher.dart';

import 'whatsapp_phone_normalizer.dart';

typedef LaunchPresidentWhatsApp = Future<bool> Function({
  required String rawPhone,
  required String message,
});

Future<bool> launchWhatsAppToPresidentDefault({
  required String rawPhone,
  required String message,
}) async {
  final String? phone = normalizeWhatsAppPhone(rawPhone);
  if (phone == null) {
    return false;
  }

  final String encodedMessage = Uri.encodeComponent(message);
  final Uri whatsappUri = Uri.parse(
    'whatsapp://send?phone=$phone&text=$encodedMessage',
  );
  final Uri webFallbackUri = Uri.parse(
    'https://wa.me/$phone?text=$encodedMessage',
  );

  try {
    final bool openedWhatsapp = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );
    if (openedWhatsapp) {
      return true;
    }
  } catch (_) {
    // Continue to web fallback.
  }

  try {
    return await launchUrl(
      webFallbackUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    return false;
  }
}
