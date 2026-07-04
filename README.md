# Excel Viewer Pro

تطبيق Flutter عربي RTL لفتح ملفات Excel بصيغة XLSX وعرضها داخل التطبيق بدون Microsoft Excel وبدون WebView.

## المميزات

- واجهة عربية بالكامل واتجاه RTL.
- شاشة Splash احترافية.
- اختيار ملف XLSX من مدير ملفات الهاتف.
- قراءة كل الشيتات داخل الملف.
- عرض الشيتات في Tabs.
- جدول يدعم تمرير أفقي وعمودي.
- بحث داخل صفوف الشيت الحالي.
- تكبير وتصغير حجم الخط.
- حفظ حجم الخط والوضع الفاتح/الداكن باستخدام SharedPreferences.
- معالجة أخطاء الملفات غير الصالحة أو الفارغة.

## الحزم المستخدمة

- file_picker: لاختيار ملف xlsx.
- excel: قراءة ملف xlsx وتحويله لصفوف.
- shared_preferences: حفظ إعدادات المستخدم.

## إنشاء مشروع Flutter كامل

إذا كان لديك Flutter مثبتًا، نفّذ الأوامر التالية:

```bash
flutter create excel_viewer_pro
```

ثم انسخ ملفات هذا المشروع فوق ملفات المشروع الذي تم إنشاؤه.

أو من داخل هذا المجلد مباشرة. ملاحظة: الحزمة لا تحتوي على مجلد Android كامل لأن Flutter ينشئ ملفات Gradle المناسبة لإصدار SDK الموجود عندك:

```bash
flutter create --platforms=android .
flutter pub get
flutter run
flutter build apk --release
```

سيكون ملف APK النهائي غالبًا في:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

## ملاحظات مهمة

- التطبيق يدعم XLSX فقط.
- لا يحتاج التطبيق لصلاحيات تخزين خاصة على Android لأن `file_picker` يستخدم نافذة اختيار الملفات الأصلية. راجع `docs/android_permissions.md`.
- ملفات XLS القديمة غير مدعومة في هذا الإصدار.
- إذا ظهرت مشكلة بسبب إصدار Flutter قديم، حدّث Flutter ثم نفّذ:

```bash
flutter upgrade
flutter clean
flutter pub get
flutter build apk --release
```
