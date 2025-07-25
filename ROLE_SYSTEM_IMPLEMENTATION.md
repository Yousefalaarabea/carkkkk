# نظام الأدوار (Role System) - التوثيق

## نظرة عامة
تم تنفيذ نظام الأدوار في التطبيق ليتكون من 3 أدوار رئيسية:

### الأدوار المتاحة:
1. **Renter (المستأجر)** - Role ID: 1
2. **Owner (المالك)** - Role ID: 2  
3. **Driver (السائق)** - Role ID: 3

## آلية عمل النظام:

### 1. عند التسجيل (Signup)
- يتم تعيين الدور الافتراضي: **Renter (Role 1)**
- يتم إرسال طلب POST إلى `/user-roles/` مع:
  ```json
  {
    "user": userId,
    "role": 1
  }
  ```

### 2. عند إضافة أول سيارة (Add Car)
- يتم التحقق من الأدوار الحالية للمستخدم
- إذا كان المستخدم لديه دور Renter فقط، يتم ترقيته إلى **Owner (Role 2)**
- يتم إرسال طلب POST إلى `/user-roles/` مع:
  ```json
  {
    "user": userId,
    "role": 2
  }
  ```

### 3. عند اختيار "With Driver" في خيارات التأجير
- يتم التحقق من خيار `available_with_driver` في `rentalOptionsData`
- إذا كان `true`، يتم إضافة دور **Driver (Role 3)**
- يتم إرسال طلب POST إلى `/user-roles/` مع:
  ```json
  {
    "user": userId,
    "role": 3
  }
  ```

## الملفات المعدلة:

### 1. `lib/core/car_service.dart`
- **`addCar()`**: تم إضافة منطق التحقق من خيار "with driver"
- **`updateCar()`**: تم إضافة نفس المنطق عند تحديث السيارة
- **`assignRoleOwner()`**: وظيفة موجودة لترقية المستخدم إلى Owner
- **`assignRoleDriver()`**: وظيفة محسنة للتحقق من الأدوار الموجودة قبل إضافة دور Driver

### 2. `lib/features/auth/presentation/cubits/auth_cubit.dart`
- **`signup()`**: تم إضافة تعيين دور Renter عند التسجيل

## مثال على التدفق:

```
1. المستخدم يسجل → Role 1 (Renter)
2. المستخدم يضيف أول سيارة → Role 2 (Owner)
3. المستخدم يختار "With Driver" → Role 3 (Driver)
```

## التحقق من الأدوار:

### قبل إضافة أي دور:
1. يتم جلب جميع الأدوار الحالية من `/user-roles/`
2. يتم التحقق من وجود الدور المطلوب
3. إذا لم يكن موجود، يتم إضافته
4. إذا كان موجود، يتم تجاهل الطلب

## رسائل التصحيح:

### عند إضافة دور Owner:
```
✅ Owner role assigned to user {userId}
ℹ️ User already has Owner role or is not just a Renter.
❌ Failed to assign Owner role. Status: {statusCode}
```

### عند إضافة دور Driver:
```
✅ Driver role assigned to user {userId}
ℹ️ User already has Driver role.
❌ Failed to assign Driver role. Status: {statusCode}
```

## ملاحظات مهمة:

1. **التراكمية**: يمكن للمستخدم أن يكون لديه أكثر من دور في نفس الوقت
2. **التحقق**: يتم التحقق من الأدوار الموجودة قبل إضافة أي دور جديد
3. **التحديث**: نفس المنطق يعمل عند تحديث خيارات السيارة
4. **الأمان**: يتم استخدام admin token لعمليات إدارة الأدوار

## API Endpoints المستخدمة:

- `POST /user-roles/` - إضافة دور جديد
- `GET /user-roles/` - جلب جميع الأدوار للتحقق
- `POST /cars/` - إضافة سيارة
- `PATCH /cars/{id}/` - تحديث سيارة
- `POST /car-rental-options/` - إضافة خيارات التأجير
- `PATCH /car-rental-options/{id}/` - تحديث خيارات التأجير
