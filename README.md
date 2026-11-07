# SRA — تطبيق Flutter (Android + Windows + Web)

هذا تطبيق Flutter كامل لواجهة SRA، يعمل على **Android, Windows, و Web**
من كود واحد، ويتصل بـ SRA Backend (الموجود في مجلد `backend/`).

---

## 0. ما هو موجود هنا الآن

تم تجهيز **كود التطبيق الكامل (Dart)** في مجلد `lib/`:

```
flutter_app/
├── lib/
│   ├── main.dart              # نقطة الدخول
│   ├── theme.dart              # نظام الألوان (داكن + كهرماني، مطابق للويب)
│   ├── models/                 # نماذج البيانات (محادثة، رسالة، ذاكرة، ملف)
│   ├── services/
│   │   ├── api_service.dart    # الاتصال بـ Backend
│   │   └── settings_service.dart # حفظ عنوان الخادم على الجهاز
│   ├── screens/
│   │   ├── home_screen.dart    # شاشة رئيسية تتكيف (Rail للديسكتوب / Bottom Bar للموبايل)
│   │   ├── chat_screen.dart    # المحادثة + إدارة المحادثات
│   │   ├── memory_screen.dart  # الذاكرة طويلة المدى
│   │   ├── files_screen.dart   # الملفات والمكتبة
│   │   └── settings_screen.dart # ضبط عنوان الخادم
│   └── widgets/
│       └── chat_bubble.dart
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

**ما هو غير موجود بعد**: مجلدات `android/`, `windows/`, `web/` (الخاصة
بكل منصة). هذه المجلدات تحتوي على إعدادات بناء (Gradle, CMake, إلخ)
**يجب أن تُولَّد تلقائياً بواسطة أداة Flutter نفسها** على جهازك،
لأنها تعتمد بدقة على إصدار Flutter/Android SDK المثبت لديك — توليدها
يدوياً قد ينتج ملفات غير متوافقة مع جهازك. الخطوة 2 أدناه تولّدها
في ثوانٍ.

---

## 1. المتطلبات

| المنصة | المتطلبات |
|---|---|
| عام | [Flutter SDK](https://docs.flutter.dev/get-started/install) (أحدث إصدار مستقر) |
| Android | Android Studio + Android SDK (لتشغيل `flutter build apk`) |
| Windows | Visual Studio 2022 مع "Desktop development with C++" (لتشغيل `flutter build windows`) |
| Web | لا يحتاج شيئاً إضافياً (يستخدم Chrome للتجربة) |

تحقق من جاهزية بيئتك:

```bash
flutter doctor
```

---

## 2. إعداد المشروع لأول مرة

من داخل مجلد `flutter_app`:

```bash
# 1) جلب الحزم (http, shared_preferences, file_picker, intl...)
flutter pub get

# 2) توليد مجلدات المنصات (Android, Windows, Web) المناسبة لجهازك
flutter create --platforms=android,windows,web .
```

الأمر الثاني **لن يحذف أي كود من lib/** — فقط يضيف المجلدات الناقصة
(`android/`, `windows/`, `web/`) مع الإعدادات الافتراضية الصحيحة.

### تفعيل الاتصال بخادم محلي على Android (HTTP بدون SSL)

بعد توليد مجلد `android/`، افتح:
`android/app/src/main/AndroidManifest.xml`

وأضف الخاصية `android:usesCleartextTraffic="true"` إلى عنصر
`<application>` (مهم لأن SRA Backend يعمل عبر `http://` بدون شهادة
SSL في مرحلة التطوير/الشبكة المنزلية):

```xml
<application
    android:label="SRA"
    android:usesCleartextTraffic="true"
    ... >
```

> عند نشر نسخة إنتاجية حقيقية على الإنترنت، يُفضّل تشغيل الـ Backend
> خلف HTTPS (مثلاً عبر Caddy أو Nginx + شهادة Let's Encrypt) وحذف هذه
> الخاصية.

---

## 3. تشغيل الـ Backend أولاً

تطبيق Flutter هو "واجهة" فقط — يحتاج SRA Backend (FastAPI) ليكون
يعمل أولاً. من مجلد `backend/` (راجع `README.md` الرئيسي للتفاصيل):

```bash
cd ../backend
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> لاحظ استخدام `--host 0.0.0.0` بدل `127.0.0.1` — هذا ضروري ليتمكن
> جهاز Android (أو أي جهاز آخر على الشبكة) من الوصول إلى الخادم.

---

## 4. ضبط عنوان الخادم في التطبيق

عند أول تشغيل، افتح **الإعدادات (⚙)** من شريط التطبيق العلوي، وأدخل
عنوان الخادم المناسب:

| الحالة | العنوان |
|---|---|
| محاكي Android + الخادم على نفس الكمبيوتر | `http://10.0.2.2:8000` |
| جهاز Android حقيقي على نفس شبكة Wi-Fi | `http://<IP الكمبيوتر>:8000` (مثال: `http://192.168.1.50:8000`) |
| تطبيق Windows والخادم على نفس الكمبيوتر | `http://localhost:8000` |
| تطبيق Web والخادم على نفس الكمبيوتر | `http://localhost:8000` |

لمعرفة IP الكمبيوتر على الشبكة:
- Windows: `ipconfig` (سطر "IPv4 Address")
- macOS/Linux: `ifconfig` أو `ip addr`

الإعداد يُحفظ على الجهاز (`shared_preferences`) ولا يحتاج إعادة كل مرة.

---

## 5. التشغيل أثناء التطوير

```bash
# عرض الأجهزة المتاحة (محاكي Android، Windows Desktop، Chrome...)
flutter devices

# التشغيل على جهاز/محاكي Android
flutter run -d emulator-5554

# التشغيل على Windows Desktop
flutter run -d windows

# التشغيل على المتصفح (Chrome)
flutter run -d chrome
```

---

## 6. البناء لنسخة إنتاجية

### Android (APK)

```bash
flutter build apk --release
```

الناتج: `build/app/outputs/flutter-apk/app-release.apk`

ثبّته على هاتفك مباشرة (نسخه عبر USB أو رابط) — أو لتوزيعه عبر
Google Play استخدم بدلاً منه:

```bash
flutter build appbundle --release
```

الناتج: `build/app/outputs/bundle/release/app-release.aab`

> **توقيع التطبيق**: لتوزيع APK خارج جهازك الشخصي، يجب توقيعه بمفتاح
> توقيع (Keystore). راجع توثيق Flutter الرسمي حول
> "Build and release an Android app" لإنشاء `key.properties` وإعداد
> `android/app/build.gradle`. بدون توقيع، الـ APK يعمل فقط للتثبيت
> اليدوي المباشر على جهازك (Debug/Release غير موقّع لا يُقبل في Play).

### Windows (تطبيق سطح مكتب)

```bash
flutter build windows --release
```

الناتج: مجلد كامل في `build/windows/x64/runner/Release/`
يحتوي على `sra_app.exe` وكل المكتبات المطلوبة (`.dll`). لتوزيعه،
انسخ المجلد كاملاً (أو غلّفه في مُثبِّت باستخدام أداة مثل Inno Setup).

### Web

```bash
flutter build web --release
```

الناتج: مجلد `build/web/` — يحتوي على ملفات ثابتة (HTML/JS/CSS)
يمكن رفعها على أي استضافة (Nginx, Cloudflare Pages, Netlify, GitHub
Pages...). تذكر أن المتصفح سيتصل بـ Backend عبر العنوان المضبوط في
شاشة الإعدادات — إذا كان الـ Backend على خادم بعيد، يجب أن يكون
متاحاً عبر `https://` أيضاً (المتصفحات تمنع طلبات HTTP من صفحة HTTPS).

---

## 7. ملاحظات إنتاجية مهمة

1. **هذه نسخة لمستخدم واحد (شخصية)** — لا يوجد نظام تسجيل دخول/مستخدمين
   متعددين بعد. إن أردت نشرها على خادم يصل إليه أكثر من جهاز لك (هاتف +
   كمبيوتر)، يكفي أن يعمل Backend واحد على عنوان IP/دومين ثابت، وكل
   أجهزتك تشير إليه من شاشة الإعدادات.
2. **الأمان**: إن نشرت الـ Backend على الإنترنت (ليس فقط شبكتك
   المنزلية)، أضف:
   - HTTPS (عبر Nginx/Caddy + Let's Encrypt).
   - مصادقة (API Key أو JWT) على مسارات الـ API — حالياً لا توجد
     مصادقة لأن المشروع شخصي ومخصص للشبكة المحلية.
3. **التحديثات المستقبلية**: عند إضافة الصوت أو البحث الأكاديمي إلى
   الـ Backend، تُضاف شاشات/أزرار جديدة في `lib/screens` بنفس الطريقة
   دون التأثير على باقي التطبيق.
