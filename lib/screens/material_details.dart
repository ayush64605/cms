import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/add_quotation.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class MaterialDetails extends StatefulWidget {
  final String userId;
  final String materialorderDocId;

  const MaterialDetails(
      {required this.userId, required this.materialorderDocId});

  @override
  State<MaterialDetails> createState() => _MaterialDetailsState();
}

class _MaterialDetailsState extends State<MaterialDetails> {
  Future<Map<String, dynamic>> fetchOrderData() async {
    DocumentSnapshot orderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('orders')
        .doc(widget.materialorderDocId)
        .get();

    return orderDoc.data() as Map<String, dynamic>;
  }

  String companyName = '';

  @override
  void initState() {
    super.initState();
    fetchCompanyName();
  }

  Future<void> fetchCompanyName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          companyName = userDoc['companyName'];
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching company name: $e');
    }
  }

  Future<void> _downloadPDF() async {
    final pdf = pw.Document();

    // Load image from assets
    final ByteData bytes = await rootBundle.load('asset/logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();

    // Fetch items and order details from Firestore
    List<Map<String, dynamic>> items = [];
    Map<String, dynamic>? orderDetails;
    final userId = widget.userId; // Replace with actual userId
    final materialOrderDocId =
        widget.materialorderDocId; // Replace with actual materialorderDocId

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(materialOrderDocId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        orderDetails = doc.data() as Map<String, dynamic>;
      }
    });

    // Calculate total of all items' totals// Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(pw.MemoryImage(byteList), width: 200, height: 200),
                    pw.SizedBox(width: 200),
                    pw.Text(companyName)
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(
                    color: PdfColor.fromInt(
                        0xFF012A56)), // Equivalent to Color.fromRGBO(1, 42, 86, 1)
                pw.SizedBox(height: 20),
                if (orderDetails != null) ...[
                  pw.Row(
                    children: [
                      pw.Text('Material Name: ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(orderDetails!['materialName'] ?? '',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Text('Quantity: ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(orderDetails!['quantity']?.toString() ?? '',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Text('Client Name: ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(orderDetails!['clientName'] ?? '',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Text('Client Number: ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(orderDetails!['clientNumber'] ?? '',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Text('Address: ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(orderDetails!['address'] ?? '',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],
              ]);
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/item_details.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

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
                                    builder: (context) => Materialside(
                                      userId: widget.userId,
                                    ),
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
                            Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.47),
                              child: IconButton(
                                icon: Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    _downloadPDF, // Call the download function
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
            FutureBuilder<Map<String, dynamic>>(
              future: fetchOrderData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  Map<String, dynamic> orderData = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                _buildItemRow(
                                    'Material name', orderData['materialName']),
                                _buildItemRow(
                                    'Quantity', orderData['quantity']),
                                _buildItemRow(
                                    'Client Name', orderData['clientName']),
                                _buildItemRow(
                                    'Client no.', orderData['clientNumber']),
                                _buildItemRow('Delivery address', ''),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          orderData['address'],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
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
