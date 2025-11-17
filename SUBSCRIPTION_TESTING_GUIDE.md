# Abonelik Test Rehberi

## 🎯 Test Senaryoları

### 1. Google Play Console'da Test Hesabı Ayarlama

#### Adım 1: Test Kullanıcısı Ekle
1. Google Play Console'a giriş yap: https://play.google.com/console
2. Sol menüden **Setup > License Testing** seçin
3. **License testers** bölümünde test e-postalarını ekleyin
   - Kendi Gmail adresinizi ekleyin
   - Test edecek kişilerin e-postalarını ekleyin

#### Adım 2: Test Ürünlerini Kontrol Et
1. **Monetize > Subscriptions** menüsüne gidin
2. Her abonelik ürünü için:
   - ✅ **Base plans** aktif olmalı
   - ✅ **Pricing** tanımlı olmalı
   - ✅ **Availability** → Test gruplarında aktif olmalı
   - ✅ En az bir **price** tanımlı olmalı

#### Adım 3: Test Cihazı Ayarla
1. Android cihazınızda:
   - Google hesabınızı **test hesabı olarak** ekleyin
   - Uygulamayı Play Store'dan değil, **debug modda** yükleyin

---

### 2. RevenueCat Dashboard Kontrolleri

#### Adım 1: Offerings Kontrolü
1. RevenueCat Dashboard: https://app.revenuecat.com
2. **Projects > [Your Project] > Offerings** menüsüne gidin
3. **Default Offering**'i kontrol edin:
   - ✅ **Current** olarak işaretli olmalı
   - ✅ Package'lar doğru tanımlı olmalı
   - ✅ Product ID'ler Google Play ile eşleşmeli

#### Adım 2: Products Kontrolü
1. **Products** menüsüne gidin
2. Her product için:
   - ✅ **Product ID** Google Play ile eşleşmeli
   - ✅ **Entitlements** bağlı olmalı
   - ✅ **Platforms > Android** aktif olmalı

#### Adım 3: Entitlements Kontrolü
1. **Entitlements** menüsüne gidin
2. Her entitlement için:
   - ✅ Product'lar bağlı olmalı
   - ✅ Entitlement ID'ler kod ile eşleşmeli

---

### 3. Uygulamada Test Senaryoları

#### Senaryo 1: Yeni Kullanıcı - Free Plan
1. ✅ Uygulamayı ilk kez aç
2. ✅ Firebase'de `subscriptionPlan: 'free'` olduğunu kontrol et
3. ✅ `totalClothes: 0`, `monthlyCombinationsUsed: 0` olduğunu kontrol et
4. ✅ 15 kıyafet eklenebilmeli
5. ✅ 3 kombin oluşturulabilmeli

#### Senaryo 2: Premium Plan Satın Alma
1. ✅ Paywall sayfasına git
2. ✅ Fiyatlar görünüyor mu kontrol et
3. ✅ Premium planı seç
4. ✅ Satın alma işlemini tamamla
5. ✅ Firebase'de `subscriptionPlan: 'premium'` olduğunu kontrol et
6. ✅ 30 kıyafet eklenebilmeli
7. ✅ 15 kombin oluşturulabilmeli

#### Senaryo 3: Limit Kontrolü - Kıyafet Ekleme
1. ✅ Free plan ile 15 kıyafet ekle
2. ✅ 16. kıyafet eklemeye çalış
3. ✅ Paywall gösterilmeli
4. ✅ Snackbar mesajı görünmeli: "15/15 kıyafet limitine ulaştınız"

#### Senaryo 4: Limit Kontrolü - Kombin Oluşturma
1. ✅ Free plan ile 3 kombin oluştur
2. ✅ 4. kombin oluşturmaya çalış
3. ✅ Paywall gösterilmeli
4. ✅ Snackbar mesajı görünmeli: "Aylık kombin limitinize ulaştınız"

#### Senaryo 5: Kombin İçin Minimum 10 Kıyafet Kontrolü
1. ✅ 9 kıyafet ekle
2. ✅ Kombin oluşturmaya çalış
3. ✅ Buton disabled olmalı
4. ✅ Uyarı mesajı görünmeli: "En az 10 kıyafet olmalı"

#### Senaryo 6: RevenueCat Senkronizasyonu
1. ✅ Uygulamaya gir (subscription aktif olsa bile)
2. ✅ `syncSubscriptionFromRevenueCat()` çağrılmalı
3. ✅ Firebase'de subscription bilgileri güncellenmeli
4. ✅ `subscriptionStartDate`, `subscriptionEndDate` kontrol et

#### Senaryo 7: Abonelik İptal Etme
1. ✅ Google Play Console'da subscription'ı iptal et
2. ✅ RevenueCat'te durumu kontrol et
3. ✅ Uygulamada `syncSubscriptionFromRevenueCat()` çağrıldığında
4. ✅ `subscriptionPlan: 'free'` olmalı

---

### 4. Debug Log Kontrolleri

#### RevenueCat Log'ları
Uygulama çalışırken `logcat` veya debug console'da şunları görmelisiniz:

```
D/[Purchases] - DEBUG: 💰 Products request finished for vezu_monthly_premium, vezu_monthly_pro, vezu_yearly
D/[Purchases] - DEBUG: 💰 Retrieved productDetailsList: ...
I/[Purchases] - INFO: ℹ️ Offering retrieved successfully
```

#### Firebase Firestore Kontrolleri
`users/{userId}` dokümanında şunlar olmalı:

```json
{
  "subscriptionPlan": "premium",
  "totalClothes": 10,
  "totalOutfitsCreated": 5,
  "monthlyCombinationsUsed": 3,
  "monthlyCombinationsResetDate": "2024-01-01T00:00:00Z",
  "subscriptionStartDate": "2024-01-01T00:00:00Z",
  "subscriptionEndDate": "2024-02-01T00:00:00Z",
  "subscriptionPeriodStartDate": "2024-01-01T00:00:00Z",
  "subscriptionPeriodEndDate": "2024-02-01T00:00:00Z",
  "subscriptionLastRenewalDate": "2024-01-01T00:00:00Z"
}
```

---

### 5. Test API Key Kullanımı (Opsiyonel)

**✅ ÖNEMLİ: Test API key kullanıldığında PARA ÇEKİLMEZ!**

Şu anda production API key kullanılıyor. Test için 2 seçenek var:

#### Seçenek 1: Test (Sandbox) API Key Kullan (Önerilen)
1. RevenueCat Dashboard'da **Project Settings > API Keys** bölümünden
2. **Public SDK Key (Sandbox)** key'ini kopyalayın
3. `lib/main.dart` dosyasında:

```dart
// Test için - PARA ÇEKMEZ!
const revenueCatApiKey = 'test_YOUR_TEST_API_KEY_HERE';
```

**Avantajlar:**
- ✅ Kesinlikle para çekilmez
- ✅ Test satın almaları gerçek satın alma gibi görünür ama ücretlendirilmez
- ✅ RevenueCat Dashboard'da test işlemleri olarak işaretlenir

**Dezavantajlar:**
- ⚠️ Google Play Console'da ayrı test ürünleri tanımlamanız gerekebilir
- ⚠️ Test ortamında bazı özellikler sınırlı olabilir

#### Seçenek 2: Production API Key + Google Play License Testing
1. Production API key kullanmaya devam edin
2. Google Play Console'da **Setup > License Testing** bölümünden
3. Kendi Gmail adresinizi test kullanıcısı olarak ekleyin
4. Test satın almaları yapın (para çekilmez)

**Avantajlar:**
- ✅ Production ortamına daha yakın test
- ✅ Gerçek ürünlerle test yapılır
- ✅ Test kullanıcısı olarak eklenen hesaplar için para çekilmez

**Dezavantajlar:**
- ⚠️ Yanlışlıkla test kullanıcısı olmayan bir hesapla satın alırsanız para çekilebilir
- ⚠️ Dikkatli olmak gerekir

---

### 6. Yaygın Hatalar ve Çözümleri

#### Hata: "Missing productDetails"
**Çözüm:**
- Google Play Console'da product'ın **active** olduğundan emin ol
- Base plan'ın **pricing** tanımlı olduğundan emin ol
- RevenueCat'te product ID'nin doğru eşleştiğinden emin ol

#### Hata: "No packages found in offering"
**Çözüm:**
- RevenueCat Dashboard'da **Default Offering**'in **Current** olduğundan emin ol
- Package identifier'ların doğru olduğundan emin ol
- Product'ların entitlement'lara bağlı olduğundan emin ol

#### Hata: "Invalid API Key"
**Çözüm:**
- API key'in doğru olduğundan emin ol
- Platform'un (Android) doğru key olduğundan emin ol
- Key'in expired olmadığından emin ol

#### Hata: Firebase'de subscription güncellenmiyor
**Çözüm:**
- `syncSubscriptionFromRevenueCat()` fonksiyonunun çağrıldığından emin ol
- Firebase Firestore kurallarının yazmaya izin verdiğinden emin ol
- User ID'nin doğru olduğundan emin ol

---

### 7. Otomatik Test İçin Debug Page

Uygulamaya debug sayfası eklenebilir (opsiyonel):
- Subscription durumunu görüntüle
- Manuel senkronizasyon tetikle
- Limit kontrolü test et
- Test verilerini sıfırla

---

## ✅ Test Checklist

- [ ] Google Play Console'da test hesabı eklendi
- [ ] RevenueCat Dashboard'da offerings doğru yapılandırıldı
- [ ] Yeni kullanıcı free plan ile başlıyor
- [ ] Premium plan satın alınabiliyor
- [ ] Pro plan satın alınabiliyor
- [ ] Yearly Pro plan satın alınabiliyor
- [ ] Kıyafet limiti çalışıyor (15/30/50/70)
- [ ] Kombin limiti çalışıyor (3/15/20/30)
- [ ] Minimum 10 kıyafet kontrolü çalışıyor
- [ ] Paywall limit aşıldığında gösteriliyor
- [ ] Firebase'de subscription bilgileri güncelleniyor
- [ ] RevenueCat senkronizasyonu çalışıyor
- [ ] Abonelik iptal edildiğinde free plan'a dönüyor

---

## 📞 Destek

Sorun yaşarsanız:
1. Debug log'larını kontrol edin
2. RevenueCat Dashboard'da Customer Info'yu kontrol edin
3. Firebase Firestore'da user dokümanını kontrol edin
4. Google Play Console'da subscription durumunu kontrol edin
