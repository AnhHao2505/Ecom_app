const payosWorkerBaseUrl = String.fromEnvironment(
  'PAYOS_WORKER_URL',
  defaultValue: 'https://emart-payos-api.lndkhang278.workers.dev',
);

const payosUsdToVndRate = 26000;

int usdToVnd(double amount) => (amount * payosUsdToVndRate).round();

String formatVnd(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer(String.fromCharCode(0x20AB));
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[index]);
  }
  return buffer.toString();
}
