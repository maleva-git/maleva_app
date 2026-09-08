import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

class CreateRTIScreen extends StatefulWidget {
  const CreateRTIScreen({Key? key}) : super(key: key);

  @override
  State<CreateRTIScreen> createState() => _CreateRTIScreenState();
}

class _CreateRTIScreenState extends State<CreateRTIScreen> {
  String selectedStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Create RTI (Live Tracking)', style: AppTypography.heading2(color: colour.kWhite)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: colour.kWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Card
            _buildSectionHeader(Icons.info, 'Basic Information', Colors.blue),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Job Number (From Planning)', border: OutlineInputBorder()),
                      items: ['JOB-8992', 'JOB-8993'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Truck', border: OutlineInputBorder()),
                          items: ['TN-04-AX-1234'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {},
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Driver', border: OutlineInputBorder()),
                          items: ['Ramesh'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {},
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Status Tracking
            _buildSectionHeader(Icons.satellite_alt, 'Live Status Monitoring', Colors.green),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RadioListTile<String>(title: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), value: 'Active', groupValue: selectedStatus, onChanged: (v) => setState(() => selectedStatus = v!)),
                  RadioListTile<String>(title: const Text('Sleeping', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), value: 'Sleeping', groupValue: selectedStatus, onChanged: (v) => setState(() => selectedStatus = v!)),
                  RadioListTile<String>(title: const Text('On Time', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), value: 'On Time', groupValue: selectedStatus, onChanged: (v) => setState(() => selectedStatus = v!)),
                  RadioListTile<String>(title: const Text('Maintenance', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), value: 'Maintenance', groupValue: selectedStatus, onChanged: (v) => setState(() => selectedStatus = v!)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Multi-Stop Pickups
            _buildSectionHeader(Icons.unarchive, 'Pickups (Multi-Stop)', Colors.orange),
            Card(
              elevation: 2,
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(decoration: const InputDecoration(labelText: 'Pickup Address', filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Date/Time', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Qty', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Wgt (T)', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Add Pickup')))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Multi-Stop Deliveries
            _buildSectionHeader(Icons.archive, 'Deliveries (Multi-Stop)', Colors.purple),
            Card(
              elevation: 2,
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(decoration: const InputDecoration(labelText: 'Delivery Address', filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Date/Time', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Qty', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Wgt (T)', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Add Delivery')))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security & Warehouse
            _buildSectionHeader(Icons.security, 'Security & Warehouse', Colors.grey.shade700),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Seal By', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Break Seal By', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'WH Enter', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'WH Exit', border: OutlineInputBorder()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Direct Costing
            _buildSectionHeader(Icons.attach_money, 'Direct Costing', Colors.teal),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Driver Salary', prefixText: '₹ ', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Manpower Req', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(decoration: const InputDecoration(labelText: 'Manpower Amount', prefixText: '₹ ', border: OutlineInputBorder())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Proof of Delivery
            _buildSectionHeader(Icons.camera_alt, 'Proof of Delivery (POD)', Colors.indigo),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload, size: 48, color: Colors.indigo.shade300),
                      const SizedBox(height: 8),
                      const Text('Tap to Upload Photo/Signature', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Save RTI Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}
