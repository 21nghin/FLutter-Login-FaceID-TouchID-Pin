import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const String keyPin = 'pin';

class AuthenticationService{
  /// Khởi tạo xác thực cục bộ
  /// và cung cấp dịch vụ này trên toàn cầu
  static final localAuth = LocalAuthentication();

  /// Tạo bộ lưu trữ
  /// nó cũng là 1 ví dụ tạo ra để có quyền truy cập vào bộ lưu trữ flutter
  final _storage = const FlutterSecureStorage();

  /// Tạo 1 số bộ điều khiển luồng và điều này cần phải boolean
  /// và theo dõi người dùng có trạng thái xác thực mới nhất
  /// và đùng quên rằng thực hiên chương trình phát broadcast này
  /// đảm bảo rằng chúng có thể đăng ký bất kỳ và bất kỳ nơi nào
  final StreamController<bool> _isEnableController = StreamController<bool>.broadcast();
  final StreamController<bool> _isNewUserController = StreamController<bool>.broadcast();

  /// Sau đó thực hiện các bộ định nghĩa
  StreamController<bool> get isEnableController => _isEnableController;
  StreamController<bool> get isNewUserController => _isNewUserController;

  ///  và trong trường hợp này sẽ đưa nó vào getter cho các bộ phát trực tiếp cho các luồng
  /// Và sẽ nhận các luồng, vì vậy đây là getter của bộ điều khiển là getter các luồng
  Stream<bool> get isEnabledStream => _isEnableController.stream;
  Stream<bool> get isNewUserStream => _isNewUserController.stream;

  /// Thực hiện 1 số phương pháp để sử lý bộ nhớ khi những gì đã đọc từ bộ lưu trữ
  Future<String> read(String key) async{
    ///đọc khóa từ bộ lưu trữ
    final val = await _storage.read(key: key);
    /// sẽ kiểm tra xem khóa có hợp lệ không và sau đó trả về
    /// nếu không, trả về một chuỗi trống
    return val != null ? jsonDecode(val): '';
  }

  /// nó sẽ xóa mọi thứ liên quan đến bộ nhớ
  Future<void> clearStorage() async{
    _storage.delete(key: keyPin);
  }

  /// gửi khóa và giá trị và cố gắng ghi vào bộ nhớ
  Future<void> write(String key, dynamic value) async{
    await _storage.write(key: key, value: jsonDecode(value));
  }

  ///sẽ được sử dụng là mã xác minh
  Future<void> verifyCode(String enteredCode) async{
    final pin = await read(keyPin);
    /// và đây là nơi chúng ta có thể kiểm tra xem mã pin mà chúng ta gửi
    /// có giống với những gì nó đã được lưu hay không,
    /// và có giống nhau không và chúng ta đã đăng ký bộ điều khiển luồng
    if(pin != null && pin == enteredCode){
      isNewUserController.add(false);
    }else{
      ///trong trường hợp không có thì chúng ta cố gắng
      ///viết cái này dưới dạng mã pin mới
      ///và chúng ta cũng thử  để thông báo cho người điều khiển về nó
      isEnableController.add(true);
      write(keyPin, enteredCode);
    }
    ///trong trường hợp không có thì chúng ta cố gắng viết cái này dưới dạng mã pin mới
    ///và chúng ta cũng thử  để thông báo cho người điều khiển về nó
    isEnableController.add(true);
  }

  /// và cuối cùng chúng ta cần đảm bảo rằng tất cả các bộ điều khiển đã được đóng,
  void dispose(){
    _isEnableController.close();
    _isNewUserController.close();
  }
}

///bản dịch vụ xác thực cần phải có sẵn trên toàn cầu để chúng ta có thể sử dụng nó ở mọi nơi.
///vì vậy chúng ta không cần phải tạo một cái mới trong mọi lớp học
final AuthenticationService authService = AuthenticationService();
final localAuth = AuthenticationService.localAuth;