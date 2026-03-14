import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactHelper {
  static Future<Contact?> pickContact(BuildContext context) async {
    try {
      debugPrint('Requesting contact permission directly...');
      final hasPermission = await FlutterContacts.requestPermission(readonly: true);
      
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact permissions denied.')));
        }
        return null;
      }

      debugPrint('Fetching all contacts locally...');
      // Load all contacts with basic info
      final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: false);
      
      if (!context.mounted) return null;

      // Show bottom sheet
      return await showModalBottomSheet<Contact>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => _ContactPickerSheet(contacts: contacts),
      );

    } catch (e, stack) {
      debugPrint('Error picking contact: $e');
      debugPrint(stack.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    return null;
  }
}

class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  const _ContactPickerSheet({required this.contacts});
  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  late List<Contact> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  void _filter(String query) {
    setState(() {
      _filteredContacts = widget.contacts
          .where((c) => c.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Select a Contact', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'Search friends...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredContacts.isEmpty
                ? const Center(child: Text('No contacts found'))
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final c = _filteredContacts[index];
                      final hasPhone = c.phones.isNotEmpty;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Text(c.displayName.isNotEmpty ? c.displayName[0].toUpperCase() : '?', 
                                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: hasPhone ? Text(c.phones.first.number, style: TextStyle(color: Colors.grey.shade500)) : const Text('No phone number'),
                        enabled: hasPhone,
                        onTap: () {
                          // Pass back the selected contact
                          Navigator.pop(context, c);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
