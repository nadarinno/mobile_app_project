import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/Controller/PaymentController.dart';



class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentController controller = PaymentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      appBar: AppBar(
        title: const Text('Add Payment'),
        backgroundColor: const Color(0xFFFFFDF6),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: controller.cardNumber,
              expiryDate: controller.expiryDate,
              cardHolderName: controller.cardHolderName,
              cvvCode: controller.cvvCode,
              showBackView: controller.isCvvFocused,
              cardBgColor: const Color(0xFF561C24),
              obscureCardCvv: true,
              obscureCardNumber: false,
              isHolderNameVisible: true,
              labelCardHolder: "Cardholder",
              onCreditCardWidgetChange: (brand) {},
            ),
            CreditCardForm(
              formKey: controller.formKey,
              obscureCvv: true,
              obscureNumber: false,
              cardNumber: controller.cardNumber,
              expiryDate: controller.expiryDate,
              cardHolderName: controller.cardHolderName,
              cvvCode: controller.cvvCode,
              isHolderNameVisible: true,
              isCardNumberVisible: true,
              isExpiryDateVisible: true,
              onCreditCardModelChange: (data) {
                controller.onCreditCardModelChange(
                  cardNumber: data.cardNumber,
                  expiryDate: data.expiryDate,
                  cardHolderName: data.cardHolderName,
                  cvvCode: data.cvvCode,
                  isCvvFocused: data.isCvvFocused,
                );
                setState(() {}); // Update UI
              },
              inputConfiguration: const InputConfiguration(
                cardNumberDecoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  border: OutlineInputBorder(),
                ),
                expiryDateDecoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                cvvCodeDecoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  border: OutlineInputBorder(),
                ),
                cardHolderDecoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: controller.isLoading,
              builder: (context, loading, _) {
                return loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () => controller.submitPaymentForm(context, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF561C24),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    "Add Payment",
                    style: TextStyle(color: Color(0xFFFFFDF6), fontSize: 18),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Color(0xFF561C24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

