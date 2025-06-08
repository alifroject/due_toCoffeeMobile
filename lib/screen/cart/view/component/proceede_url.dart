import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final String invoiceUrl;

  const PaymentConfirmationPage({Key? key, required this.invoiceUrl}) : super(key: key);

  @override
  _PaymentConfirmationPageState createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  late InAppWebViewController webViewController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.invoiceUrl)),
            onWebViewCreated: (controller) => webViewController = controller,
            onLoadStart: (controller, url) => setState(() => isLoading = true),
            onLoadStop: (controller, url) => setState(() => isLoading = false),
            onLoadError: (controller, url, code, message) => setState(() => isLoading = false),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
