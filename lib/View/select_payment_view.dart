import 'package:flutter/material.dart';
import '../Controller/select_payment_controller.dart';

class SelectPaymentMethod extends StatefulWidget {
  const SelectPaymentMethod({super.key});

  @override
  _SelectPaymentMethodState createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  final PaymentController _controller = PaymentController();
  List<Map<String, dynamic>> cards = [];
  bool isLoading = false;
  int? selectedCardIndex;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    setState(() {
      isLoading = true;
    });

    cards = await _controller.fetchCards();

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFE5E1DA),
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: Color(0xFF561C24)),
          ),
          content: Text(
            'Are you sure you want to delete this card?',
            style: TextStyle(color: Color(0xFF561C24)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF561C24)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFFFDF6)),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF561C24)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E1DA),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Select a Payment Method', style: TextStyle(color: Color(0xFF561C24))),
        backgroundColor: Color(0xFFE5E1DA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _controller.addNewCard,
              child: Text('Add new', style: TextStyle(color: Color(0xFFFFFDF6))),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF561C24)),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : cards.isEmpty
                  ? Center(child: Text('No payment methods found.', style: TextStyle(color: Color(0xFF561C24))))
                  : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final isSelected = selectedCardIndex == index;
                  return Dismissible(
                    key: Key(card['paymentId']),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await _confirmDelete(context);
                    },
                    onDismissed: (direction) async {
                      final paymentId = card['paymentId'];
                      await _controller.deleteCard(paymentId);
                      setState(() {
                        cards.removeAt(index);
                        if (selectedCardIndex == index) {
                          selectedCardIndex = null;
                        } else if (selectedCardIndex != null && selectedCardIndex! > index) {
                          selectedCardIndex = selectedCardIndex! - 1;
                        }
                      });
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white, size: 28),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCardIndex = index;
                        });
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(color: Color(0xFF561C24), width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            'Visa Debit Classic ***${card['number'].toString().substring(card['number'].length - 4)}',
                            style: TextStyle(color: Color(0xFF561C24)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(card['name'], style: TextStyle(color: Color(0xFF561C24))),
                              Text(card['expiry'], style: TextStyle(color: Color(0xFF561C24))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedCardIndex != null
                  ? () {
                final selectedCard = cards[selectedCardIndex!];
                _controller.continuePayment(selectedCard);
              }
                  : null,
              child: Text('Continue', style: TextStyle(color: Color(0xFFFFFDF6))),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF561C24)),
            ),
          ],
        ),
      ),
    );
  }
}