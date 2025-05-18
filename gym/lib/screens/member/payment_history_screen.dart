import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../models/payment.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final payments = await _paymentService.getMemberPayments(
          authProvider.currentUser!.id,
        );

        setState(() {
          _payments = payments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Kullanıcı bilgisi bulunamadı';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ödeme geçmişi yüklenirken hata: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Geçmişi')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _payments.isEmpty
              ? const Center(child: Text('Ödeme geçmişi bulunamadı'))
              : ListView.builder(
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment.formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                payment.formattedAmount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Ödeme Türü: ${payment.paymentTypeName}'),
                          if (payment.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(payment.description),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
