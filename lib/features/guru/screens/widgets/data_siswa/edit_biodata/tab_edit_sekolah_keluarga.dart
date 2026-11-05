import 'package:flutter/material.dart';
import 'edit_biodata_fields.dart';

class TabEditSekolahKeluarga extends StatelessWidget {
  final TextEditingController previousSchoolController;
  final TextEditingController admissionDateController;
  final VoidCallback onSelectAdmissionDate;
  final TextEditingController admissionClassController;
  final TextEditingController familyStatusController;
  final TextEditingController childOrderController;

  const TabEditSekolahKeluarga({
    super.key,
    required this.previousSchoolController,
    required this.admissionDateController,
    required this.onSelectAdmissionDate,
    required this.admissionClassController,
    required this.familyStatusController,
    required this.childOrderController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EditFieldLabel('Sekolah Asal (SD / MI)'),
          EditTextField(
            controller: previousSchoolController,
            hint: 'Contoh: SDN 1 / Asal SD',
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Tanggal Masuk'),
                    TextField(
                      controller: admissionDateController,
                      readOnly: true,
                      onTap: onSelectAdmissionDate,
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        suffixIcon: const Icon(Icons.calendar_month, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Diterima di Kelas'),
                    EditTextField(
                      controller: admissionClassController,
                      hint: 'Contoh: 7A',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Status dalam Keluarga'),
                    EditTextField(
                      controller: familyStatusController,
                      hint: 'Anak Kandung/Tiri...',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Anak Ke-'),
                    EditTextField(
                      controller: childOrderController,
                      hint: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
