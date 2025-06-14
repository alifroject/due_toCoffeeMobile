import 'package:flutter/material.dart';

class EducationalContents extends StatelessWidget {
  final String language;
  const EducationalContents({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, String>> translations = {
      'English': {
        'title': "Educational Contents",
        'dailyHabits': "🗓️ Daily & Weekly Habits:\n"
            "Track your waste to spot patterns.\n"
            "Plan meals, use shopping lists.\n"
            "Control portions to avoid cooking too much.\n"
            "Shop small amounts to keep food fresh.",
        'storage': "🧠 Smart Storage & Shopping:\n"
            "Use FIFO (First-In, First-Out) system.\n"
            "Store food properly with airtight containers.\n"
            "Avoid buying perishables in bulk.\n"
            "Freeze extras for future use.",
        'takeout': "🍽️ Takeout & Dining Out:\n"
            "Order smaller portions or share.\n"
            "Request takeaway boxes for leftovers.\n"
            "Eat a snack before dining out.\n"
            "Avoid over-ordering when hungry.",
        'repurpose': "💡 Repurpose Leftovers & Scraps:\n"
            "Turn leftovers into soups or stir-fries.\n"
            "Save scraps for broths or croutons.\n"
            "Freeze extra meals for later.\n"
            "Practice zero-waste cooking.",
      },
      'Indonesia': {
        'title': "Konten Edukasi",
        'dailyHabits': "🗓️ Kebiasaan Harian & Mingguan:\n"
            "Catat sampah makanan untuk lihat polanya.\n"
            "Rencanakan menu & buat daftar belanja.\n"
            "Kontrol porsi agar tidak memasak berlebihan.\n"
            "Belanja secukupnya agar tetap segar.",
        'storage': "🧠 Penyimpanan & Belanja Cerdas:\n"
            "Gunakan sistem FIFO (masuk pertama keluar pertama).\n"
            "Simpan makanan dalam wadah kedap udara.\n"
            "Hindari beli makanan mudah busuk secara berlebihan.\n"
            "Bekukan makanan sisa untuk digunakan nanti.",
        'takeout': "🍽️ Makan di Luar & Bawa Pulang:\n"
            "Pesan porsi kecil atau berbagi.\n"
            "Minta kotak makanan untuk sisa.\n"
            "Makan camilan sebelum keluar.\n"
            "Hindari memesan berlebihan saat lapar.",
        'repurpose': "💡 Gunakan Ulang Sisa Makanan:\n"
            "Buat sup atau tumisan dari sisa makanan.\n"
            "Gunakan sisa kulit sayur untuk kaldu.\n"
            "Bekukan makanan tambahan untuk nanti.\n"
            "Masak tanpa limbah sebisa mungkin.",
      }
    };

    final trans = translations[language]!;

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trans['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(trans['dailyHabits']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(trans['storage']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(trans['takeout']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(trans['repurpose']!, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
