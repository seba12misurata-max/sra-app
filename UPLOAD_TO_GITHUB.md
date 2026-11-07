# 🚀 كيف تحصل على APK في 10 دقائق — Windows 7

## الخطوات بالترتيب:

### 1. أنشئ حساب GitHub مجاني
https://github.com/signup

### 2. أنشئ repository جديد
- اذهب إلى: https://github.com/new
- اسمه: `sra-app`
- اتركه Public أو Private (كلاهما يعمل مع Actions)
- اضغط **Create repository**

### 3. ارفع الملفات
**الطريقة السهلة (بدون Git):**
1. افتح الـ repository على GitHub
2. اضغط **Add file** → **Upload files**
3. اسحب كل محتوى مجلد `flutter_app/` وأسقطه في الصفحة
4. اضغط **Commit changes**

### 4. GitHub Actions يبدأ تلقائياً
- اذهب إلى تبويب **Actions** في الـ repository
- ستجد workflow اسمه **Build SRA APK** يعمل
- انتظر 10-15 دقيقة حتى ينتهي (شريط أخضر ✅)

### 5. حمّل APK
- اضغط على الـ workflow Run المكتمل
- في أسفل الصفحة: **Artifacts**
- حمّل **SRA-v1.0-arm64** (للهواتف الحديثة)
- أو **SRA-v1.0-universal** (يعمل على الكل)

### 6. ثبّت على هاتفك
1. انقل APK للهاتف (USB أو واتساب لنفسك)
2. إعدادات الهاتف → الأمان → **مصادر غير معروفة** ✓
3. افتح ملف APK وثبّته
4. افتح SRA ← أيقونة ⚙ ← أدخل عنوان خادم Backend

---

## ⚠️ مهم قبل الرفع

تأكد أن هيكل المجلدات هكذا في GitHub:
```
/ (root of repository)
├── .github/
│   └── workflows/
│       └── build-apk.yml   ← هذا يشغّل البناء
├── android/
├── lib/
├── pubspec.yaml
└── ...
```

**لا ترفع مجلد flutter_app كـ parent** — ارفع محتواه مباشرة.

---

## بدل GitHub: Codemagic (أسهل)

1. https://codemagic.io → سجّل بحساب GitHub
2. اختر مشروعك
3. اختر **Flutter App**
4. اضغط **Start new build**
5. حمّل APK من النتائج

