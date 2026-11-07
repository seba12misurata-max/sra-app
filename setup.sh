#!/usr/bin/env bash
# =============================================================
#  SRA — سكريبت الإعداد الكامل
#  شغّله مرة واحدة فقط بعد فك ضغط الملف
#  يعمل على: Linux / macOS / Windows (Git Bash أو WSL)
# =============================================================
set -e

BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${BLUE}[SRA]${NC} $1"; }
ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
fail()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "  ███████╗██████╗  █████╗ "
echo "  ██╔════╝██╔══██╗██╔══██╗"
echo "  ███████╗██████╔╝███████║"
echo "  ╚════██║██╔══██╗██╔══██║"
echo "  ███████║██║  ██║██║  ██║"
echo "  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝"
echo "   إعداد مشروع Flutter كامل"
echo ""

# ---------- 1. التحقق من Flutter ----------
info "فحص Flutter SDK..."
if ! command -v flutter &>/dev/null; then
  fail "Flutter غير مثبت! حمّله من: https://flutter.dev/docs/get-started/install"
fi
ok "Flutter: $(flutter --version --machine 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["frameworkVersion"])' 2>/dev/null || flutter --version | head -1)"

# ---------- 2. تفعيل المنصات ----------
info "تفعيل منصة Windows Desktop..."
flutter config --enable-windows-desktop &>/dev/null || true

info "تفعيل منصة Web..."
flutter config --enable-web &>/dev/null || true

# ---------- 3. توليد gradle-wrapper.jar الحقيقي ----------
# Flutter يحتاج هذا الملف لبناء تطبيق أندرويد
WRAPPER_JAR="android/gradle/wrapper/gradle-wrapper.jar"
if [ ! -s "$WRAPPER_JAR" ] || [ "$(wc -c < "$WRAPPER_JAR")" -lt 1000 ]; then
  info "توليد gradle-wrapper.jar..."
  # استخدام flutter لإنشاء مشروع مؤقت واستخراج الـ jar منه
  TMPDIR_FLUTTER=$(mktemp -d)
  flutter create --quiet --platforms=android "$TMPDIR_FLUTTER/tmp_project" &>/dev/null
  cp "$TMPDIR_FLUTTER/tmp_project/android/gradle/wrapper/gradle-wrapper.jar" "$WRAPPER_JAR"
  rm -rf "$TMPDIR_FLUTTER"
  ok "gradle-wrapper.jar تم توليده"
else
  ok "gradle-wrapper.jar موجود"
fi

# ---------- 4. جلب الحزم ----------
info "جلب حزم Dart (flutter pub get)..."
flutter pub get
ok "الحزم جاهزة"

# ---------- 5. رسالة ختامية ----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "الإعداد اكتمل! الخطوة التالية:"
echo ""
echo "  شغّل الخادم أولاً (من مجلد backend):"
echo "    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
echo ""
echo "  ثم ابنِ التطبيق:"
echo "    APK لأندرويد  :  flutter build apk --release"
echo "    تطبيق Windows  :  flutter build windows --release"
echo "    تطبيق Web      :  flutter build web --release"
echo ""
echo "  أو للتشغيل المباشر أثناء التطوير:"
echo "    flutter devices   ← لرؤية الأجهزة"
echo "    flutter run       ← تشغيل على الجهاز/المحاكي"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
