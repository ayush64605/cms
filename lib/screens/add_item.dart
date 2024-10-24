import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItem extends StatefulWidget {
  final String userId;
  final String quotationDocId;

  const AddItem({required this.userId, required this.quotationDocId});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitRateController = TextEditingController();

  String? _selectedUnit;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); 
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(widget.userId);

        CollectionReference itemsRef = userRef
            .collection('quotations')
            .doc(widget.quotationDocId)
            .collection('items');

        Navigator.pop(context); 

        await itemsRef.add({
          'itemName': _itemNameController.text.trim(),
          'quantity': int.tryParse(_qtyController.text.trim()) ?? 0,
          'unit': _selectedUnit ?? '',
          'unitRate': double.tryParse(_unitRateController.text.trim()) ?? 0.0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added successfully!')),
        );
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to add item: $e')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
     final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;
    final double imageTopPadding = screenHeight * 0.46;
    final double adjustedImageTopPadding =
        isKeyboardVisible ? screenHeight * 0.1 : imageTopPadding;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, 
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
                          top: screenHeight * 0.04, left: screenWidth * 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Go back to previous screen
                                },
                              ),
                              const Text(
                                'Add Item',
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

              // Form fields
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit rate field
                    TextFormField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: 'item name',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 4, 63, 132)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 4, 63, 132)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Quantity and Unit fields
                    Row(
                      children: [
                        // Quantity field
                        Expanded(
                          child: TextFormField(
                            controller: _qtyController,
                            decoration: InputDecoration(
                              labelText: 'Qty.',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 63, 132)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 63, 132)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the quantity';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),

                        // Unit dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            items: <String>['sqft', 'meter', 'numbers', 'ft']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 63, 132)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 63, 132)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a unit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _unitRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Unit rate',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 4, 63, 132)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 4, 63, 132)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Unit rate';
                        }
                        return null;
                      },
                    ),
                    SizedBox(width: 16),

                    // GST field

                    SizedBox(height: 16),
                  ],
                ),
              ),

              // Save Button
              Padding(
                padding: EdgeInsets.only(top: adjustedImageTopPadding),
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveItem, // Call the save method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Save',
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
      ),
    );
  }
}
