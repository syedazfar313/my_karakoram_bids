// lib/screens/supplier/add_material.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class AddMaterialPage extends StatefulWidget {
  final UserModel supplier;
  final String? materialId;
  final Map<String, dynamic>? materialData;

  const AddMaterialPage({
    super.key,
    required this.supplier,
    this.materialId,
    this.materialData,
  });

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Material constants
  final List<String> materials = [
    'Pathar (Stone)',
    'Raat (Sand)',
    'Bajari (Gravel)',
    'Cement',
    'Sariya (Steel Rod)',
    'Eent (Brick)',
    'Lakri (Wood)',
  ];

  final List<String> vehicles = ['Tractor', 'Mazda', 'Dumper', 'Pickup'];

  final List<String> units = ['Ton', 'Kg', 'Bag', 'Piece', 'Foot', 'CFT'];

  // Form controllers
  String? selectedMaterial;
  String? selectedUnit = 'Ton';
  String? selectedVehicle;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryChargesController =
      TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _vehicleCapacityController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isAvailable = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.materialData != null) {
      _loadMaterialData();
    }
  }

  void _loadMaterialData() {
    final data = widget.materialData!;
    selectedMaterial = data['name'];
    selectedUnit = data['unit'] ?? 'Ton';
    selectedVehicle = data['vehicleType'];
    _priceController.text = data['pricePerUnit']?.toString() ?? '';
    _quantityController.text = data['quantity']?.toString() ?? '';
    _deliveryChargesController.text = data['deliveryCharges']?.toString() ?? '';
    _vehicleNumberController.text = data['vehicleNumber'] ?? '';
    _vehicleCapacityController.text = data['vehicleCapacity']?.toString() ?? '';
    _descriptionController.text = data['description'] ?? '';
    isAvailable = data['isAvailable'] ?? true;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _deliveryChargesController.dispose();
    _vehicleNumberController.dispose();
    _vehicleCapacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.materialId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Material' : 'Add New Material'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Material Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Material Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMaterial,
                      decoration: const InputDecoration(
                        labelText: 'Select Material *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: materials.map((material) {
                        return DropdownMenuItem(
                          value: material,
                          child: Text(material),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMaterial = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a material';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price per Unit *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              hintText: 'e.g., 5000',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUnit = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Available Quantity *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.inventory_2),
                        hintText: 'e.g., 100',
                        suffixText: selectedUnit,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Available for Order'),
                      subtitle: Text(
                        isAvailable
                            ? 'Material is available'
                            : 'Material is out of stock',
                      ),
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery & Vehicle Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery & Vehicle Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryChargesController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Charges (per km)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping),
                        hintText: 'e.g., 50',
                        helperText: 'Leave empty if no delivery available',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedVehicle,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                      items: vehicles.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle,
                          child: Text(vehicle),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVehicle = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vehicleNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                        hintText: 'e.g., ABC-123',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vehicleCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Capacity (tons)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                        hintText: 'e.g., 10',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter any additional details...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveMaterial,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Material' : 'Add Material',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final materialData = {
        'supplierId': widget.supplier.id,
        'supplierName': widget.supplier.name,
        'name': selectedMaterial,
        'unit': selectedUnit,
        'pricePerUnit': int.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'isAvailable': isAvailable,
        'deliveryCharges': _deliveryChargesController.text.isNotEmpty
            ? int.parse(_deliveryChargesController.text)
            : null,
        'vehicleType': selectedVehicle,
        'vehicleNumber': _vehicleNumberController.text.isNotEmpty
            ? _vehicleNumberController.text
            : null,
        'vehicleCapacity': _vehicleCapacityController.text.isNotEmpty
            ? int.parse(_vehicleCapacityController.text)
            : null,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.materialId != null) {
        // Update existing material
        await _firestore
            .collection('materials')
            .doc(widget.materialId)
            .update(materialData);
      } else {
        // Add new material
        materialData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('materials').add(materialData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.materialId != null
                  ? 'Material updated successfully'
                  : 'Material added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
