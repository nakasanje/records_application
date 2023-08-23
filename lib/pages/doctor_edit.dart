import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:records_application/models/doctors.dart';

class ProductsTrendsList extends StatefulWidget {
  const ProductsTrendsList({super.key});

  @override
  State<ProductsTrendsList> createState() => _ProductsTrendsListState();
}

class _ProductsTrendsListState extends State<ProductsTrendsList> {
  List<DoctorModel> doctors = [];
  List<DoctorModel> filtereddoctors = [];

  @override
  void initState() {
    fetchTrends();
    super.initState();
  }

  fetchTrends() async {
    var trends = await FirebaseFirestore.instance.collection('doctor').get();
    mapTrends(trends);
  }

  mapTrends(QuerySnapshot<Map<String, dynamic>> trends) {
    var list = trends.docs
        .map((doctor) => DoctorModel(
              doctorId: doctor['doctorId'],
              email: doctor['email'],
              role: doctor['role'],
              photoUrl: doctor['photoUrl'],
              username: doctor['username'],
            ))
        .toList();

    setState(() {
      doctors = list;
      filtereddoctors = list; // Show all items by default
    });
  }

  void _performSearch(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all items
        filtereddoctors = List.from(doctors);
      } else {
        // Perform search and update the filteredTrends list
        filtereddoctors = doctors
            .where((doctor) => doctor.doctorId
                .toLowerCase()
                .contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSearchTextChanged(String searchText) {
    _performSearch(searchText);
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this Doctor?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(DoctorModel doctor) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();

    if (confirmDelete == true) {
      try {
        // Delete the item from Firestore
        await FirebaseFirestore.instance
            .collection('doctor')
            .doc(doctor.doctorId)
            .delete();

        // Update the filteredTrends list to remove the deleted item
        setState(() {
          filtereddoctors.remove(doctor);
        });

        // Show a snackbar to indicate successful deletion.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
          ),
        );
      } catch (e) {
        // Handle any errors that might occur during deletion
        print('Error deleting item: $e');
        // Show a snackbar to indicate an error occurred.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting item'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchTextChanged,
              decoration: const InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtereddoctors.length, // Use filteredTrends here
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(filtereddoctors[index].username),
                        subtitle: Text(
                            '${filtereddoctors[index].email}\n${filtereddoctors[index].username}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(filtereddoctors[
                              index]), // Pass the item to the delete function
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
