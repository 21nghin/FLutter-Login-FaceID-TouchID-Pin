# login_faceid_touchid_pin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Login FaceID và TouchID
 -> Chúng tôi có hộp thoại mặc định với nút 'OK' để hiển thị thông báo lỗi xác thực cho 2 trường hợp sau:
    1. Mật mã / PIN / Hình chưa được đặt. Người dùng chưa định cấu hình mật mã trên iOS hoặc mã PIN / hình mở khóa trên Android.
    2. ID cảm ứng / Vân tay chưa được đăng ký. Người dùng chưa đăng ký bất kỳ dấu vân tay nào trên thiết bị.

   giải thích :
              Có nghĩa là, nếu không có vân tay trên thiết bị của người dùng, một hộp thoại có hướng dẫn sẽ bật lên
               để người dùng thiết lập vân tay. Nếu người dùng nhấp vào nút 'OK', nó sẽ trả về 'false'.

 -> Sử dụng các API đã xuất để kích hoạt xác thực cục bộ với các hộp thoại mặc định:
 -> Phương thức authenticate () sử dụng xác thực sinh trắc học, nhưng cũng cho phép người dùng sử dụng mã pin, mẫu hoặc mật mã.
 -> Bạn có thể sử dụng thông báo hộp thoại mặc định của chúng tôi hoặc bạn có thể sử
    dụng tin nhắn của riêng mình bằng cách chuyển vào IOSAuthMessages và AndroidAuthMessages:
 -> Nếu cần, bạn có thể dừng xác thực theo cách thủ công cho android:
 -> Có 6 loại ngoại lệ: PasscodeNotSet, NotEnrolled, NotAvailable, OtherOperatingSystem, LockedOut và PermanentlyLockedOut.
    Chúng được bao bọc trong lớp LocalAuthenticationError.
     Bạn có thể bắt ngoại lệ và xử lý chúng theo các kiểu khác nhau.
 -> Lưu ý rằng plugin này hoạt động với cả Touch ID và Face ID. Tuy nhiên, để sử dụng cái sau, bạn cũng cần thêm:
    => config trên IOS:
        <key>NSFaceIDUsageDescription</key>
        <string>Why is my app authenticating using face id?</string>
        -> vào tệp Info.plist của bạn.
         Không làm như vậy dẫn đến hộp thoại cho người dùng biết ứng dụng của bạn chưa được cập nhật để sử dụng Face ID.
    => config Android:
    -> Lưu ý: Lưu ý rằng plugin local_auth yêu cầu sử dụng FragmentActivity thay vì Activity
       Điều này có thể dễ dàng thực hiện bằng cách chuyển sang sử dụng FlutterFragmentActivity như trái ngược với
       FlutterActivity trong tệp kê khai của bạn (hoặc lớp Hoạt động của riêng bạn nếu bạn đang mở rộng lớp cơ sở).
       1. Cập nhật của bạn MainActivity.java:
            import android.os.Bundle;
            import io.flutter.app.FlutterFragmentActivity;
            import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
            import io.flutter.plugins.localauth.LocalAuthPlugin;

            public class MainActivity extends FlutterFragmentActivity {
                @Override
                protected void onCreate(Bundle savedInstanceState) {
                    super.onCreate(savedInstanceState);
                    FlutterAndroidLifecyclePlugin.registerWith(
                            registrarFor(
                                    "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
                    LocalAuthPlugin.registerWith(registrarFor("io.flutter.plugins.localauth.LocalAuthPlugin"));
                }
            }
       2. Cập nhật MainActivity.kt của bạn:
            import io.flutter.embedding.android.FlutterFragmentActivity
            import io.flutter.embedding.engine.FlutterEngine
            import io.flutter.plugins.GeneratedPluginRegistrant

            class MainActivity: FlutterFragmentActivity() {
                override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
                    GeneratedPluginRegistrant.registerWith(flutterEngine)
                }
            }
   -> Cập nhật tệp AndroidManifest.xml trong dự án của bạn để bao gồm các quyền USE_FINGERPRINT như sau:
          <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
       LƯU Ý:
              1. Trên Android, bạn chỉ có thể kiểm tra sự tồn tại của phần cứng vân tay trước API 29 (Android Q).
                 Do đó, nếu bạn muốn hỗ trợ các loại sinh trắc học khác (chẳng hạn như quét khuôn mặt) và
                 bạn muốn hỗ trợ các SDK thấp hơn Q, không gọi getAvailableBiometrics. Đơn giản chỉ cần gọi xác thực với
                 biometricOnly: true. Điều này sẽ trả về một lỗi nếu không có sẵn phần cứng.
              2. Bạn có thể đặt tùy chọn stickAuth trên plugin thành true để plugin không trả về lỗi nếu hệ thống đặt ứng dụng ở chế độ nền
                 Điều này có thể xảy ra nếu người dùng nhận được cuộc gọi điện thoại trước khi họ có cơ hội xác thực.
                 Với stickAuth được đặt thành false, điều này sẽ dẫn đến việc plugin trả về kết quả không thành công cho ứng dụng Dart.
                 Nếu được đặt thành true, plugin sẽ thử xác thực lại khi ứng dụng tiếp tục.
