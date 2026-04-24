import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

mixin SettingsBodyActions {
  static const _appStoreUrl = 'https://apps.apple.com/'; // TODO: App Store ID

  void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.termsofservice),
        content: const SingleChildScrollView(
          child: Text(
            'Son güncelleme: Nisan 2026\n\n'
            '1. Kabul\n'
            'Shakr uygulamasını kullanarak aşağıdaki kullanım şartlarını kabul etmiş sayılırsınız. '
            'Bu şartları kabul etmiyorsanız uygulamayı kullanmayınız.\n\n'
            '2. Hizmet\n'
            'Shakr, kullanıcıların konum tabanlı shake (sallama) etkileşimi ile anonim olarak eşleşmesini sağlayan '
            'bir sosyal uygulamadır. Hizmetimiz yalnızca 18 yaş ve üzeri bireyler içindir.\n\n'
            '3. Kullanıcı Yükümlülükleri\n'
            'Kullanıcılar, uygulama üzerinden yanıltıcı, zararlı veya yasadışı içerik paylaşamaz. '
            'Diğer kullanıcılara yönelik taciz, hakaret veya tehdit içeren davranışlar yasaktır.\n\n'
            '4. Fikri Mülkiyet\n'
            'Uygulama içeriği, tasarımı ve markası Shakr\'a aittir. İzinsiz kopyalama ve dağıtım yasaktır.\n\n'
            '5. Sorumluluk Sınırı\n'
            'Shakr, kullanıcılar arasındaki etkileşimlerden doğan doğrudan veya dolaylı zararlardan sorumlu tutulamaz.\n\n'
            '6. Değişiklikler\n'
            'Bu şartlar önceden bildirim yapılmaksızın güncellenebilir. Güncel versiyona uygulama üzerinden ulaşabilirsiniz.\n\n'
            '7. İletişim\n'
            'Sorularınız için: destek@shakr.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.okay),
          ),
        ],
      ),
    );
  }

  void showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.privacypolicy),
        content: const SingleChildScrollView(
          child: Text(
            'Son güncelleme: Nisan 2026\n\n'
            '1. Toplanan Veriler\n'
            'Uygulamamız; kullanıcı adı, yaş, cinsiyet, fotoğraf ve konum bilgilerini toplar. '
            'Sohbet geçmişi ve eşleşme verileri de işlenmektedir.\n\n'
            '2. Verilerin Kullanımı\n'
            'Toplanan veriler yalnızca hizmetin sunulması, güvenliğin sağlanması ve kullanıcı deneyiminin '
            'iyileştirilmesi amacıyla kullanılır. Verileriniz üçüncü taraflarla satılmaz veya kiralanmaz.\n\n'
            '3. Konum Verisi\n'
            'Konum bilgisi yalnızca yakındaki kullanıcıları eşleştirmek amacıyla anlık olarak kullanılır. '
            'Kesin konum bilgisi hiçbir zaman diğer kullanıcılarla paylaşılmaz.\n\n'
            '4. Veri Güvenliği\n'
            'Verileriniz endüstri standardı şifreleme yöntemleriyle korunmaktadır. '
            'Firebase altyapısı kullanılmakta olup Google\'ın gizlilik politikaları geçerlidir.\n\n'
            '5. Veri Saklama\n'
            'Hesabınızı sildiğinizde tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.\n\n'
            '6. Haklarınız\n'
            'KVKK kapsamında verilerinize erişme, düzeltme ve silme hakkına sahipsiniz. '
            'Bu haklarınızı kullanmak için bizimle iletişime geçebilirsiniz.\n\n'
            '7. İletişim\n'
            'Gizlilik konularında: gizlilik@shakr.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.okay),
          ),
        ],
      ),
    );
  }

  Future<void> openAppStore() async {
    final uri = Uri.parse(_appStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          AppStrings.deleteAccount,
          style: TextStyle(color: AppColors.error),
        ),
        content: Column(
          mainAxisSize: .min,
          children: [
            Text(AppStrings.deleteAccountConfirm),
            SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondaryDark,
                    ),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<SettingsCubit>().deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text(
                      AppStrings.deleteAccountAction,
                      textAlign: .center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
