import 'package:flutter/material.dart';

class AppVibes {
  AppVibes._();

  static const Map<String, Map<String, dynamic>> categories = {
    'Kultur': {
      'icon': Icons.book,
      'color': Colors.deepPurple,
      'vibes': [
        {'label': 'kitap', 'icon': Icons.menu_book},
        {'label': 'muzik', 'icon': Icons.music_note},
        {'label': 'sanat', 'icon': Icons.palette},
        {'label': 'sinema', 'icon': Icons.movie},
        {'label': 'tiyatro', 'icon': Icons.theater_comedy},
      ],
    },
    'Yasam': {
      'icon': Icons.favorite,
      'color': Colors.green,
      'vibes': [
        {'label': 'kahve', 'icon': Icons.coffee},
        {'label': 'yemek', 'icon': Icons.restaurant},
        {'label': 'spor', 'icon': Icons.sports_basketball},
        {'label': 'doga', 'icon': Icons.park},
        {'label': 'seyahat', 'icon': Icons.flight},
      ],
    },
    'Teknoloji': {
      'icon': Icons.computer,
      'color': Colors.blue,
      'vibes': [
        {'label': 'kod', 'icon': Icons.code},
        {'label': 'oyun', 'icon': Icons.sports_esports},
        {'label': 'podcast', 'icon': Icons.podcasts},
        {'label': 'tasarim', 'icon': Icons.design_services},
      ],
    },
    'Sosyal': {
      'icon': Icons.people,
      'color': Colors.orange,
      'vibes': [
        {'label': 'parti', 'icon': Icons.celebration},
        {'label': 'konser', 'icon': Icons.queue_music},
        {'label': 'etkinlik', 'icon': Icons.event},
        {'label': 'kafe', 'icon': Icons.local_cafe},
      ],
    },
  };
}
