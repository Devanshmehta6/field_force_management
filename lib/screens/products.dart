import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/screens/addProductScreen.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:field_force_management/constants.dart';
import 'package:intl/intl.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addProduct() async {
    if (_image == null ||
        _nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _costController.text.isEmpty) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    try {
      // Convert image to Base64 string
      String base64Image = await _convertImageToBase64(_image!);

      // Add product to Firestore with Base64 image string
      await _firestore.collection('products').add({
        'name': _nameController.text,
        'quantity': int.parse(_quantityController.text),
        'cost': double.parse(_costController.text),
        'imageBase64': base64Image, // Store the Base64 image string
        'date': DateFormat("dd MMMM yyyy").format(DateTime.now())
      });

      // Clear fields
      _nameController.clear();
      _quantityController.clear();
      _costController.clear();
      setState(() {
        _image = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
        ),
      );
    }
  }

  Future<String> _convertImageToBase64(XFile image) async {
    final imageBytes = await image.readAsBytes(); // Read image as bytes
    return base64Encode(imageBytes); // Convert to Base64 string
  }

  Future<void> _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  int counter = 0;

  void _showSlidingWidget(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true, // To make the background transparent
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _image!.path,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final XFile? pickedFile =
                                              await _picker.pickImage(
                                                  source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setState(() {
                                              _image = XFile(pickedFile.path);
                                            });
                                            setModalState(() {});
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor:
                                              Colors.purple.shade200,
                                        ),
                                        child: Text("Select Image",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ),
                                    ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  InputField(
                                      hintText: "Enter product name",
                                      controller: _nameController,
                                      isPassword: false,
                                      isReadOnly: false),
                                  const SizedBox(height: 16),
                                  InputField(
                                      hintText: "Enter product quantity",
                                      controller: _quantityController,
                                      isPassword: false,
                                      isReadOnly: false),
                                  const SizedBox(height: 16),
                                  InputField(
                                      hintText: "Enter cost price",
                                      controller: _costController,
                                      isPassword: false,
                                      isReadOnly: false),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addProduct();
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.pop(context);
                            }); // Close the modal
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.purple.shade200,
                          ),
                          child: Text("Add Product",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        // Enables full-screen height if needed
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('Products',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade200,
        actions: [
          IconButton(
              icon: Icon(
                Icons.add,
                size: 32,
                color: Colors.black,
              ),
              onPressed: () {
                _showSlidingWidget(context);
              })
        ],
      ),
      body: Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading products'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final productData = snapshot.data!.docs[index].data();
                String base64Image = productData[
                    'imageBase64']; // Retrieve the Base64 image string
                Uint8List imageBytes =
                    base64Decode(base64Image); // Decode to bytes
                double cardSize =
                    snapshot.data!.docs.length < 5 ? 200.0 : 300.0;
                // return ListTile(
                //   leading:
                //       Image.memory(imageBytes), // Display the image from bytes
                //   title: Text(productData['name']),
                //   subtitle: Text(
                //       'Quantity: ${productData['quantity']} | Cost: \$${productData['cost']}'),
                // );
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image and Availability Badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.memory(
                              imageBytes,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: true ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                true ? 'Available' : 'Disabled',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.circle_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(productData['name'],
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold)
                                // overflow: TextOverflow.ellipsis,
                                ),
                            SizedBox(height: 4),
                            // Date and Category
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(productData['date'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal)),
                                SizedBox(width: 4),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Price
                            Text('Rs.${productData['cost'].toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
