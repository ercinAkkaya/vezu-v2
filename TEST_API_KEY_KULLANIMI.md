# Test API Key ile Abonelik Test Rehberi

## 🎯 Hızlı Başlangıç

### 1. Debug Modda Çalıştır

**Android Studio'da:**
```
1. Uygulamayı aç
2. Cihazını bağla (veya emulator aç)
3. "Run" butonuna bas (yeşil play butonu)
4. DEBUG modda çalışacak - Test API key kullanılacak
```

### 2. Test API Key Kontrolü

`lib/main.dart` dosyasında şu satırlar olmalı:

```dart
const revenueCatApiKey = kDebugMode 
    ? 'test_lQruLqRgYNxAuDDyhDtuinudPQL' // Debug için - PARA ÇEKMEZ!
    : 'goog_ifBWZzvGcsbWBsIhLAcWaOHhgAG'; // Production anahtarı
```

**Debug modda çalıştırıyorsan:**
- ✅ Test API key (`test_...`) kullanılacak
- ✅ PARA ÇEKİLMEZ
- ✅ Logcat'te göreceksin: `[RevenueCat] Başarıyla yapılandırıldı. Mod: DEBUG (Test Key)`

---

## 📋 Test Adımları

### Adım 1: Uygulamayı Aç ve Giriş Yap

1. Uygulamayı debug modda çalıştır
2. Google ile giriş yap
3. Ana sayfaya gel

### Adım 2: Paywall Sayfasına Git

**Yol 1: Limit aşıldığında**
- Free plan ile 15. kıyafet eklemeye çalış → Paywall açılır
- Free plan ile 3 kombin oluştur, 4. kombin → Paywall açılır

**Yol 2: Manuel olarak**
- Kod değiştirmen gerekir (profile page'e buton ekle) veya
- Firebase'de `totalClothes: 16` yap → Limit aşılmış olur → Paywall gösterilir

### Adım 3: Ürünleri Görüntüle

Paywall sayfası açıldığında:

1. **Logcat'i aç** (Android Studio alt kısım)
2. **Filter**: `RevenueCat` veya `Purchases` yaz
3. Şu logları görmelisin:

```
D/[Purchases] - DEBUG: 💰 Products request finished for vezu_monthly_premium, vezu_monthly_pro, vezu_yearly
D/[Purchases] - DEBUG: 💰 Retrieved productDetailsList: ...
I/flutter: Package found: vezu_monthly_premium
I/flutter:   Product ID: vezu_monthly_premium:vezu-monthly-premium
I/flutter:   Price: ₺139,99
I/flutter:   Currency Code: TRY
```

**Eğer bu logları görmüyorsan:**
- ❌ RevenueCat yapılandırması eksik
- ❌ Google Play Console'da ürünler aktif değil
- ❌ RevenueCat Dashboard'da offerings yapılandırılmamış

### Adım 4: Fiyatları Kontrol Et

Paywall sayfasında:
- ✅ Premium plan fiyatı görünmeli (ör: ₺139,99)
- ✅ Pro plan fiyatı görünmeli (ör: ₺199,99)
- ✅ Yearly Pro plan fiyatı görünmeli (ör: ₺1.999,99)

**Eğer fiyatlar görünmüyorsa:**
- Logcat'te hata var mı kontrol et
- RevenueCat Dashboard'da products kontrol et

### Adım 5: Test Satın Alma Yap

1. Bir plan seç (örn: Premium)
2. "Abone Ol" veya "Satın Al" butonuna bas
3. Google Play ödeme dialog'u açılmalı
4. **Test satın alma yap:**
   - Google hesabın test kullanıcısı olarak ekli olmalı
   - Google Play Console > Setup > License Testing
   - Kendi Gmail adresini ekle

5. **Test satın alma tamamlandığında:**
   - ✅ Para çekilmez (test işlem)
   - ✅ Firebase'de `subscriptionPlan: 'premium'` olmalı
   - ✅ RevenueCat Dashboard'da test işlem görünmeli

---

## 🔍 Debug Kontrolleri

### Logcat'te Kontrol Et

**Android Studio'da:**
1. Alt kısımda **Logcat** sekmesine tıkla
2. **Filter** kısmına yaz:
   - `RevenueCat` - RevenueCat logları
   - `Purchases` - Satın alma logları
   - `flutter` - Flutter logları

**Aradığın loglar:**
```
[RevenueCat] Başarıyla yapılandırıldı. Mod: DEBUG (Test Key)
Package found: vezu_monthly_premium
  Product ID: vezu_monthly_premium:vezu-monthly-premium
  Price: ₺139,99
```

### Firebase Firestore'da Kontrol Et

1. Firebase Console: https://console.firebase.google.com
2. **Firestore Database** > `users/{userId}` dokümanını aç
3. Şunları kontrol et:
   ```json
   {
     "subscriptionPlan": "premium",
     "subscriptionStartDate": "...",
     "subscriptionEndDate": "...",
     "totalClothes": 10,
     "monthlyCombinationsUsed": 3
   }
   ```

### RevenueCat Dashboard'da Kontrol Et

1. RevenueCat Dashboard: https://app.revenuecat.com
2. **Customers** menüsüne git
3. Kullanıcını bul (e-posta veya Firebase user ID ile)
4. **Customer Info**'da:
   - ✅ Active entitlements: `vezu_monthly_premium` olmalı
   - ✅ Purchases: Test işlem görünmeli (yeşil "TEST" badge'i)

---

## ⚠️ Sorun Giderme

### Sorun 1: "No offerings found"

**Çözüm:**
1. RevenueCat Dashboard'da:
   - **Offerings** > Default Offering > **Current** olarak işaretle
   - Package'ların doğru tanımlı olduğundan emin ol

### Sorun 2: "Missing productDetails"

**Çözüm:**
1. Google Play Console'da:
   - **Monetize > Subscriptions**
   - Her product için:
     - Base plan **aktif** olmalı
     - Pricing **tanımlı** olmalı
     - Availability → **Test groups** aktif olmalı

### Sorun 3: Fiyatlar görünmüyor

**Çözüm:**
1. Logcat'te hata var mı kontrol et
2. Package identifier'ların doğru olduğundan emin ol
3. RevenueCat Dashboard'da products kontrol et

### Sorun 4: Test satın alma yapılamıyor

**Çözüm:**
1. Google Play Console > Setup > License Testing
2. Kendi Gmail adresini **License testers** listesine ekle
3. Uygulamayı kapat ve yeniden aç
4. Google hesabının test kullanıcısı olduğundan emin ol

---

## ✅ Test Checklist

- [ ] Debug modda çalıştırıldı (Test API key kullanılıyor)
- [ ] Logcat'te RevenueCat yapılandırma logu görünüyor
- [ ] Paywall sayfası açılıyor
- [ ] Ürünler görünüyor (Premium, Pro, Yearly Pro)
- [ ] Fiyatlar görünüyor (₺139,99, ₺199,99, vb.)
- [ ] Test satın alma yapılabiliyor
- [ ] Para çekilmedi (test işlem)
- [ ] Firebase'de subscription güncellendi
- [ ] RevenueCat Dashboard'da test işlem görünüyor

---

## 📝 Özet

**Test API key ile test etmek için:**

1. ✅ DEBUG modda çalıştır (Android Studio'dan Run)
2. ✅ Paywall sayfasına git (limit aş veya manuel)
3. ✅ Logcat'i kontrol et (ürünler yükleniyor mu?)
4. ✅ Fiyatları gör (paywall sayfasında)
5. ✅ Test satın alma yap (Google Play test kullanıcısı olarak)
6. ✅ Kontrol et (Firebase + RevenueCat Dashboard)

**Önemli:**
- Debug modda çalıştırırsan → Test API key kullanılır → PARA ÇEKİLMEZ
- Release build (dahili test) → Production API key kullanılır → Test kullanıcısı olarak eklenirse para çekilmez

---

## 🆘 Hala Çalışmıyorsa

1. Logcat'teki hata mesajını kontrol et
2. RevenueCat Dashboard'da offerings kontrol et
3. Google Play Console'da products kontrol et
4. Firebase'de user dokümanını kontrol et
5. Test kullanıcısı olarak eklendiğinden emin ol
