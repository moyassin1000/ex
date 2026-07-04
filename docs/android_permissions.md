# Android Permissions

لا توجد صلاحيات Android خاصة مطلوبة لهذا التطبيق.

السبب: التطبيق يعتمد على `file_picker`، وهو يفتح نافذة اختيار الملفات الأصلية في Android، لذلك المستخدم يمنح الوصول للملف الذي اختاره فقط.

بعد تنفيذ:

```bash
flutter create --platforms=android .
```

يمكنك فقط تعديل اسم التطبيق من ملف:

```text
android/app/src/main/AndroidManifest.xml
```

واستخدم:

```xml
android:label="Excel Viewer Pro"
```
