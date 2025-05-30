import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/reviews_controller.dart';
import 'package:intl/intl.dart';

class ReviewsPage extends StatefulWidget {
  final String productId;

  const ReviewsPage({required this.productId, Key? key}) : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late final ReviewsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReviewsController();
    _controller.fetchReviews(widget.productId).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews: $e'), backgroundColor: Colors.red),
      );
    });
    _controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product Reviews"),
        backgroundColor: const Color(0xFF561C24),
        foregroundColor: Colors.white,
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            children: [
              SizedBox(height: height * 0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Reviews",
                  style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: height * 0.01),
              Expanded(
                child: _controller.errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error: ${_controller.errorMessage}",
                        style: TextStyle(fontSize: width * 0.04, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => _controller.fetchReviews(widget.productId),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
                    : _controller.productReviews.isNotEmpty
                    ? ListView.builder(
                  itemCount: _controller.productReviews.length,
                  itemBuilder: (context, index) {
                    final review = _controller.productReviews[index];
                    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                    final formattedDate = review['timestamp'] != null
                        ? dateFormat.format((review['timestamp'] as Timestamp).toDate())
                        : 'Unknown date';
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['text'] ?? 'No text',
                            style: TextStyle(fontSize: width * 0.04, color: Colors.grey[800]),
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            "By: ${review['userName'] ?? 'Anonymous'}",
                            style: TextStyle(fontSize: width * 0.035, color: Colors.grey[500]),
                          ),
                          Text(
                            "On: $formattedDate",
                            style: TextStyle(fontSize: width * 0.035, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Text(
                    "No reviews yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: const BoxDecoration(
          color: Color(0xFFF5EDE0),
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller.reviewController,
                    maxLines: null,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: "Type your review...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: const Color(0xFF561C24),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _controller.submitReview(context, widget.productId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}