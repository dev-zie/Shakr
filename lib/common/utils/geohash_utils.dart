class GeoHashUtils {
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  static String encode(double lat, double lng, {int precision = 7}) {
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;

    var hash = '';
    var bits = 0;
    var hashValue = 0;
    var isLng = true;

    while (hash.length < precision) {
      final double mid;
      if (isLng) {
        mid = (minLng + maxLng) / 2;
        if (lng >= mid) {
          hashValue = (hashValue << 1) | 1;
          minLng = mid;
        } else {
          hashValue = hashValue << 1;
          maxLng = mid;
        }
      } else {
        mid = (minLat + maxLat) / 2;
        if (lat >= mid) {
          hashValue = (hashValue << 1) | 1;
          minLat = mid;
        } else {
          hashValue = hashValue << 1;
          maxLat = mid;
        }
      }

      isLng = !isLng;
      bits++;

      if (bits == 5) {
        hash += _base32[hashValue];
        bits = 0;
        hashValue = 0;
      }
    }
    return hash;
  }
}
