# دليل تطبيق السواق / مندوب التوصيل (Delivery Man App) — دليل شامل

> موجّه لمطوّر تطبيق الهاتف (Flutter / React Native / Native). يغطي التركيب، البنية، المصادقة، دورة حياة الطلب، التتبع الحيّ، المحفظة، الرسائل، ومرجع كامل لكل الـ API.

---

## جدول المحتويات

1. [نظرة عامة](#1-نظرة-عامة)
2. [التركيب والتشغيل المحلي (Setup)](#2-التركيب-والتشغيل-المحلي-setup)
3. [البنية المعمارية والملفات](#3-البنية-المعمارية-والملفات)
4. [المصادقة والتوثيق (Auth)](#4-المصادقة-والتوثيق-auth)
5. [نموذج بيانات المندوب](#5-نموذج-بيانات-المندوب)
6. [دورة حياة الطلب (Order Lifecycle)](#6-دورة-حياة-الطلب-order-lifecycle)
7. [الورديات والتوفّر (Shifts)](#7-الورديات-والتوفّر-shifts)
8. [تتبع الموقع المباشر والإشعارات اللحظية](#8-تتبع-الموقع-المباشر-والإشعارات-اللحظية)
9. [الإشعارات عبر FCM](#9-الإشعارات-عبر-fcm)
10. [المحفظة والنقد والتحصيل والسحب](#10-المحفظة-والنقد-والتحصيل-والسحب)
11. [الرسائل (Chat)](#11-الرسائل-chat)
12. [إدارة الحساب](#12-إدارة-الحساب)
13. [مرجع كامل لـ API Endpoints](#13-مرجع-كامل-لـ-api-endpoints)
14. [أكواد الأخطاء الشائعة](#14-أكواد-الأخطاء-الشائعة)
15. [قائمة التحقق قبل التسليم](#15-قائمة-التحقق-قبل-التسليم)

---

## 1. نظرة عامة

التطبيق مخصّص لدور `delivery-man` (مندوب التوصيل). كل مسارات المندوب تبدأ بـ:

```
https://haatapp.com/api/v1/delivery-man/...
```

### المعلومات الأساسية

| العنصر | القيمة |
|---|---|
| **Base URL** | `https://haatapp.com/api/v1` |
| **صيغة البيانات** | `JSON` |
| **النمط** | RESTful |
| **التشفير** | HTTPS إجباري |
| **Kernel** | Laravel (StackFood / Haat2) |
| **توكن المندوب** | `auth_token` نصّي عشوائي (120 حرف) |

### نوعان للمندوب (type)

| النوع | القيمة | الوصف |
|---|---|---|
| مندوب المنطقة | `zone_wise` | يستقبل الطلبات من كل مطاعم المنطقة (الافتراضي) |
| مندوب مطعم | `restaurant_wise` | مرتبط بمطعم واحد (`restaurant_id`) |

> **مهم:** مسارات `dm.api` تتحقق من حقل `token` لا من رأس Bearer فقط، لذلك أرسل التوكن **في الـ query/body باسم `token` + رأس `Authorization: Bearer {token}`** معًا.

---

## 2. التركيب والتشغيل المحلي (Setup)

### المتطلبات

| البرنامج | الإصدار الموصى به |
|---|---|
| PHP | 8.1+ |
| Composer | 2.x |
| MySQL / MariaDB | 5.7+ / 10.3+ |
| Node.js (لبناء لوحة التحكم فقط) | 16+ |
| Laravel | 10/11 (حسب `composer.json`) |

### الخطوات

```bash
# 1) تنصيب اعتماديات PHP
composer install

# 2) نسخ ملف البيئة وإعداد الاتصال بقاعدة البيانات
cp .env.example .env
php artisan key:generate

# 3) ربط مجلد التخزين (للصور والملفات المرفوعة)
php artisan storage:link

# 4) تنفيذ الترحيلات + البيانات الأولية
php artisan migrate
php artisan db:seed

# 5) بناء الأصول الأمامية (اختياري للتطوير)
npm install && npm run dev

# 6) تشغيل الخادم المحلي
php artisan serve            # http://127.0.0.1:8000
```

### المتغيّرات المهمّة في `.env`

| المتغيّر | الوصف | مثال |
|---|---|---|
| `APP_URL` | رابط الخادم الأساسي | `https://haatapp.com` |
| `APP_MODE` | `live` أو `test` (في `test` يقبل OTP ثابت `123456`) | `live` |
| `DB_*` | إعدادات قاعدة البيانات | — |
| `BROADCAST_DRIVER` | `pusher` للمسارات اللحظية | `pusher` |
| `PUSHER_APP_*` | مفاتيح Pusher للشات والتتبع | — |
| `FCM_*` | مفاتيح Firebase للإشعارات | — |

### تفعيل التطبيق من لوحة التحكم

قبل أن تعمل مسارات المندوب، يجب من لوحة الإدارة:

1. تفعيل الوحدة/الإضافة **deliveryman_app** (وإلا يرجع الخادم `503`).
2. ضبط إعدادات المندوب: `dm_maximum_orders` (أقصى عدد طلبات متزامنة)، `dm_max_cash_in_hand`، `cash_in_hand_overflow_delivery_man`.
3. ضبط `order_confirmation_model` (`deliveryman` أو `restaurant`) و `order_delivery_verification` (1 = التحقق بـ OTP عند التسليم) و `canceled_by_deliveryman`.

---

## 3. البنية المعمارية والملفات

### ملفات المرور (Routes)

| الملف | المحتوى |
|---|---|
| `routes/api/v1/api.php` | كل مسارات الـ API (سطور 95–176 و 121–176 للمندوب) |
| `routes/channels.php` | قناة Pusher الخاصة `private-deliveryman.{id}` |
| `routes/web.php` | مسار تقديم طلب الانضمام من الويب |

### المتحكّمات (Controllers)

| المتحكّم | المسار | الوظيفة |
|---|---|---|
| `DeliveryManLoginController` | `app/Http/Controllers/Api/V1/Auth/DeliveryManLoginController.php` | تسجيل الدخول والتسجيل |
| `DMPasswordResetController` | `app/Http/Controllers/Api/V1/Auth/DMPasswordResetController.php` | استعادة كلمة المرور |
| `DeliverymanController` | `app/Http/Controllers/Api/V1/DeliverymanController.php` | كل عمليات المندوب (الطلبات، الموقع، المحفظة) |
| `ConversationController` | `app/Http/Controllers/Api/V1/ConversationController.php` | الرسائل |
| `DeliveryManReviewController` | `app/Http/Controllers/Api/V1/DeliveryManReviewController.php` | التقييمات |
| `BroadcastingAuthController` | `app/Http/Controllers/Api/V1/BroadcastingAuthController.php` | تصريح قنوات Pusher |
| `ConfigController` | `app/Http/Controllers/Api/V1/ConfigController.php` | إعدادات التطبيق العامة |

### الميدل وير (Middleware)

| الاسم | المعنى |
|---|---|
| `dm.api` | يتحقق من وجود `token` في بنية الطلب موجود داخل جدول `delivery_men` |
| `actch:deliveryman_app` | يتحقق من تفعيل تطبيق المندوب (وإلا `503`) |
| `api` | يغلّف كل ردود `api/*` بالبنية الموحّدة |
| `localization` | يقرأ `X-localization` للترجمة |

---

## 4. المصادقة والتوثيق (Auth)

### رؤوس الطلبات (Headers)

| الرأس | القيمة | مطلوب |
|---|---|---|
| `Content-Type` | `application/json` | نعم للـ POST/PUT |
| `Accept` | `application/json` | نعم |
| `Authorization` | `Bearer {token}` | نعم للمسارات المحمية |
| `module_type` | `deliveryman_app` | موصى به (كما في Postman) |
| `X-localization` | `ar` أو `en` | اختياري (اللغة) |

> التوكن يُرسل **مرتين**: في الـ `token` query/body لهجمات `dm.api`، وفي رأس `Authorization` للتوافق.

### 4.1 تسجيل الدخول — `POST /auth/delivery-man/login`

**Request (JSON):**
```json
{
  "phone": "01000000000",
  "password": "Secret@123"
}
```

**Response 200 (بعد التغليف):**
```json
{
  "success": true,
  "message": null,
  "result": {
    "token": "random_120_char_auth_token",
    "topic": ["delivery_man_1_2_3"]
  },
  "code": 200
}
```

**ملاحظات:**
- الحقل المطلوب فعلي هو `phone` (وليس `email`).
- كلمة المرور أقل شيء 6 أحرف.
- الشروط: `application_status = approved` و `status = 1`، وإلا يرجع `401`.

**أخطاء محتملة:**

| الكود | `code` | الرسالة |
|---|---|---|
| 403 | `phone` | رقم الهاتف غير موجود / بيانات ناقصة |
| 401 | `auth-001` | بيانات الدخول غير مطابقة |
| 401 | `auth-003` | طلب الانضمام لم يُعتمد بعد |
| 401 | `auth-003` | الحساب موقوف |

### 4.2 تسجيل مندوب جديد — `POST /auth/delivery-man/store`

**Request (multipart/form-data لدعم الصور):**

| الحقل | النوع | مطلوب | الوصف |
|---|---|---|---|
| `f_name` | string | نعم | الاسم الأول |
| `l_name` | string | لا | الاسم الأخير |
| `email` | string | نعم | فريد |
| `phone` | string | نعم | فريد (9 أرقام+) |
| `password` | string | نعم | 8+ أحرف، حروف كبيرة وصغيرة + أرقام + رموز، غير مسرّب |
| `identity_type` | enum | نعم | `passport` \| `driving_license` \| `nid` |
| `identity_number` | string | نعم | رقم الهوية |
| `identity_image[]` | file | لا | صور الهوية (حتى 2MB للصورة) |
| `zone_id` | int | نعم | المنطقة |
| `vehicle_id` | int | نعم | المركبة |
| `earning` | enum | نعم | `0` = بدون ربح/غير مرتبط، `1` = بنظام الورديات |
| `shifts` | JSON string | نعم إذا `earning=1` | مصفوفة أرقام ورديات، مثال: `"[1,2]"` |
| `image` | file | لا | الصورة الشخصية |
| `additional_data` | JSON string | لا | بيانات إضافية مخصّصة |
| `additional_documents` | files[][] | لا | مستندات إضافية |

**Response 200:**
```json
{ "success": true, "message": "Deliveryman added successfully", "result": null, "code": 200 }
```

> بعد التسجيل تكون الحالة `application_status = pending` حتى يعتمدها الأدمن.

### 4.3 استعادة كلمة المرور

| الخطوة | الطريقة | المسار | Body |
|---|---|---|---|
| 1. طلب OTP | POST | `/auth/delivery-man/forgot-password` | `{ "phone": "..." }` |
| 2. التحقق من OTP | POST | `/auth/delivery-man/verify-token` | `{ "phone": "...", "reset_token": "123456" }` |
| 3. تعيين كلمة جديدة | PUT | `/auth/delivery-man/reset-password` | `{ "phone", "reset_token", "password", "confirm_password" }` |
| بديل Firebase | POST | `/auth/delivery-man/firebase-verify-token` | `{ "sessionInfo", "phoneNumber", "code" }` |

> في بيئة `test` يكون OTP ثابت `123456`. حد إعادة المحاولة 5 ثم حظر مؤقت.

### 4.4 تسجيل الخروج

لا يوجد endpoint خاص؛ احذف التوكن محليًا. (يُفضّل أيضًا جعل الحالة offline عبر `update-active-status` قبل الخروج.)

---

## 5. نموذج بيانات المندوب

### جدول `delivery_men`

| الحقل | النوع | الوصف |
|---|---|---|
| `id` | bigint | المعرف |
| `f_name` / `l_name` | string | الاسم |
| `phone` | string | فريد، يُستخدم للدخول |
| `email` | string | فريد |
| `password` | string | مُشفّر (bcrypt) |
| `auth_token` | string | توكن الجلسة (مخفي في الردود) |
| `fcm_token` | string | توكن Firebase |
| `zone_id` | int | المنطقة |
| `restaurant_id` | int | المطعم (لنوع `restaurant_wise`) |
| `type` | string | `zone_wise` \| `restaurant_wise` |
| `vehicle_id` | int | المركبة |
| `shift_id` | int | الوردية الحالية |
| `earning` | bool | 1 = نظام الأرباح والورديات |
| `identity_type` / `identity_number` / `identity_image` | mixed | بيانات الهوية |
| `image` | string | الصورة |
| `status` | bool | 1 = نشط |
| `active` | bool | 1 = متصل الآن (online) |
| `available` | bool | جاهز للاستقبال |
| `application_status` | enum | `approved` \| `denied` \| `pending` |
| `current_orders` | int | عدد الطلبات الجارية |
| `order_count` | int | إجمالي الطلبات المكتملة |
| `assigned_order_count` | int | إجمالي الطلبات المُسنَدة |
| `additional_data` | text | JSON بيانات إضافية |
| `additional_documents` | text | JSON مستندات |
| `current_language_key` | string | لغة التطبيق |

### جدول الورديات `delivery_man_shift`

ربط many-to-many بين `delivery_men` و `shifts` (الحقول: `delivery_man_id`, `shift_id`).

### جدول المحفظة `delivery_man_wallets`

| الحقل | الوصف |
|---|---|
| `total_earning` | إجمالي الأرباح |
| `total_withdrawn` | إجمالي المسحوب |
| `pending_withdraw` | سحب معلّق |
| `collected_cash` | النقد المحصَّل من العملاء (باليد) |

---

## 6. دورة حياة الطلب (Order Lifecycle)

### حالات الطلب

```
pending → confirmed → processing → handover → picked_up → delivered
   │           │            │            │           │
   └───────────┴────────────┴────────────┴───────────┴──→ canceled
```

### الحالات ذات الصلة بالمندوب

| الحالة | المعنى | من يضبطها |
|---|---|---|
| `pending` | بانتظار التأكيد | النظام |
| `confirmed` | مؤكَّد | المطعم أو المندوب (حسب `order_confirmation_model`) |
| `accepted` | المندوب قبِل الطلب | `accept-order` |
| `processing` | قيد التحضير | المطعم |
| `handover` | جاهز للتسليم | المطعم |
| `picked_up` | استلمه المندوب | `update-order-status` |
| `delivered` | تم التسليم | `update-order-status` |
| `canceled` | ملغي | `update-order-status` (إن كان مسموحًا) |

| مجموعات الاستعلام | الحالات |
|---|---|
| الطلبات الجارية (`current-orders`) | `accepted, confirmed, pending, processing, picked_up, handover` |
| سجل الطلبات (`all-orders`) | `delivered, canceled, refund_requested, refunded, refund_request_canceled, failed` |

### تدفق التسليم الكامل

1. **تسجيل الدخول** → استلام `token`.
2. **جعل الحالة متصل** → `POST /delivery-man/update-active-status`.
3. **جلب الطلبات المتاحة** → `GET /delivery-man/latest-orders`.
4. **قبول طلب** → `PUT /delivery-man/accept-order`.
5. **تحديث الموقع دوريًا** → `POST /delivery-man/record-location-data`.
6. **استلام من المطعم** → `PUT /delivery-man/update-order-status` بـ `status=picked_up`.
7. **التسليم**:
   - إرسال OTP للعميل (اختياري) → `PUT /delivery-man/send-order-otp`.
   - إتمام التسليم → `PUT /delivery-man/update-order-status` بـ `status=delivered` (+ `otp` إن كان التحقق مفعّلًا، و`order_proof[]` كصور).
8. **تنبيه**: لا تنسَ إشعار العميل OTP.

### قواعد قبول الطلب

- يجب ألا يتجاوز `current_orders` قيمة `dm_maximum_orders` (خطأ `405 dm_maximum_order_exceed`).
- إذا كان الدفع نقديًا و`cash_in_hand + order_amount >= dm_max_cash_in_hand` → `203 dm_max_cash_in_hand`.
- إذا أرسلت `lat`/`lng` وكان المندوب خارج نطاق الخدمة → `403 dm_out_of_zone`.
- الطلب يجب أن يكون غير مُسنَد ومطابقًا للمركبة والوردية.

---

## 7. الورديات والتوفّر (Shifts)

| الطريقة | المسار | الوصف |
|---|---|---|
| POST | `/delivery-man/update-active-status` | تبديل حالة الاتصال (online/offline) |
| GET | `/delivery-man/dm-shift` | ورديات المندوب المتاحة (يتطلب توكن) |
| GET | `/dm-shifts` | كل الورديات النشطة (عام، بدون توكن) |
| GET | `/delivery-man/dm-topic` | موضوعات FCM التي يجب الاشتراك بها |

**موضوعات FCM (topics)** تُبنى حسب حالة المندوب:

| الحالة | الموضوع |
|---|---|
| مندوب مطعم | `restaurant_dm_{restaurant_id}` |
| منطقة بدون مركبة | `{zone.deliveryman_wise_topic}` |
| منطقة + مركبة | `delivery_man_{zone_id}_{vehicle_id}` |
| منطقة + مركبة + وردية | `delivery_man_{zone_id}_{vehicle_id}_{shift_id}` |

> عادةً تظهر موضوعات متعدّدة في `profile.topic` — اشترك في كلها عبر FCM SDK.

---

## 8. تتبع الموقع المباشر والإشعارات اللحظية

### إرسال الموقع

`POST /delivery-man/record-location-data?token={token}`

```json
{
  "longitude": "90.4125",
  "latitude": "23.8103",
  "location": "Dhaka, Bangladesh"
}
```

يُحدَّث سجل `delivery_histories` للمندوب (upsert). أرسله كل 10–30 ثانية أثناء التوصيل.

### قراءة آخر موقع

| الطريقة | المسار | Body/Query |
|---|---|---|
| GET | `/delivery-man/last-location` | `order_id` (مطلوب) |
| GET | `/delivery-man/order-delivery-history` | `order_id` (مطلوب) + `token` |

### Pusher (القنوات اللحظية)

| العنصر | القيمة |
|---|---|
| القناة | `private-deliveryman.{deliveryman_id}` |
| تصريح | `POST https://haatapp.com/broadcasting/auth` |
| الحقول | `socket_id`, `channel_name` |
| التوكن | `token={auth_token}` أو `Authorization: Bearer {auth_token}` |
| الرد | `{ "auth": "app_key:hmac_signature" }` (بدون تغليف) |

> القناة تُستخدم للشات اللحظي وتحديثات حالة الطلب.

---

## 9. الإشعارات عبر FCM

| الطريقة | المسار | Body |
|---|---|---|
| PUT | `/delivery-man/update-fcm-token` | `{ "fcm_token": "..." }` |
| GET | `/delivery-man/notifications` | يرجع إشعارات آخر 7 أيام |

- حدّث `fcm_token` عند كل تشغيل للتطبيق وعند تجديد التوكن.
- اشترك في موضوعات `topic` القادمة من `login` / `profile` / `dm-topic`.
- أنواع الإشعارات: تحديث حالة الطلب، رسالة جديدة، إشعارات إدارية.

---

## 10. المحفظة والنقد والتحصيل والسحب

### الحقول الأساسية في `GET /delivery-man/profile`

| الحقل | المعنى |
|---|---|
| `cash_in_hands` | النقد المحصَّل حاليًا |
| `balance` | الرصيد (إجمالي الأرباح − المسحوب) |
| `total_earning` / `total_withdrawn` / `pending_withdraw` | إحصاءات الأرباح |
| `withdraw_able_balance` | الرصيد القابل للسحب |
| `Payable_Balance` | المبلغ المستحق دفعه للإدارة |
| `adjust_able` | هل يمكن عمل تسوية |
| `show_pay_now_button` | إظهار زر الدفع الآن |
| `over_flow_warning` / `over_flow_block_warning` | تحذيرات تجاوز حد النقد |
| `dm_max_cash_in_hand` | الحد الأقصى للنقد باليد |
| `todays_earning` / `this_week_earning` / `this_month_earning` | الأرباح |
| `total_incentive_earning` / `incentive_list` | الحوافز |
| `shift_id`, `shift_name`, `shift_start_time`, `shift_end_time`, `shifts` | الورديات |
| `topic` | موضوعات FCM |

### الدفع النقدي المحصَّل (Pay Now)

`POST /delivery-man/make-collected-cash-payment?token={token}`

```json
{
  "payment_gateway": "stripe",
  "amount": "100.00",
  "callback": "https://example.com/callback"
}
```
يرجع `redirect_link` لفتح بوابة الدفع. الحد الأدنى `min_amount_to_pay_dm`.

### تسوية المحفظة

`POST /delivery-man/make-wallet-adjustment?token={token}` — بدون Body؛ يخصم النقد المحصَّل مقابل الأرباح.

### سجل الحركات

| الطريقة | المسار | الوصف |
|---|---|---|
| GET | `/delivery-man/wallet-payment-list` | حركات التحصيل (`limit`, `offset`, `search`) |
| GET | `/delivery-man/wallet-provided-earning-list` | حركات التسوية |
| GET | `/delivery-man/get-disbursement-report` | تقرير السحب (`limit`, `offset`) |

### طرق السحب

| الطريقة | المسار | Body |
|---|---|---|
| GET | `/delivery-man/get-withdraw-method-list` | — |
| GET | `/delivery-man/withdraw-method/list` | `limit`, `offset`, `search` |
| POST | `/delivery-man/withdraw-method/store` | `withdraw_method_id` + حقول الطريقة (مثال `account_no`) |
| POST | `/delivery-man/withdraw-method/make-default` | `{ "id", "is_default": 1 }` |
| DELETE | `/delivery-man/withdraw-method/delete` | `{ "id" }` |

> حقول طريقة السحب تأتي ديناميكيًا من `method_fields` الخاص بالطريقة. `dm_disbursement_waiting_time` يحدّد مدة الانتظار قبل اكتمال السحب.

---

## 11. الرسائل (Chat)

| الطريقة | المسار | Body/Query |
|---|---|---|
| GET | `/delivery-man/message/list` | `limit`, `offset`, `type` (اختياري: `customer` \| `vendor`) |
| GET | `/delivery-man/message/search-list` | `name` (مطلوب), `type`, `limit`, `offset` |
| GET | `/delivery-man/message/details` | `conversation_id` أو `vendor_id` أو `user_id` + `limit`, `offset` |
| POST | `/delivery-man/message/send` | `message` + (`conversation_id` أو `receiver_id` + `receiver_type`) + `image[]` (اختياري) |

**مثال `message/send`:**
```json
{
  "receiver_id": 12,
  "receiver_type": "customer",
  "message": "أنا في الطريق إليك"
}
```

> `receiver_type` = `customer` أو `vendor`. `status: true` في الرد يعني أن هناك طلبًا جاريًا بين الطرفين (يسمح بالشات المرتبط بالطلب).

---

## 12. إدارة الحساب

| العملية | الطريقة | المسار |
|---|---|---|
| عرض الملف | GET | `/delivery-man/profile` |
| تعديل الملف | PUT | `/delivery-man/update-profile` |
| حذف الحساب | DELETE | `/delivery-man/remove-account` |

**`update-profile` Body:**

| الحقل | مطلوب | ملاحظات |
|---|---|---|
| `f_name`, `l_name` | نعم | — |
| `email` | نعم | فريد (باستثناء صاحب الحساب) |
| `password` | لا | إن أُرسلت يجب أن تحقق سياسة القوة |
| `image` | لا | max 2048KB |
| `vehicle_id` | لا | — |
| `shifts` | لا | JSON array |

**شروط حذف الحساب:** لا توجد طلبات جارية (`pending, accepted, confirmed, processing, handover, picked_up`) ولا نقد محصَّل `collected_cash > 0`، وإلا يرجع `203` مع رسالة.

---

## 13. مرجع كامل لـ API Endpoints

> جميع الردود مغلّفة بـ `{ success, message, result, code }`. أدناه نعرض محتوى `result` فقط.

### 13.1 المصادقة

| # | الطريقة | المسار | توكن | Body |
|---|---|---|---|---|
| 1 | POST | `/auth/delivery-man/login` | لا | `phone`, `password` |
| 2 | POST | `/auth/delivery-man/store` | لا | بيانات التسجيل |
| 3 | POST | `/auth/delivery-man/forgot-password` | لا | `phone` |
| 4 | POST | `/auth/delivery-man/verify-token` | لا | `phone`, `reset_token` |
| 5 | PUT | `/auth/delivery-man/reset-password` | لا | `phone`, `reset_token`, `password`, `confirm_password` |
| 6 | POST | `/auth/delivery-man/firebase-verify-token` | لا | `sessionInfo`, `phoneNumber`, `code` |

### 13.2 الملف والحالة

| # | الطريقة | المسار | توكن | ملاحظات |
|---|---|---|---|---|
| 7 | GET | `/delivery-man/profile` | نعم | كل إحصاءات المندوب والمحفظة والورديات |
| 8 | PUT | `/delivery-man/update-profile` | نعم | تعديل البيانات |
| 9 | POST | `/delivery-man/update-active-status` | نعم | تبديل online/offline |
| 10 | PUT | `/delivery-man/update-fcm-token` | نعم | `fcm_token` |
| 11 | DELETE | `/delivery-man/remove-account` | نعم | حذف الحساب |
| 12 | GET | `/delivery-man/notifications` | نعم | إشعارات آخر 7 أيام |
| 13 | GET | `/delivery-man/dm-topic` | نعم | موضوعات FCM |
| 14 | GET | `/delivery-man/dm-shift` | نعم | الورديات المتاحة للمندوب |

### 13.3 الموقع

| # | الطريقة | المسار | توكن | Body/Query |
|---|---|---|---|---|
| 15 | POST | `/delivery-man/record-location-data` | نعم | `longitude`, `latitude`, `location` |
| 16 | GET | `/delivery-man/last-location` | لا | `order_id` |
| 17 | GET | `/delivery-man/order-delivery-history` | نعم | `order_id` |

### 13.4 الطلبات

| # | الطريقة | المسار | توكن | Body/Query |
|---|---|---|---|---|
| 18 | GET | `/delivery-man/current-orders` | نعم | `status` (اختياري) |
| 19 | GET | `/delivery-man/latest-orders` | نعم | `limit`, `offset` |
| 20 | GET | `/delivery-man/all-orders` | نعم | `limit`, `offset`, `status` (اختياري) |
| 21 | GET | `/delivery-man/order` | نعم | `order_id` |
| 22 | GET | `/delivery-man/order-details` | نعم | `order_id` |
| 23 | PUT | `/delivery-man/accept-order` | نعم | `order_id`, `lat`, `lng` |
| 24 | PUT | `/delivery-man/update-order-status` | نعم | `order_id`, `status`, `reason`, `otp`, `order_proof[]` |
| 25 | PUT | `/delivery-man/update-payment-status` | نعم | `order_id`, `status=paid` |
| 26 | PUT | `/delivery-man/send-order-otp` | نعم | `order_id` |

**مثال 23 — `accept-order`:**
```json
{ "order_id": 100, "lat": "23.8103", "lng": "90.4125" }
```

**مثال 24 — `update-order-status`:**
```json
{
  "order_id": 100,
  "status": "delivered",
  "otp": "4821",
  "reason": ""
}
```
- `status` ∈ `confirmed | canceled | picked_up | delivered`.
- `reason` مطلوب عند `canceled`.
- `otp` مطلوب عند `delivered` إذا `order_delivery_verification = 1`.
- `order_proof[]` صور إثبات التسليم (حتى 5).

**شكل `result` في 18/19/20:**
```json
{
  "total_size": 5,
  "limit": 20,
  "offset": 1,
  "orders": [ { "id": 100, "order_status": "picked_up", "delivery_address": {}, "...": "..." } ],
  "order_count": { "accepted": 1, "confirmed": 0, "all": 3 }
}
```

### 13.5 التقييمات

| # | الطريقة | المسار | توكن | Body |
|---|---|---|---|---|
| 27 | GET | `/delivery-man/reviews/{delivery_man_id}` | نعم (Bearer) | — |
| 28 | GET | `/delivery-man/reviews/rating/{delivery_man_id}` | نعم | — |
| 29 | POST | `/delivery-man/reviews/submit` | نعم (Bearer) | `delivery_man_id`, `order_id`, `comment`, `rating` (≤5), `attachment[]` |

### 13.6 المحفظة والسحب

| # | الطريقة | المسار | توكن | Body/Query |
|---|---|---|---|---|
| 30 | POST | `/delivery-man/make-collected-cash-payment` | نعم | `payment_gateway`, `amount`, `callback` |
| 31 | POST | `/delivery-man/make-wallet-adjustment` | نعم | — |
| 32 | GET | `/delivery-man/wallet-payment-list` | نعم | `limit`, `offset`, `search` |
| 33 | GET | `/delivery-man/wallet-provided-earning-list` | نعم | `limit`, `offset`, `search` |
| 34 | GET | `/delivery-man/get-disbursement-report` | نعم | `limit`, `offset` |
| 35 | GET | `/delivery-man/get-withdraw-method-list` | نعم | — |
| 36 | GET | `/delivery-man/withdraw-method/list` | نعم | `limit`, `offset`, `search` |
| 37 | POST | `/delivery-man/withdraw-method/store` | نعم | `withdraw_method_id`, حقول الطريقة |
| 38 | POST | `/delivery-man/withdraw-method/make-default` | نعم | `id`, `is_default` |
| 39 | DELETE | `/delivery-man/withdraw-method/delete` | نعم | `id` |

### 13.7 الرسائل

| # | الطريقة | المسار | توكن | Body/Query |
|---|---|---|---|---|
| 40 | GET | `/delivery-man/message/list` | نعم | `limit`, `offset`, `type` |
| 41 | GET | `/delivery-man/message/search-list` | نعم | `name`, `type`, `limit`, `offset` |
| 42 | GET | `/delivery-man/message/details` | نعم | `conversation_id` أو `vendor_id` أو `user_id` |
| 43 | POST | `/delivery-man/message/send` | نعم | `message`, `conversation_id`/`receiver_id`+`receiver_type` |

### 13.8 مسارات عامة يحتاجها التطبيق

| # | الطريقة | المسار | الوصف |
|---|---|---|---|
| 44 | GET | `/config` | إعدادات التطبيق (مهم: `order_delivery_verification`, `show_dm_earning`, `dm_picture_upload_status`, `app_minimum_version_android_deliveryman`...) |
| 45 | GET | `/config/get-zone-id?lat=&lng=` | تحديد المنطقة، يرجع `zone_id`, `zone_data` |
| 46 | GET | `/get-vehicles` | المركبات |
| 47 | GET | `/dm-shifts` | الورديات النشطة |
| 48 | GET | `/get-PaymentMethods` | طرق الدفع |
| 49 | GET | `/zone/list` | المناطق |
| 50 | POST | `https://haatapp.com/broadcasting/auth` | تصريح Pusher |

---

## 14. أكواد الأخطاء الشائعة

### بنية الخطأ

```json
{
  "success": false,
  "message": "رسالة الخطأ",
  "result": [ { "code": "auth-001", "message": "User credentials does not match." } ],
  "code": 401
}
```

### أكواد حالة HTTP

| الكود | المعنى |
|---|---|
| 200 | نجاح |
| 203 | تحذير منطقي (مثل تجاوز حد النقد) |
| 401 | توكن خاطئ/مفقود أو بيانات دخول خاطئة |
| 403 | فشل تحقق، أو غير مسموح (مثل الإلغاء أو OTP) |
| 404 | العنصر غير موجود |
| 405 | تجاوز حد (طلبات كثيرة / كثير محاولات OTP) |
| 406 | OTP غير مطابق |
| 503 | تطبيق المندوب غير مفعّل (actch) |

### أكواد منطقية مهمّة

| الكود | السياق |
|---|---|
| `auth-001` | بيانات الدخول غير صحيحة |
| `auth-003` | الحساب غير معتمد/موقوف |
| `dm_out_of_zone` | خارج نطاق الخدمة |
| `dm_maximum_order_exceed` | تجاوز أقصى عدد طلبات |
| `dm_max_cash_in_hand` | تجاوز حد النقد باليد |
| `order` | الطلب غير موجود/لا يمكن قبوله |
| `otp` | رمز التسليم غير مطابق |
| `order-confirmation-model` | تأكيد الطلب من صلاحية المطعم |
| `status` | الإلغاء من المندوب غير مسموح |
| `on-going` | لا يمكن حذف الحساب لوجود طلبات/رصيد |

---

## 15. قائمة التحقق قبل التسليم

- [ ] `Content-Type: application/json` + `Accept: application/json` على كل الطلبات.
- [ ] إرسال التوكن مرتين: `?token={token}` + `Authorization: Bearer {token}`.
- [ ] تحديث `fcm_token` والاشتراك في كل `topic` القادمة من `profile`.
- [ ] بدء `record-location-data` كل 10–30 ثانية عند الاتصال.
- [ ] الاشتراك في `private-deliveryman.{id}` للشات والتحديثات اللحظية.
- [ ] احترام سياسة كلمة المرور (8+، حروف كبيرة/صغيرة، أرقام، رموز).
- [ ] معالجة `application_status = pending` بشاشة "قيد المراجعة".
- [ ] معالجة `active=0` بشاشة "الحساب موقوف".
- [ ] قراءة `order_delivery_verification` من `/config` لإظهار/إخفاء حقل OTP.
- [ ] قراءة `dm_picture_upload_status` قبل إلزام صورة إثبات التسليم.
- [ ] التعامل مع `over_flow_warning` / `over_flow_block_warning` في الملف الشخصي.
- [ ] عدم محاولة القبول عند بلوغ `current_orders >= dm_maximum_orders`.
- [ ] دعم `X-localization: ar` للترجمة العربية.

---

### ملفات مرجعية داخل المشروع

| الملف | الوصف |
|---|---|
| `API_DOCS.md` | توثيق عام موحّد لكل الأدوار |
| `API_REQUESTS_GUIDE.md` | دليل أمثلة الطلبات |
| `api_collection.json` | مجموعة Postman جاهزة (متغيّرات: `base_url`, `dm_token`) |
| `VENDOR_APP_GUIDE.md` | دليل تطبيق المتجر (مرجع أسلوبي) |
| `routes/api/v1/api.php` | المصدر الرسمي لمسارات الـ API |
