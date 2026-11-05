import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_biodata_fields.dart';

class TabEditIdentitas extends StatelessWidget {
  final String? currentFotoUrl;
  final bool isUploadingFoto;
  final VoidCallback onPickAndUploadPhoto;
  final TextEditingController namaController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final String religion;
  final List<String> religionOptions;
  final ValueChanged<String> onReligionChanged;
  final TextEditingController birthPlaceController;
  final TextEditingController birthDateController;
  final VoidCallback onSelectBirthDate;
  final TextEditingController addressController;

  const TabEditIdentitas({
    super.key,
    required this.currentFotoUrl,
    required this.isUploadingFoto,
    required this.onPickAndUploadPhoto,
    required this.namaController,
    required this.gender,
    required this.onGenderChanged,
    required this.religion,
    required this.religionOptions,
    required this.onReligionChanged,
    required this.birthPlaceController,
    required this.birthDateController,
    required this.onSelectBirthDate,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Profil Siswa Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: isUploadingFoto
                            ? const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : (currentFotoUrl != null && currentFotoUrl!.isNotEmpty)
                                ? Image.network(
                                    currentFotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.blue,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: onPickAndUploadPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: onPickAndUploadPhoto,
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: Text(
                    'Ganti Foto Siswa',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nama Siswa
          const EditFieldLabel('Nama Lengkap Siswa *'),
          EditTextField(
            controller: namaController,
            hint: 'Nama lengkap...',
          ),

          const SizedBox(height: 14),

          // Jenis Kelamin
          const EditFieldLabel('Jenis Kelamin *'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Laki-laki', style: TextStyle(fontSize: 13)),
                  value: 'L',
                  groupValue: gender,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) onGenderChanged(val);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Perempuan', style: TextStyle(fontSize: 13)),
                  value: 'P',
                  groupValue: gender,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) onGenderChanged(val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Agama
          const EditFieldLabel('Agama *'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: religion,
                isExpanded: true,
                items: religionOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  if (val != null) onReligionChanged(val);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Tempat & Tanggal Lahir
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Tempat Lahir'),
                    EditTextField(
                      controller: birthPlaceController,
                      hint: 'Kota kelahiran...',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditFieldLabel('Tanggal Lahir'),
                    TextField(
                      controller: birthDateController,
                      readOnly: true,
                      onTap: onSelectBirthDate,
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
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
            ],
          ),

          const SizedBox(height: 14),

          // Alamat
          const EditFieldLabel('Alamat Tempat Tinggal'),
          EditTextField(
            controller: addressController,
            hint: 'Dusun, Desa, RT/RW, Kecamatan...',
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
