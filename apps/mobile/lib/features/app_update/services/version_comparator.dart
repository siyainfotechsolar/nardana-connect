/// Semantic Version Comparator for Nardana Connect
/// Compares versions numerically by major.minor.patch and build number, NOT lexicographically.
class VersionComparator {
  /// Parses a semantic version string (e.g. "1.0.0", "1.2.3+4", "v2.1") into [major, minor, patch]
  static List<int> parseVersionParts(String version) {
    var clean = version.trim().toLowerCase();
    if (clean.startsWith('v')) {
      clean = clean.substring(1);
    }
    // Remove any build number or pre-release tags after + or -
    final plusIndex = clean.indexOf('+');
    if (plusIndex != -1) {
      clean = clean.substring(0, plusIndex);
    }
    final dashIndex = clean.indexOf('-');
    if (dashIndex != -1) {
      clean = clean.substring(0, dashIndex);
    }

    final parts = clean.split('.');
    final int major = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0;
    final int minor = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final int patch = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;

    return [major, minor, patch];
  }

  /// Compares [v1] and [v2].
  /// Returns < 0 if v1 < v2
  /// Returns 0 if v1 == v2
  /// Returns > 0 if v1 > v2
  static int compareVersions(String v1, String v2) {
    final p1 = parseVersionParts(v1);
    final p2 = parseVersionParts(v2);

    for (int i = 0; i < 3; i++) {
      if (p1[i] < p2[i]) return -1;
      if (p1[i] > p2[i]) return 1;
    }
    return 0;
  }

  /// Checks if [installedVersion] and [installedBuild] are strictly below [minVersion] and [minBuild].
  static bool isBelowMinimum({
    required String installedVersion,
    required int installedBuild,
    required String minVersion,
    required int minBuild,
  }) {
    final cmp = compareVersions(installedVersion, minVersion);
    if (cmp < 0) return true;
    if (cmp > 0) return false;
    // Same major.minor.patch, compare build number
    return installedBuild < minBuild;
  }

  /// Checks if [latestVersion] and [latestBuild] is newer than [installedVersion] and [installedBuild].
  static bool isNewerAvailable({
    required String installedVersion,
    required int installedBuild,
    required String latestVersion,
    required int latestBuild,
  }) {
    final cmp = compareVersions(installedVersion, latestVersion);
    if (cmp < 0) return true;
    if (cmp > 0) return false;
    // Same major.minor.patch, check if latest build is higher
    return latestBuild > installedBuild;
  }
}
