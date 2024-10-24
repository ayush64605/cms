import 'package:flutter/material.dart';
import 'package:myapp/screens/add_quotation.dart';

class ItemDetails extends StatefulWidget {
final String userId;
final String quotationDocId;


  const ItemDetails({required this.userId, required this.quotationDocId});
  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 4, 63, 132),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.04,
                      left: screenWidth * 0.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddQuotation(userId: widget.userId, quotationDocId: widget.quotationDocId,),
                                  ),
                                );
                              },
                            ),
                            const Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    _buildItemRow('Item name', 'name'),
                    _buildItemRow('Item quantity', '500 feet'),
                    _buildItemRow('Unit price', '100'),
                    _buildItemRow('Subtotal', '50000'),
                    _buildItemRow('GST(18%)', '9000'),
                    Container(
                      width: screenWidth * 0.9, // Set the width of the divider
                      child: Divider(
                        color: Color.fromARGB(255, 4, 63, 132),
                        thickness:
                            1.0, // Optional: Set the thickness of the divider
                      ),
                    ),
                    _buildItemRow('Total', '59000')
                  ],
                ),
              ),
            ),
             Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.40),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      
    );
  }
}
