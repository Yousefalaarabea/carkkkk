# Post-Trip Handover System

## نظرة عامة

تم تنفيذ نظام **Post-Trip Handover** لإدارة عملية تسليم السيارة بعد انتهاء الرحلة بدون سائق. النظام يتكون من مرحلتين رئيسيتين:

### 1. Renter Drop-Off (تسليم المستأجر)
### 2. Owner Drop-Off (استلام المالك)

---

## 🏗️ البنية المعمارية

### **Models (نماذج البيانات)**

#### `PostTripHandoverModel`
- يحتوي على كل بيانات عملية التسليم
- يتتبع حالة التسليم لكل من المستأجر والمالك
- يحفظ معلومات الدفع والرسوم الزائدة

#### `ExcessChargesModel`
- يحسب الرسوم الزائدة للوقت والكيلومترات
- يحتوي على الأسعار المتفق عليها والفعلي

#### `HandoverLogModel`
- يسجل كل خطوة في عملية التسليم
- يتتبع الإجراءات والوقت والتواريخ

### **Cubits (إدارة الحالة)**

#### `RenterDropOffCubit`
- يدير عملية تسليم المستأجر
- يتعامل مع رفع الصور وحساب الرسوم الزائدة
- يعالج الدفع ويضيف الملاحظات

#### `OwnerDropOffCubit`
- يدير عملية استلام المالك
- يعرض بيانات تسليم المستأجر
- يؤكد استلام الدفع النقدي ويضيف ملاحظات المالك

### **Screens (الشاشات)**

#### `RenterDropOffScreen`
- شاشة تسليم المستأجر مع 5 خطوات:
  1. رفع صورة السيارة بعد الرحلة
  2. رفع صورة عداد المسافات
  3. إدخال قراءة العداد النهائية
  4. حساب الرسوم الزائدة ومعالجة الدفع
  5. إضافة ملاحظات المستأجر

#### `OwnerDropOffScreen`
- شاشة استلام المالك تعرض:
  - ملخص عملية التسليم
  - الصور المرفوعة
  - الرسوم الزائدة
  - حالة الدفع
  - ملاحظات المستأجر
  - إضافة ملاحظات المالك

### **Widgets (العناصر)**

#### `ExcessChargesWidget`
- يعرض تفاصيل الرسوم الزائدة
- يحسب التكلفة الإجمالية
- يعرض طريقة الدفع وحالتها

#### `HandoverNotesWidget`
- يسمح بإضافة الملاحظات
- يعرض عدد الأحرف المدخلة

#### `ImageUploadWidget`
- يتعامل مع رفع الصور
- يدعم الكاميرا والمعرض

---

## 🔄 Flow العملية

### **الخطوة 1: Renter Drop-Off**

1. **تهيئة العملية**
   ```dart
   context.read<RenterDropOffCubit>().initializeHandover(
     tripId: 'trip_001',
     carId: 'car_001',
     renterId: 'renter_001',
     ownerId: 'owner_001',
     paymentMethod: 'visa',
   );
   ```

2. **رفع صورة السيارة**
   ```dart
   await context.read<RenterDropOffCubit>().uploadCarImage(imageFile);
   ```

3. **رفع صورة العداد**
   ```dart
   await context.read<RenterDropOffCubit>().uploadOdometerImage(imageFile);
   ```

4. **إدخال قراءة العداد**
   ```dart
   context.read<RenterDropOffCubit>().setFinalOdometerReading(250);
   ```

5. **حساب الرسوم الزائدة**
   ```dart
   context.read<RenterDropOffCubit>().calculateExcessCharges(
     agreedKilometers: 200,
     agreedHours: 24,
     extraKmRate: 0.5,
     extraHourRate: 10.0,
   );
   ```

6. **معالجة الدفع**
   ```dart
   context.read<RenterDropOffCubit>().processPayment();
   ```

7. **إضافة الملاحظات**
   ```dart
   context.read<RenterDropOffCubit>().addRenterNotes('ملاحظات المستأجر');
   ```

8. **إكمال التسليم**
   ```dart
   context.read<RenterDropOffCubit>().completeRenterHandover();
   ```

### **الخطوة 2: Owner Drop-Off**

1. **تحميل بيانات التسليم**
   ```dart
   context.read<OwnerDropOffCubit>().loadHandoverData(handoverData, logs);
   ```

2. **تأكيد الدفع النقدي (إذا كان مطلوباً)**
   ```dart
   context.read<OwnerDropOffCubit>().confirmCashPayment();
   ```

3. **إضافة ملاحظات المالك**
   ```dart
   context.read<OwnerDropOffCubit>().addOwnerNotes('ملاحظات المالك');
   ```

4. **إكمال الاستلام**
   ```dart
   context.read<OwnerDropOffCubit>().completeOwnerHandover();
   ```

---

## 🚀 كيفية الاستخدام

### **البداية من شاشة إدارة الرحلة**

1. انتقل إلى `TripManagementScreen`
2. اضغط على زر `handshake` في الـ AppBar
3. سيتم نقلك إلى `RenterDropOffScreen`

### **الانتقال بين الشاشات**

```dart
// من شاشة إدارة الرحلة إلى تسليم المستأجر
Navigator.pushNamed(
  context,
  ScreensName.renterDropOffScreen,
  arguments: {
    'tripId': 'trip_001',
    'carId': 'car_001',
    'renterId': 'renter_001',
    'ownerId': 'owner_001',
    'paymentMethod': 'visa',
  },
);

// من تسليم المستأجر إلى استلام المالك (تلقائي)
// يحدث في RenterDropOffScreen عند إكمال التسليم

// من استلام المالك إلى الشاشة الرئيسية (تلقائي)
// يحدث في OwnerDropOffScreen عند إكمال الاستلام
```

---

## 📊 تتبع البيانات

### **Handover Logs**

كل خطوة يتم تسجيلها في `HandoverLogModel`:

```dart
HandoverLogModel.create(
  handoverId: 'handover_001',
  action: HandoverLogModel.renterUploadCarImage,
  actor: HandoverLogModel.renter,
  description: 'Car image uploaded',
  metadata: {'imagePath': '/path/to/image.jpg'},
);
```

### **الحالات المدعومة**

- `renter_upload_car_image`
- `renter_upload_odometer`
- `renter_payment`
- `renter_handover`
- `owner_review`
- `owner_handover`

---

## 🔧 التخصيص

### **إضافة طرق دفع جديدة**

1. أضف الطريقة في `PostTripHandoverModel.paymentMethod`
2. حدث `ExcessChargesWidget._getPaymentMethodText()`
3. أضف منطق المعالجة في `RenterDropOffCubit.processPayment()`

### **تخصيص الرسوم الزائدة**

1. حدث `ExcessChargesModel.calculate()`
2. أضف حقول جديدة في النموذج
3. حدث `ExcessChargesWidget` لعرض الحقول الجديدة

### **إضافة خطوات جديدة**

1. أضف الحالة في الـ Cubit
2. أضف الـ State المناسب
3. حدث الشاشة لعرض الخطوة الجديدة

---

## 🧪 الاختبار

### **اختبار Renter Drop-Off**

1. ابدأ من `TripManagementScreen`
2. اضغط على زر `handshake`
3. اتبع الخطوات الخمس
4. تأكد من إكمال كل خطوة

### **اختبار Owner Drop-Off**

1. بعد إكمال Renter Drop-Off
2. ستنتقل تلقائياً إلى Owner Drop-Off
3. راجع البيانات المعروضة
4. أكمل عملية الاستلام

---

## 📝 ملاحظات مهمة

1. **البيانات المحاكية**: النظام يستخدم بيانات محاكية للاختبار
2. **التخزين المحلي**: البيانات تُحفظ محلياً حالياً
3. **التكامل المستقبلي**: جاهز للتكامل مع API
4. **التحقق**: كل خطوة تتطلب إكمال الخطوة السابقة
5. **السجلات**: كل إجراء يُسجل مع الوقت والتاريخ

---

## 🔮 التطوير المستقبلي

- [ ] تكامل مع API حقيقي
- [ ] إشعارات push
- [ ] تحويل الأرباح للمالكين
- [ ] تقارير مفصلة
- [ ] دعم المدفوعات الإلكترونية
- [ ] تتبع GPS في الوقت الفعلي 