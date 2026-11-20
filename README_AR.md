# Amir Girgis Music — مشروع جديد من الصفر

تطبيق Android مبني باستخدام Flutter، بواجهة سوداء وذهبية، ويحتوي على ملفات MP3 التي أرسلتها في هذه المحادثة.

## محتويات النسخة الحالية
- واجهة رئيسية باسم Amir Girgis.
- قائمة تضم 10 ملفات صوت محلية تعمل دون إنترنت.
- بحث داخل قائمة الأغاني.
- مشغل صوت مع تقدم ووقت التشغيل.
- دعم إشعارات/تشغيل الصوت في الخلفية عبر `just_audio_background`.

## المتطلبات
- Flutter SDK حديث (Dart 3.4 أو أحدث).
- Android Studio مع Android SDK.
- اتصال إنترنت أول مرة لتحميل حزم Flutter.

## بناء مشروع Android لأول مرة
افتح Terminal داخل مجلد المشروع ونفّذ:

```bash
flutter create --platforms=android --org com.amir.girgis .
```

ثم استبدل محتوى `android/app/src/main/AndroidManifest.xml` بالنموذج الموجود في `android_manifest_template.xml`، ثم:

```bash
flutter pub get
flutter run
```

لإنشاء APK:

```bash
flutter build apk --release
```

المسار المتوقع:
`build/app/outputs/flutter-apk/app-release.apk`

## إضافة أغنية جديدة
1. انسخ ملف MP3 إلى `assets/audio/`.
2. أضف Track جديداً داخل قائمة `tracks` في `lib/main.dart` مع عنوانه ومسار الملف.
3. نفّذ `flutter pub get` ثم أعد بناء APK.

## دعم البث عبر الإنترنت
المشغل يدعم الأغاني المحلية وروابط البث المباشر. لإضافة أغنية أونلاين، أضف عنصراً جديداً إلى قائمة `tracks` في `lib/main.dart` بهذا الشكل:

```dart
Track(
  title: 'اسم الأغنية',
  streamUrl: 'https://your-domain.com/audio/song.mp3',
),
```

اترك `asset` غير محدد للأغنية المتدفقة. يجب أن يكون الرابط مباشراً ويعمل عبر HTTPS، وأن يسمح بالوصول العام. لا تضع كلمات مرور أو روابط خاصة داخل التطبيق.

## ملاحظة
هذا ملف مصدر Flutter جاهز للبناء، وليس APK مبنياً. يجب تنفيذ أوامر البناء على جهاز مثبت عليه Flutter وAndroid SDK.


## غلاف الألبوم
تم إضافة الصورة التي أرسلتها كغلاف رئيسي في الصفحة الرئيسية داخل `assets/images/album_cover.png`. لتغيير الغلاف لاحقاً، استبدل هذا الملف مع الاحتفاظ بالاسم نفسه ثم أعد بناء التطبيق.

تمت إضافة الصورة الثانية التي أرسلها المستخدم كصورة مصغرة موحدة للأغاني داخل قائمة التشغيل: `assets/images/songs_artwork.png`.

## أيقونة التطبيق من صورتك
تم تجهيز صورتك كأيقونة مربعة سوداء بإطار ذهبي مع الحفاظ على ظهور الصورة كاملة قدر الإمكان.
بعد إنشاء مجلد Android عبر `flutter create` نفّذ:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

سيتم توليد أيقونات Android من `assets/images/app_icon.png`.


## أسهل طريقة لبناء APK على Windows
1. ثبّت Flutter SDK وAndroid Studio، وتأكد أن أمر `flutter doctor` يعمل.
2. فك ضغط المشروع كاملاً في مجلد عادي على الكمبيوتر.
3. افتح مجلد المشروع وشغّل `BUILD_APK_WINDOWS.bat`.
4. انتظر انتهاء البناء؛ سيُفتح مجلد ملف APK تلقائياً.

المسار النهائي:
`build/app/outputs/flutter-apk/app-release.apk`

إذا توقف البناء، انسخ رسالة الخطأ كاملة وأرسلها للمساعدة في إصلاحها.
