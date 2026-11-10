import 'package:flutter_test/flutter_test.dart';
import 'package:nardana_connect/features/app_update/services/version_comparator.dart';

void main() {
  group('VersionComparator Tests', () {
    test('compareVersions accurately compares major versions', () {
      expect(VersionComparator.compareVersions('1.0.0', '2.0.0'), lessThan(0));
      expect(VersionComparator.compareVersions('2.0.0', '1.0.0'), greaterThan(0));
      expect(VersionComparator.compareVersions('1.0.0', '1.0.0'), equals(0));
    });

    test('compareVersions accurately compares minor and patch', () {
      expect(VersionComparator.compareVersions('1.0.0', '1.1.0'), lessThan(0));
      expect(VersionComparator.compareVersions('1.2.3', '1.2.4'), lessThan(0));
      expect(VersionComparator.compareVersions('1.10.0', '1.9.0'), greaterThan(0)); // string comparison would fail here!
      expect(VersionComparator.compareVersions('2.0.1', '2.0.1+5'), equals(0));
      expect(VersionComparator.compareVersions('v1.0.0', '1.0.0'), equals(0));
    });

    test('isBelowMinimum handles build numbers when version matches', () {
      expect(
        VersionComparator.isBelowMinimum(
          installedVersion: '1.0.0',
          installedBuild: 1,
          minVersion: '1.0.0',
          minBuild: 2,
        ),
        isTrue,
      );

      expect(
        VersionComparator.isBelowMinimum(
          installedVersion: '1.0.0',
          installedBuild: 2,
          minVersion: '1.0.0',
          minBuild: 2,
        ),
        isFalse,
      );

      expect(
        VersionComparator.isBelowMinimum(
          installedVersion: '0.9.9',
          installedBuild: 99,
          minVersion: '1.0.0',
          minBuild: 1,
        ),
        isTrue,
      );
    });

    test('isNewerAvailable works properly', () {
      expect(
        VersionComparator.isNewerAvailable(
          installedVersion: '1.0.0',
          installedBuild: 1,
          latestVersion: '1.0.1',
          latestBuild: 2,
        ),
        isTrue,
      );

      expect(
        VersionComparator.isNewerAvailable(
          installedVersion: '1.0.0',
          installedBuild: 1,
          latestVersion: '1.0.0',
          latestBuild: 1,
        ),
        isFalse,
      );
    });
  });
}
