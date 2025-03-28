import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/widgets/dialogBox.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryManager extends StatefulWidget {
  const InventoryManager({super.key});

  @override
  State<InventoryManager> createState() => _InventoryManagerState();
}

class _InventoryManagerState extends State<InventoryManager> {
  late Stream<List<Map<String, dynamic>>> inventoriesStream;

  @override
  void initState() {
    super.initState();
    inventoriesStream = fetchInventories();
  }

  Stream<List<Map<String, dynamic>>> fetchInventories() {
    return FirebaseFirestore.instance
        .collection('Inventories') // The 'inventory' collection in Firestore
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              print(doc.id);
              return {
                'doc_id' : doc.id,
                'shopName': data['shop_name'] ?? '',
                'products': data['products'] ?? [],
                'employee_assigned':
                    data['employee_assigned'] ?? '', // Default status
              };
            }).toList());
  }

  void _showSlidingWidget(
    BuildContext context,
    List products,
    String emp,
    // VoidCallback onSave,
    String id
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        print(id);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      emp,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text("Name: ${product["productName"]}"),
                          subtitle: Row(
                            children: [
                              Text("Quantity: "),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                      text: product["quantity"].toString()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setModalState(() {
                                      // Update the quantity for the product
                                      products[index]["quantity"] =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(8.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        

                        // Call the onSave callback
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Inventories',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade200,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Section: Project Analysis Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard(
                    "Annual Client Management", Icons.analytics, width, 50),
                _buildCard("Monthly Clients Served", Icons.people, width, 15),
                _buildCard("Recent Earnings", Icons.attach_money, width, 2000),
              ],
            ),
            SizedBox(height: height * 0.03),

            // Middle Section: Charts and Summary
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTableSection(),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    flex: 1,
                    child: _buildSummarySection(height, context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, double width, double value) {
    return Container(
      width: width * 0.3,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple.shade200, size: 36),
          const SizedBox(height: 8.0),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16.0),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading and Add New Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active Inventories",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add logic to open the dialog box for adding new inventories
                  showDialog(
                    context: context,
                    builder: (context) => DialogBox(), // Your dialog widget
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade200,
                ),
                child: Text(
                  "Add New",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Active Inventories List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: inventoriesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching inventories'),
                  );
                }

                final inventories = snapshot.data ?? [];

                if (inventories.isEmpty) {
                  return Center(
                    child: Text(
                      "No active inventories found.",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  );
                }

                return ListView(
                  children: inventories
                      .map((inventory) => buildTableRow(
                          inventory['shopName'],
                          inventory['products'],
                          inventory['employee_assigned'],
                          inventory['doc_id']
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Widget buildTableRow(
  Widget buildTableRow(String shopName, List products, String emp, String id) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade200,
          child: Icon(
            Icons.store,
            color: Colors.white,
          ),
        ),
        title: Text(shopName,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Products: ${products.length}",
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600),
            ),
            Text(
              "Incharge: ${emp}",
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[600],
        ),
        onTap: () {
          // Define what happens when a tile is tapped
          _showSlidingWidget(context, products, emp, id);
        },
      ),
    );
  }

  Widget _buildSummarySection(double height, BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final List<String> _targets = []; // Initial targets

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upcoming Targets",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),
              // Input Field and Add Button
              Row(
                children: [
                  Expanded(
                      child: InputField(
                          hintText: "Add new target",
                          controller: _controller,
                          isPassword: false,
                          isReadOnly: false)),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          _targets.add(_controller.text);
                          _controller.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200),
                    child: Text(
                      "Add",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),

              // List of Targets
              Expanded(
                child: _targets.isEmpty
                    ? Center(
                        child: Text(
                          "No targets yet. Add your first one!",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _targets.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _targets[index],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            leading: Icon(
                              Icons.assignment,
                              color: Colors.purple.shade200,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _targets.removeAt(index);
                                });
                              },
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Tapped on: ${_targets[index]}")),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
