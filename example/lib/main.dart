import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

/// Minimal host app: what integrating the scanner module looks like.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // the scanner UI is portrait-only
  runApp(const MaterialApp(title: 'Scanner example', debugShowCheckedModeBanner: false, home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String status = 'No scan yet';

  Future<void> _scan(ScannerTab tab) async {
    final result = await Scanner.open(context, tab: tab);
    if (!mounted) return;
    setState(
      () => status = result == null
          ? 'Closed without scanning'
          : '"${result.title}": ${result.pages.length} page(s)${result.pdf == null ? '' : ', PDF ${result.pdf!.path}'}',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scanner module')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(status),
        const SizedBox(height: 16),
        for (final tab in ScannerTab.values)
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined),
            title: Text(tab.title(context)),
            onTap: () => _scan(tab),
          ),
      ],
    ),
  );
}
