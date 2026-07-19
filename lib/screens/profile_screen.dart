import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../profile_provider.dart';
import '../theme_provider.dart';
import '../currency_provider.dart';
import '../review_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: () {
              final t = context.read<ThemeProvider>();
              t.toggleTheme(!t.isDarkMode);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // Profile photo (DP)
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.teal.shade100,
              backgroundImage: profile.imagePath.isNotEmpty
                  ? FileImage(File(profile.imagePath))
                  : null,
              child: profile.imagePath.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.teal)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              profile.name.isNotEmpty ? profile.name : 'Your Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),

          Center(
            child: Text(
              profile.dob.isNotEmpty ? 'DOB: ${profile.dob}' : 'Date of birth not set',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),

          // Edit profile button
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Currency selector
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(
              CurrencyProvider.currencies[
              context.watch<CurrencyProvider>().symbol] ??
                  '',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context),
          ),

          // Rate this app
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate this app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ReviewHelper.openStoreListing(),
          ),

          const Divider(),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Student Wallet by Daynix Studio',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Currency picker dialog
  void _showCurrencyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: CurrencyProvider.currencies.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () {
                  context.read<CurrencyProvider>().setCurrency(entry.key);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ---------------- Edit Profile Screen ----------------

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  String _dob = '';
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nameController = TextEditingController(text: profile.name);
    _dob = profile.dob;
    _imagePath = profile.imagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(picked.path);
    final saved = await File(picked.path).copy('${dir.path}/$fileName');

    setState(() => _imagePath = saved.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = DateFormat('dd MMM yyyy').format(picked));
    }
  }

  void _save() {
    context.read<ProfileProvider>().saveProfile(
      name: _nameController.text.trim(),
      dob: _dob,
      imagePath: _imagePath,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal.shade100,
                backgroundImage:
                _imagePath.isNotEmpty ? FileImage(File(_imagePath)) : null,
                child: _imagePath.isEmpty
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.teal)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Tap photo to change', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
              ),
              child: Text(_dob.isNotEmpty ? _dob : 'Select date'),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}