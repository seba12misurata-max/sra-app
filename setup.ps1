# =============================================================
#  SRA — سكريبت الإعداد لنظام Windows (PowerShell)
#  شغّله مرة واحدة بعد فك ضغط المشروع
#  التشغيل: Right-click > "Run with PowerShell"
#  أو من PowerShell:  cd flutter_app; .\setup.ps1
# =============================================================

Write-Host ""
Write-Host "  SRA - Setup Script" -ForegroundColor Cyan
Write-Host "  إعداد مشروع Flutter كامل" -ForegroundColor Cyan
Write-Host ""

# ---------- 1. التحقق من Flutter ----------
Write-Host "[SRA] فحص Flutter SDK..." -ForegroundColor Blue
try {
    $flutterVer = (flutter --version 2>&1)[0]
    Write-Host "[✓] $flutterVer" -ForegroundColor Green
} catch {
    Write-Host "[✗] Flutter غير مثبت!" -ForegroundColor Red
    Write-Host "    حمّله من: https://flutter.dev/docs/get-started/install"
    exit 1
}

# ---------- 2. تفعيل المنصات ----------
Write-Host "[SRA] تفعيل Windows Desktop..." -ForegroundColor Blue
flutter config --enable-windows-desktop | Out-Null

Write-Host "[SRA] تفعيل Web..." -ForegroundColor Blue
flutter config --enable-web | Out-Null

# ---------- 3. توليد gradle-wrapper.jar ----------
$WrapperJar = "android\gradle\wrapper\gradle-wrapper.jar"
$jarInfo = Get-Item $WrapperJar -ErrorAction SilentlyContinue
if ($null -eq $jarInfo -or $jarInfo.Length -lt 1000) {
    Write-Host "[SRA] توليد gradle-wrapper.jar..." -ForegroundColor Blue
    $tmpDir = [System.IO.Path]::GetTempPath() + "sra_tmp_" + [System.Guid]::NewGuid().ToString()
    flutter create --quiet --platforms=android $tmpDir\tmp_project 2>&1 | Out-Null
    Copy-Item "$tmpDir\tmp_project\android\gradle\wrapper\gradle-wrapper.jar" $WrapperJar
    Remove-Item $tmpDir -Recurse -Force
    Write-Host "[✓] gradle-wrapper.jar تم توليده" -ForegroundColor Green
} else {
    Write-Host "[✓] gradle-wrapper.jar موجود" -ForegroundColor Green
}

# ---------- 4. جلب الحزم ----------
Write-Host "[SRA] جلب حزم Dart..." -ForegroundColor Blue
flutter pub get
Write-Host "[✓] الحزم جاهزة" -ForegroundColor Green

# ---------- 5. رسالة ختامية ----------
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[✓] الإعداد اكتمل! الخطوات التالية:" -ForegroundColor Green
Write-Host ""
Write-Host "  شغّل الخادم أولاً (من مجلد backend):"
Write-Host "    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
Write-Host ""
Write-Host "  ثم ابنِ التطبيق:"
Write-Host "    flutter build apk --release        (APK لأندرويد)"
Write-Host "    flutter build windows --release    (تطبيق Windows)"
Write-Host "    flutter build web --release        (تطبيق Web)"
Write-Host ""
Write-Host "  للتشغيل المباشر:"
Write-Host "    flutter devices    (لرؤية الأجهزة)"
Write-Host "    flutter run        (تشغيل على الجهاز المحدد)"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
