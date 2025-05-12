import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetails extends StatefulWidget {
  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();

  bool flag = false;
  late SharedPreferences pr;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    pr = await SharedPreferences.getInstance();
    flag = pr.getBool("is_avail") ?? false;

    if (flag) {
      setState(() {
        nameController.text = pr.getString("name") ?? '';
        mobileController.text = pr.getString("mobileNo") ?? '';
        addressController.text = pr.getString("address") ?? '';
        cityController.text = pr.getString("city") ?? '';
        stateController.text = pr.getString("state") ?? '';
        pinController.text = pr.getString("pin") ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE0F2F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      flag ? "Check Your Details" : "Enter Your Details",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                _buildInputField(
                  label: 'Full Name',
                  icon: Icons.person,
                  controller: nameController,
                  validator: () {
                    if (nameController.text.trim().isEmpty) {
                      return 'Please enter full name';
                    }
                    if (nameController.text.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  label: 'Street Address',
                  icon: Icons.location_on,
                  controller: addressController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: () {
                    if (addressController.text.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'City',
                        icon: Icons.location_city,
                        controller: cityController,
                        validator: () =>
                        cityController.text.trim().isEmpty ? 'Enter city' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'State',
                        icon: Icons.map,
                        controller: stateController,
                        validator: () =>
                        stateController.text.trim().isEmpty ? 'Enter state' : null,
                      ),
                    ),
                  ],
                ),
                _buildInputField(
                  label: 'PIN Code',
                  icon: Icons.numbers,
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: () {
                    final text = pinController.text.trim();
                    if (text.isEmpty) return 'Please enter PIN code';
                    if (text.length != 6) return 'PIN code must be 6 digits';
                    return null;
                  },
                ),
                _buildInputField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: () {
                    final text = mobileController.text.trim();
                    if (text.isEmpty) return 'Please enter phone number';
                    if (text.length != 10) return 'Phone number must be 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    label: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    icon: const Icon(Icons.navigate_next_sharp,
                        color: Colors.white, size: 30),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveDetails();
                        Navigator.pop(context,true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Details Saved')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function() validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        validator: (_) => validator(),
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
          fillColor: Colors.tealAccent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal),
          ),
        ),
      ),
    );
  }

  void _saveDetails() async {
    await pr.setString("name", nameController.text.trim());
    await pr.setString("mobileNo", mobileController.text.trim());
    await pr.setString("address", addressController.text.trim());
    await pr.setString("city", cityController.text.trim());
    await pr.setString("state", stateController.text.trim());
    await pr.setString("pin", pinController.text.trim());
    await pr.setBool("is_avail", true);
  }
}