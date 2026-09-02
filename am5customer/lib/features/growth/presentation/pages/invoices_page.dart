import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  bool _loading = true;
  String? _error;
  List<Invoice> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await context.read<GrowthApi>().listInvoices();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } on Failure catch (f) {
      if (mounted) {
        setState(() {
          _error = f.message;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.invoices)),
      body: _loading
          ? LivoraLoading(message: s.loading)
          : _error != null
              ? Column(
                  children: [
                    Text(_error!),
                    LivoraButton(label: s.retry, onPressed: _load),
                  ],
                )
              : _items.isEmpty
                  ? Center(child: Text(s.offlineHint))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final inv = _items[i];
                        return ListTile(
                          title: Text('${inv.invoiceNumber} · ${inv.serviceName}'),
                          subtitle: Text(inv.issuedAt),
                          trailing: Text('₹${inv.totalAmount.toStringAsFixed(0)}'),
                        );
                      },
                    ),
    );
  }
}
