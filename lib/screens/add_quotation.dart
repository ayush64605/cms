import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/add_item.dart';
import 'package:myapp/screens/item_details.dart';
import 'package:myapp/screens/quotations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class AddQuotation extends StatefulWidget {
  final String userId;
  final String quotationDocId;

  const AddQuotation({required this.userId, required this.quotationDocId});

  @override
  State<AddQuotation> createState() => _AddQuotationState();
}

class _AddQuotationState extends State<AddQuotation> {
  Future<DocumentSnapshot> _fetchQuotationData() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('quotations')
        .doc(widget.quotationDocId);

    return await docRef.get();
  }

  Stream<QuerySnapshot> _fetchQuotationItems() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('quotations')
        .doc(widget.quotationDocId)
        .collection('items')
        .snapshots();
  }

  Future<void> _downloadPDF() async {
    final pdf = pw.Document();

    // Load image from assets
    final ByteData bytes = await rootBundle.load('asset/logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();

    // Fetch items from Firestore
    List<Map<String, dynamic>> items = [];
    final userId = 'your_user_id'; // Replace with actual userId
    final quotationDocid =
        'your_quotation_docid'; // Replace with actual quotationDocid

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('quotations')
        .doc(widget.quotationDocId)
        .collection('items')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        items.add(doc.data() as Map<String, dynamic>);
      });
    });

    // Calculate total of all items' totals
    double grandTotal = 0.0;
    List<List<String>> tableData =
        List<List<String>>.generate(items.length, (index) {
      final item = items[index];
      final itemName = item['itemName'] ?? '';
      final quantity = item['quantity']?.toString() ?? '';
      final unitRate = item['unitRate']?.toString() ?? '';
      final total = (item['quantity'] * item['unitRate']).toString();
      grandTotal += item['quantity'] * item['unitRate'];
      return [(index + 1).toString(), itemName, quantity, unitRate, total];
    });

    // Add a page to the PDF
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
                  pw.SizedBox(width: 10),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(
                  color: PdfColor.fromInt(
                      0xFF012A56)), // Equivalent to Color.fromRGBO(1, 42, 86, 1)
              pw.SizedBox(height: 20),
              pw.Text('Item Details', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Index',
                  'Item Name',
                  'Quantity',
                  'Unit Rate/Unit',
                  'Total'
                ],
                data: tableData,
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF012A56)),
                  ),
                  pw.Text(
                    grandTotal.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          );
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => quotationscreen(userId: widget.userId),
          ),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
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
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => quotationscreen(
                                            userId: widget.userId),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: _fetchQuotationData(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    }
                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return Center(
                                          child: Text('Quotation not found'));
                                    }

                                    var data = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    var quotationName = data['quotationName'];
                                    var clientName = data['clientName'];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$quotationName',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$clientName',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.09),
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
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.06,
                    right: screenWidth * 0.06,
                    top: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _fetchQuotationItems(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Items (0)', // Default text while waiting
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Items (0)', // Default text in case of error
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(
                              'Items (0)', // Text when no items are found
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }

                          // Calculate item count
                          final itemCount = snapshot.data!.docs.length;

                          return Text(
                            'Items ($itemCount)', // Display dynamic item count
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddItem(
                                userId: widget.userId,
                                quotationDocId: widget.quotationDocId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 4, 63, 132),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          'Add Item',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: screenHeight *
                  0.20, // Adjust the top position to match the height of the static content
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchQuotationItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No items found'));
                    }

                    // Extract item documents from snapshot
                    final items = snapshot.data!.docs;

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            final itemName = item['itemName'] ??
                                'Item Name'; // Replace with your field
                            final itemPrice = item['unitRate'] ??
                                0; // Replace with your field
                            final itemArea = item['quantity'] ??
                                '500 sqft'; // Replace with your field

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal:
                                      17), // Added margin between containers
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 245, 245, 245),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '$itemArea @ rs. $itemPrice/sqft',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.more_vert,
                                            color: Colors.black54),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 90,
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  children: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        // Get the reference to the item document to be deleted
                                                        final itemDoc =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(widget
                                                                    .userId)
                                                                .collection(
                                                                    'quotations')
                                                                .doc(widget
                                                                    .quotationDocId)
                                                                .collection(
                                                                    'items')
                                                                .doc(item.id);

                                                        // Delete the item document
                                                        try {
                                                          await itemDoc
                                                              .delete(); // Close the modal after deletion
                                                        } catch (e) {
                                                          print(
                                                              'Error deleting item: $e');
                                                          // Optionally, show an error message to the user
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                214, 10, 10),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.black26),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rs. ${item['quantity'] * item['unitRate']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.2), // Add space to make sure the last container is not hidden
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchQuotationItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(16),
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Color.fromARGB(255, 4, 63, 132),
                        ),
                      ),
                      child: Text('No items to display'),
                    );
                  }

                  // Calculate total sum of all items' prices
                  final items = snapshot.data!.docs;
                  double total = 0;
                  items.forEach((item) {
                    final quantity = item['quantity'] ?? 0;
                    final unitRate = item['unitRate'] ?? 0;
                    total += quantity * unitRate;
                  });

                  return Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(16),
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color.fromARGB(255, 4, 63, 132),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Rs. $total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
