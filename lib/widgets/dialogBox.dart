import 'package:field_force_management/screens/Inventory%20Manager/inventoryManager.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({super.key});

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _paymentType = "Cash";

  final List<String> _allProducts = [
    "Product 1",
    "Product 2",
    "Product 3",
    "Product 4"
  ];
  List<String> _selectedProducts = [];
  List<int> _selectedQuantities = [];

  @override
  void initState() {
    super.initState();
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
                itemCount: _allProducts.length,
                itemBuilder: (context, index) {
                  final product = _allProducts[index];
                  
                  // Check if product is selected, default quantity is 0 if not
                  final currentQuantity = _selectedProducts.contains(product)
                      ? _selectedQuantities[_selectedProducts.indexOf(product)]
                      : 0;

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        // InputField(
                        //   isPassword: false,
                        //   isReadOnly: false,
                        //   // controller: ,
                        //   hintText: "0",
                        // ),
                        // Quantity TextField
                        // InputField(
                        //     hintText: "Quantity",
                        //     controller: TextEditingController(
                        //       text: currentQuantity > 0
                        //           ? currentQuantity.toString()
                        //           : '',
                        //     ),
                        //     isPassword: false,
                        //     isReadOnly: false)
                        // SizedBox(
                        //   width: 100,
                        //   child: TextField(
                        //     keyboardType: TextInputType.number,
                        //     decoration: InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       contentPadding:
                        //           EdgeInsets.symmetric(vertical: 4.0),
                        //     ),
                        //     controller: TextEditingController(
                        //       text: currentQuantity > 0
                        //           ? currentQuantity.toString()
                        //           : '',
                        //     ),
                        //     onChanged: (value) {
                        //       setState(() {
                        //         int quantity = int.tryParse(value) ?? 0;
                        //         if (quantity > 0) {
                        //           // Add or update the product and its quantity
                        //           if (!_selectedProducts.contains(product)) {
                        //             _selectedProducts.add(product);
                        //             _selectedQuantities.add(quantity);
                        //           } else {
                        //             _selectedQuantities[_selectedProducts
                        //                 .indexOf(product)] = quantity;
                        //           }
                        //         } else {
                        //           // Remove the product if quantity is 0
                        //           _selectedProducts.remove(product);
                        //           _selectedQuantities.removeAt(
                        //               _selectedProducts.indexOf(product));
                        //         }
                        //       });
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.0),

            // Quantity Input for Selected Products
            // if (_selectedProducts.isNotEmpty)
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "Enter Quantities:",
            //         style: GoogleFonts.poppins(
            //             fontSize: 14, fontWeight: FontWeight.bold),
            //       ),
            //       const SizedBox(height: 8.0),
            //       ..._selectedProducts.map((product) {
            //         return Padding(
            //           padding: const EdgeInsets.symmetric(vertical: 8.0),
            //           child: Row(
            //             children: [
            //               Expanded(
            //                 child: Text(
            //                   product,
            //                   style: GoogleFonts.poppins(fontSize: 14),
            //                 ),
            //               ),
            //               const SizedBox(width: 16.0),
            //               Expanded(
            //                 child: TextField(
            //                   controller: _quantityControllers[product],
            //                   keyboardType: TextInputType.number,
            //                   decoration: InputDecoration(
            //                     labelText: "Quantity",
            //                     labelStyle: GoogleFonts.poppins(fontSize: 14),
            //                     border: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(8.0),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         );
            //       }).toList(),
            //     ],
            //   ),

            // DropdownButtonFormField<String>(
            //   value: _paymentType,
            //   decoration: InputDecoration(
            //     labelStyle: GoogleFonts.poppins(
            //         fontSize: 16, fontWeight: FontWeight.normal),
            //     labelText: "Payment Contract Type",
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //   ),
            //   items: ["Cash", "Credit", "Online"]
            //       .map((type) => DropdownMenuItem(
            //             value: type,
            //             child: Text(
            //               type,
            //               style: GoogleFonts.poppins(fontSize: 16),
            //             ),
            //           ))
            //       .toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _paymentType = value;
            //     });
            //   },
            // ),
            // SizedBox(height: 16.0),

            // // Quantity Needed Field
            // TextField(
            //   controller: _quantityController,
            //   keyboardType: TextInputType.number,
            //   decoration: InputDecoration(
            //     labelStyle: GoogleFonts.poppins(
            //         fontSize: 16, fontWeight: FontWeight.normal),
            //     labelText: "Quantity Needed",
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 24.0),

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
                    if (_shopNameController.text.isNotEmpty &&
                        _productsController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) {
                      // Perform save operation here
                      Navigator.of(context).pop();
                      // InventoryManager().buildTableRow();
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text(
                      //         "Inventory for ${_shopNameController.text} added successfully!",
                      //         style: GoogleFonts.poppins(
                      //             fontSize: 16, fontWeight: FontWeight.normal)),
                      //   ),
                      // );
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
