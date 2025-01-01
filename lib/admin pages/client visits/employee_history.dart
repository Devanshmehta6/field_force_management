import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EmployeeHistory extends StatefulWidget {
  const EmployeeHistory({super.key});

  @override
  State<EmployeeHistory> createState() => _EmployeeHistoryState();
}

class _EmployeeHistoryState extends State<EmployeeHistory> {
  List<Map<String, dynamic>> _employees = []; // List to store employees
  List<Map<String, dynamic>> _clientVisits = []; // List to store client visits
  bool _isLoading = true; // To indicate data loading
  String _searchQuery = ""; // Search query for employees
  String? _selectedEmployee; // Selected employee name

  @override
  void initState() {
    super.initState();
    _fetchEmployees(); // Fetch employees on page load
  }

  Future<void> _fetchEmployees() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch employees from the database
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .get();

      List<Map<String, dynamic>> employees = [];
      for (var doc in snapshot.docs) {
        employees.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClientVisits(String assignedTo) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch client visits for the selected employee
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Client Visits")
          .where("assigned_to", isEqualTo: assignedTo)
          .get();

      List<Map<String, dynamic>> clientVisits = [];
      for (var doc in snapshot.docs) {
        clientVisits.add(doc.data() as Map<String, dynamic>);
      }
      // print(clientVisits);
      setState(() {
        _clientVisits = clientVisits;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching client visits: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
            _selectedEmployee == null
                ? "Track your employees"
                : "Client Visits for $_selectedEmployee",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade200,
        actions: [
          if (_selectedEmployee == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: EmployeeSearchDelegate(
                      employees: _employees,
                      onEmployeeSelected: (employeeName) {
                        setState(() {
                          _selectedEmployee = employeeName;
                          _fetchClientVisits(employeeName);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _selectedEmployee == null
              ? ListView.builder(
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return ListTile(
                      title: Text(employee['username'] ?? "No Name"),
                      onTap: () {
                        setState(() {
                          _selectedEmployee = employee['username'];
                          _fetchClientVisits(employee['username']);
                        });
                      },
                    );
                  },
                )
              : _clientVisits.isEmpty
                  ? Center(child: Text("No client visits found."))
                  : ListView.builder(
                      itemCount: _clientVisits.length,
                      itemBuilder: (context, index) {
                        final visit = _clientVisits[index];
                        DateFormat inputFormat =
                            DateFormat("MMMM dd, yyyy 'at' hh:mm:ss a z");
                        DateTime parsedDate =
                            inputFormat.parse(visit['date_time']);
                        String formattedDate =
                            DateFormat('MMM dd, yyyy').format(parsedDate);

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              visit['name'] ?? "No Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Date: ${formattedDate}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            onTap: () {
                              // Define what happens when a tile is tapped
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: _selectedEmployee != null
          ? FloatingActionButton(
              child: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedEmployee = null; // Go back to employee list
                  _clientVisits = [];
                });
              },
            )
          : null,
    );
  }
}

class EmployeeSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> employees;
  final void Function(String) onEmployeeSelected;

  EmployeeSearchDelegate({required this.employees, required this.onEmployeeSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = employees
        .where((employee) => (employee['username'] ?? "")
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final employee = results[index];
        return ListTile(
          title: Text(employee['username'] ?? "No Name"),
          onTap: () {
            onEmployeeSelected(employee['username']);
            close(context, employee['username']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = employees
        .where((employee) => (employee['username'] ?? "")
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final employee = suggestions[index];
        return ListTile(
          title: Text(employee['username'] ?? "No Name"),
          onTap: () {
            query = employee['username'];
            showResults(context);
          },
        );
      },
    );
  }
}
