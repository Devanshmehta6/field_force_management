import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/screens/Inventory%20Manager/inventoryManager.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({super.key});

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> items = ['Cash', 'Card'];
  String selectedValue = 'Cash';

  List<Map<String, dynamic>> products = [];
  Map<String, String> quantities = {};

  List<String> _checkedInEmployees = [];
  String? _selectedEmployee;

  Future<void> _fetchCheckedInEmployees() async {
    try {
      String todayDate = DateFormat('dd MMMM yyyy')
          .format(DateTime.now()); // e.g., "08 Oct 2024"

      List<String> checkedInEmployees = [];

      // Fetch all employee documents
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .get();

      for (var employeeDoc in employeeSnapshot.docs) {
        // Access the 'Record' subcollection for each employee document
        QuerySnapshot recordSnapshot = await FirebaseFirestore.instance
            .collection("Employee Attendance")
            .doc(employeeDoc.id)
            .collection("Record")
            .get();
        checkedInEmployees.add(employeeDoc['username']);
      }
      setState(() {
        _checkedInEmployees = checkedInEmployees;
      });
      print(_checkedInEmployees);
    } catch (e) {
      print("Error fetching checked-in employees: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch products from Firestore collection "products"
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        products = querySnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _saveInventory() async {
    if (_shopNameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        selectedValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }
    try {
      List<Map<String, dynamic>> inventoryToSave = [];

      quantities.forEach((productId, quantity) {
        if (quantity.isNotEmpty && int.parse(quantity) > 0) {
          final product = products.firstWhere((p) => p['id'] == productId);
          inventoryToSave.add({
            // 'productId': productId,
            'productName': product['name'],
            'quantity': int.parse(quantity),
          });
        }
      });

      await _firestore.collection('Inventories').add({
        'shop_name': _shopNameController.text,
        'contact_no': _contactController.text,
        'products': inventoryToSave,
        'employee_assigned' : _selectedEmployee
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding inventory: $e',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _fetchCheckedInEmployees();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final dialogWidth = mediaQuery.size.width * 0.8;
    final dialogHeight = mediaQuery.size.height * 0.6;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Inventory",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Shop Name Field
            TextField(
              style: GoogleFonts.poppins(fontSize: 16),
              controller: _shopNameController,
              decoration: InputDecoration(
                labelStyle: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.normal),
                labelText: "Shop Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(product['name'],
                                style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.normal),
                              labelText: "Quantity",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 16),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                quantities[product['id']] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              keyboardType: TextInputType.phone,
              maxLength: 10,
              
              style: GoogleFonts.poppins(fontSize: 16),
              controller: _contactController,
              decoration: InputDecoration(
                labelStyle: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.normal),
                labelText: "Contact Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 12),
                  child: DropdownButton<String>(
                    // Dropdown items
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      );
                    }).toList(),

                    // Value to display in the dropdown
                    value: selectedValue,

                    // Hint when no item is selected
                    hint: Text(
                      'Select payment mode',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),

                    // When an item is selected
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value.toString();
                      });
                    },
                  ),
                ),
                // SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedEmployee,
                  items: _checkedInEmployees.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role,
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEmployee = newValue;
                    });
                  },
                  hint: Text(
                    'Assign employee',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  onTap: () async {
                    _checkedInEmployees.isEmpty
                        ? CupertinoActivityIndicator()
                        : await _fetchCheckedInEmployees();
                  },
                ),
              ],
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_shopNameController.text.isNotEmpty) {
                      _saveInventory();
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.pop(context);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill in all fields"),
                        ),
                      );
                    }
                  },
                  child: Text("Save",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
