import 'package:flutter/material.dart';

class GlassesInfoCard extends StatelessWidget {
  final String customerName;
  final String prescriptionDate;
  final String frameModel;
  final String lensType;
  final String estimatedReadyDate;
  final Map<String, dynamic>? prescription;

  const GlassesInfoCard({
    super.key,
    required this.customerName,
    required this.prescriptionDate,
    required this.frameModel,
    required this.lensType,
    required this.estimatedReadyDate,
    this.prescription,
  });

  Widget _buildPrescriptionColumn(String eye, Map<String, dynamic>? eyeData) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eye, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Sphere: ${eyeData?['sphere'] ?? 'N/A'}'),
          Text('Cylinder: ${eyeData?['cylinder'] ?? 'N/A'}'),
          Text('Axis: ${eyeData?['axis'] ?? 'N/A'}'),
          Text('Prism: ${eyeData?['prism'] ?? 'N/A'}'),
          Text('Add: ${eyeData?['add'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final od = prescription?['OD'] as Map<String, dynamic>?;
    final os = prescription?['OS'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Name: $customerName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Prescription Date: $prescriptionDate'),
            Text('Frame Model: $frameModel'),
            Text('Lens Type: $lensType'),
            Text('Estimated Ready Date: $estimatedReadyDate'),
            const Divider(height: 24, thickness: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrescriptionColumn('OD', od),
                const SizedBox(width: 32),
                _buildPrescriptionColumn('OS', os),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
