/// 커스텀 위젯 및 유틸리티 라이브러리 (전체 버전)
///
/// 모든 커스텀 위젯과 유틸리티를 export합니다.
/// StorageUtil과 NetworkUtil을 포함한 모든 기능을 사용할 수 있습니다.
///
/// 주의: 이 파일을 사용하려면 pubspec.yaml에 다음 의존성이 필요합니다:
/// ```yaml
/// dependencies:
///   shared_preferences: ^2.2.2
///   http: ^1.1.0
/// ```
///
/// ⚠️ 중요: external_util 폴더를 삭제한 경우, 이 파일의 export 문도 제거해야 합니다.
/// (44번, 47번 줄의 export 문을 주석 처리하거나 삭제하세요)
///
/// 외부 패키지 의존성이 없는 경우 custom.dart를 사용하세요.
///
/// 사용 예시:
/// ```dart
/// import 'package:custom_test_app/custom/custom_full.dart';
///
/// // 위젯 사용
/// CustomText("안녕하세요")
/// CustomButton(btnText: "확인", onCallBack: () {})
///
/// // 모든 유틸리티 사용
/// CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd');
/// CustomStorageUtil.setString('key', 'value');  // shared_preferences 필요
/// CustomNetworkUtil.get('/api/users');  // http 패키지 필요
/// ```
///
/// 선택적 import:
/// - 기본 버전 (의존성 없음): `import 'package:custom_test_app/custom/custom.dart';`
/// - 위젯만 필요한 경우: `import 'package:custom_test_app/custom/widgets.dart';`
/// - 핵심 유틸리티만: `import 'package:custom_test_app/custom/utils_core.dart';`
/// - 스토리지 유틸리티만: `import 'package:custom_test_app/custom/external_util/storage/custom_storage_util.dart';`
/// - 네트워크 유틸리티만: `import 'package:custom_test_app/custom/external_util/network/custom_network_util.dart';`
library;

// 위젯 export
export 'widgets.dart';

// 핵심 유틸리티 export (외부 패키지 의존성 없음)
export 'utils_core.dart';

// 스토리지 유틸리티 export (shared_preferences 의존)
export 'external_util/storage/custom_storage_util.dart';

// 네트워크 유틸리티 export (http 패키지 의존)
export 'external_util/network/custom_network_util.dart';
