import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/theme/app_colors.dart';

class AppVibes {
  AppVibes._();

  static Color colorForVibe(String label) {
    for (final cat in categories.values) {
      for (final v in cat['vibes'] as List) {
        if (v['label'] == label) return cat['color'] as Color;
      }
    }
    return AppColors.primary;
  }

  static const Map<String, Map<String, dynamic>> categories = {
    'Kültür': {
      'icon': LucideIcons.bookOpen,
      'color': AppColors.primary,
      'vibes': [
        {'label': 'kitap', 'icon': LucideIcons.bookOpen},
        {'label': 'muzik', 'icon': LucideIcons.music},
        {'label': 'sanat', 'icon': LucideIcons.palette},
        {'label': 'sinema', 'icon': LucideIcons.clapperboard},
        {'label': 'tiyatro', 'icon': LucideIcons.drama},
      ],
    },
    'Yaşam': {
      'icon': LucideIcons.heart,
      'color': Color(0xFF10B981),
      'vibes': [
        {'label': 'kahve', 'icon': LucideIcons.coffee},
        {'label': 'yemek', 'icon': LucideIcons.utensils},
        {'label': 'spor', 'icon': LucideIcons.dumbbell},
        {'label': 'doga', 'icon': LucideIcons.treeDeciduous},
        {'label': 'seyahat', 'icon': LucideIcons.plane},
      ],
    },
    'Teknoloji': {
      'icon': LucideIcons.laptop,
      'color': Color(0xFF3B82F6),
      'vibes': [
        {'label': 'kod', 'icon': LucideIcons.code},
        {'label': 'oyun', 'icon': LucideIcons.gamepad2},
        {'label': 'podcast', 'icon': LucideIcons.mic},
        {'label': 'tasarim', 'icon': LucideIcons.penTool},
      ],
    },
    'Sosyal': {
      'icon': LucideIcons.users,
      'color': Color(0xFFF59E0B),
      'vibes': [
        {'label': 'parti', 'icon': LucideIcons.partyPopper},
        {'label': 'konser', 'icon': LucideIcons.headphones},
        {'label': 'etkinlik', 'icon': LucideIcons.calendarDays},
        {'label': 'kafe', 'icon': LucideIcons.cupSoda},
      ],
    },
  };
}
