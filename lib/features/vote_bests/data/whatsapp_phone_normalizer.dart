String? normalizeWhatsAppPhone(String rawPhone) {
  String phone =
      rawPhone.trim().replaceAll(RegExp(r'[\s\-\(\)\[\]\{\}\+]'), '');
  if (phone.startsWith('00')) {
    phone = phone.substring(2);
  }
  if (!RegExp(r'^\d+$').hasMatch(phone)) {
    return null;
  }
  if (phone.length == 8) {
    return '65$phone';
  }
  if (phone.startsWith('65') && phone.length == 10) {
    return phone;
  }
  if (phone.length >= 9 && phone.length <= 15) {
    return phone;
  }
  return null;
}
