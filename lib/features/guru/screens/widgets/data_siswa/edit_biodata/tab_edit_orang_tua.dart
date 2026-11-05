import 'package:flutter/material.dart';
import 'edit_biodata_fields.dart';

class TabEditOrangTua extends StatelessWidget {
  final TextEditingController namaAyahController;
  final TextEditingController pekerjaanAyahController;
  final TextEditingController namaIbuController;
  final TextEditingController pekerjaanIbuController;
  final TextEditingController namaWaliController;
  final TextEditingController pekerjaanWaliController;
  final TextEditingController noHpOrtuController;
  final TextEditingController noHpController;

  const TabEditOrangTua({
    super.key,
    required this.namaAyahController,
    required this.pekerjaanAyahController,
    required this.namaIbuController,
    required this.pekerjaanIbuController,
    required this.namaWaliController,
    required this.pekerjaanWaliController,
    required this.noHpOrtuController,
    required this.noHpController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EditFieldLabel('Nama Ayah Kandung'),
          EditTextField(
            controller: namaAyahController,
            hint: 'Nama Ayah...',
          ),

          const SizedBox(height: 10),

          const EditFieldLabel('Pekerjaan Ayah'),
          EditTextField(
            controller: pekerjaanAyahController,
            hint: 'Pekerjaan Ayah...',
          ),

          const SizedBox(height: 16),

          const EditFieldLabel('Nama Ibu Kandung'),
          EditTextField(
            controller: namaIbuController,
            hint: 'Nama Ibu...',
          ),

          const SizedBox(height: 10),

          const EditFieldLabel('Pekerjaan Ibu'),
          EditTextField(
            controller: pekerjaanIbuController,
            hint: 'Pekerjaan Ibu...',
          ),

          const SizedBox(height: 16),

          const EditFieldLabel('Nama Wali (Jika Ada)'),
          EditTextField(
            controller: namaWaliController,
            hint: 'Nama Wali...',
          ),

          const SizedBox(height: 10),

          const EditFieldLabel('Pekerjaan Wali'),
          EditTextField(
            controller: pekerjaanWaliController,
            hint: 'Pekerjaan Wali...',
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          const EditFieldLabel('Nomor HP / WhatsApp Orang Tua'),
          EditTextField(
            controller: noHpOrtuController,
            hint: '08xxxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 12),

          const EditFieldLabel('Nomor HP / WhatsApp Siswa'),
          EditTextField(
            controller: noHpController,
            hint: '08xxxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}
