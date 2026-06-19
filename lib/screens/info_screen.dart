import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zatürre Hakkında', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppTheme.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zatürre belirtileri, risk faktörleri ve korunma yolları hakkında temel bilgiler.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : AppTheme.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Hero Bilgi Kartı
            _buildHeroCard(isDark),
            const SizedBox(height: 24),

            // Nedir Kartı
            _buildInfoCard(
              title: 'Zatürre (Pnömoni) Nedir?',
              icon: Icons.coronavirus_outlined,
              iconColor: AppTheme.primaryColor,
              isDark: isDark,
              content: const Text(
                'Zatürre, akciğerlerdeki hava keseciklerinin iltihaplanmasıyla ortaya çıkan bir enfeksiyondur. Bakteri, virüs veya mantar kaynaklı olabilir. Erken tanı ve uygun tedavi önemlidir.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Belirtiler Kartı
            _buildInfoCard(
              title: 'Belirtiler',
              icon: Icons.sick_outlined,
              iconColor: AppTheme.secondaryColor,
              isDark: isDark,
              content: Column(
                children: [
                  _buildIconBulletPoint('Yüksek ateş ve titreme', Icons.thermostat_outlined, AppTheme.secondaryColor, isDark),
                  _buildIconBulletPoint('Öksürük', Icons.masks_outlined, AppTheme.secondaryColor, isDark),
                  _buildIconBulletPoint('Nefes darlığı', Icons.air_outlined, AppTheme.secondaryColor, isDark),
                  _buildIconBulletPoint('Göğüs ağrısı', Icons.favorite_border_outlined, AppTheme.secondaryColor, isDark),
                  _buildIconBulletPoint('Halsizlik ve yorgunluk', Icons.battery_alert_outlined, AppTheme.secondaryColor, isDark),
                  _buildIconBulletPoint('Balgam', Icons.water_drop_outlined, AppTheme.secondaryColor, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Risk Faktörleri Kartı
            _buildInfoCard(
              title: 'Risk Faktörleri',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFF59E0B),
              isDark: isDark,
              content: Column(
                children: [
                  _buildIconBulletPoint('İleri yaş', Icons.elderly_outlined, const Color(0xFFF59E0B), isDark),
                  _buildIconBulletPoint('Bağışıklık sisteminin zayıf olması', Icons.shield_outlined, const Color(0xFFF59E0B), isDark),
                  _buildIconBulletPoint('Sigara kullanımı', Icons.smoking_rooms_outlined, const Color(0xFFF59E0B), isDark),
                  _buildIconBulletPoint('Kronik hastalıklar', Icons.medical_services_outlined, const Color(0xFFF59E0B), isDark),
                  _buildIconBulletPoint('Uzun süreli yatak istirahati', Icons.bed_outlined, const Color(0xFFF59E0B), isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Doktora Başvurma Kartı (Uyarı Tasarımı)
            _buildWarningCard(isDark),
            const SizedBox(height: 24),

            // Korunma Yolları Kartı
            _buildInfoCard(
              title: 'Korunma Yolları',
              icon: Icons.health_and_safety_outlined,
              iconColor: Colors.green,
              isDark: isDark,
              content: Column(
                children: [
                  _buildIconBulletPoint('Elleri düzenli yıkamak', Icons.clean_hands_outlined, Colors.green, isDark),
                  _buildIconBulletPoint('Sigara dumanından uzak durmak', Icons.smoke_free_outlined, Colors.green, isDark),
                  _buildIconBulletPoint('Bağışıklığı güçlü tutmak', Icons.fitness_center_outlined, Colors.green, isDark),
                  _buildIconBulletPoint('Kalabalık ortamlarda dikkatli olmak', Icons.groups_outlined, Colors.green, isDark),
                  _buildIconBulletPoint('Doktor önerilerine uymak', Icons.medical_information_outlined, Colors.green, isDark),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Alt Uyarı Kutusu
            _buildFooterWarning(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Zatürre Hakkında Bilinçlenin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Erken farkındalık, doğru zamanda doktora başvurmak için önemlidir.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.healing_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : AppTheme.textLight,
            ),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(bool isDark) {
    const dangerColor = Color(0xFFEF4444);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(isDark ? 0.2 : 0.05),
        border: Border.all(color: dangerColor.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services_rounded, color: dangerColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ne Zaman Doktora Başvurmalı?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIconBulletPoint('Nefes darlığı artarsa', Icons.priority_high_rounded, dangerColor, isDark),
          _buildIconBulletPoint('Göğüs ağrısı varsa', Icons.priority_high_rounded, dangerColor, isDark),
          _buildIconBulletPoint('Yüksek ateş düşmüyorsa', Icons.priority_high_rounded, dangerColor, isDark),
          _buildIconBulletPoint('Dudaklarda morarma görülürse', Icons.priority_high_rounded, dangerColor, isDark),
          _buildIconBulletPoint('Genel durum hızla kötüleşirse', Icons.priority_high_rounded, dangerColor, isDark),
        ],
      ),
    );
  }

  Widget _buildIconBulletPoint(String text, IconData icon, Color iconColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 20, color: iconColor.withOpacity(0.8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white70 : AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterWarning(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.textLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu uygulama yalnızca yapay zeka destekli ön değerlendirme amacı taşır. Kesin tanı ve tedavi için mutlaka bir sağlık uzmanına başvurulmalıdır.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
