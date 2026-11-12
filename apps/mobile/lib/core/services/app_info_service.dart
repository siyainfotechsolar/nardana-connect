import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  AppInfoService._();
  static final AppInfoService instance = AppInfoService._();

  PackageInfo? _info;

  Future<void> initialize() async {
    try {
      _info = await PackageInfo.fromPlatform();
    } catch (_) {
      // Fallback
    }
  }

  Future<PackageInfo> getPackageInfo() async {
    if (_info != null) return _info!;
    try {
      _info = await PackageInfo.fromPlatform();
    } catch (_) {
      _info = PackageInfo(
        appName: 'NARDANA CONNECT',
        packageName: 'in.nardana.connect.nardana_connect',
        version: '1.0.3',
        buildNumber: '4',
        buildSignature: '',
      );
    }
    return _info!;
  }

  String get appName => _info?.appName.isNotEmpty == true ? _info!.appName : 'NARDANA CONNECT';
  String get version => _info?.version.isNotEmpty == true ? _info!.version : '1.0.3';
  String get buildNumber => _info?.buildNumber.isNotEmpty == true ? _info!.buildNumber : '4';
  String get packageName => _info?.packageName.isNotEmpty == true ? _info!.packageName : 'in.nardana.connect.nardana_connect';
  String get platform => 'Android';

  String get formattedVersion => 'Version $version';
  String get formattedBuild => 'Build $buildNumber';
  String get fullVersionString => 'Version $version (Build $buildNumber)';
}
