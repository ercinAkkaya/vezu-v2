# RevenueCat Sandbox Test Yapılandırması

## 🎯 Sandbox Test için Yapılması Gerekenler

### 1. RevenueCat Dashboard - Sandbox API Key Kontrolü

#### Adım 1: Sandbox API Key'i Al
1. RevenueCat Dashboard'a git: https://app.revenuecat.com
2. **Project Settings** > **API Keys** menüsüne git
3. **Public SDK Key (Sandbox)** key'ini bul ve kopyala
   - Format: `test_XXXXXXXXXXXXXXXXXX`
   - Bu key test ortamı için kullanılır

#### Adım 2: Sandbox API Key'i Kod'a Ekle
`lib/main.dart` dosyasında:

```dart
const revenueCatApiKey = kDebugMode 
    ? 'test_YOUR_SANDBOX_API_KEY_HERE' // Sandbox key (test için)
    : 'goog_ifBWZzvGcsbWBsIhLAcWaOHhgAG'; // Production key (release için)
```

---

### 2. RevenueCat Dashboard - Sandbox Offerings Yapılandırması

#### ÖNEMLİ: Sandbox ve Production Offerings Farklıdır!

**Sandbox test için ayrı offerings yapılandırman gerekir.**

#### Adım 1: Sandbox Offerings Oluştur
1. RevenueCat Dashboard > **Offerings** menüsüne git
2. **Sandbox Mode** veya **Test Mode** seçeneğini bul
   - Bazı RevenueCat planlarında sandbox mode ayrı bir sekme olabilir
   - Eğer yoksa, mevcut offerings'i sandbox için de kullanabilirsin

#### Adım 2: Default Offering'i Current Yap
1. **Offerings** > **Default Offering** (veya ana offering'in)
2. **Current** butonuna tıkla (aktif hale getir)
3. Sandbox test için bu offering kullanılacak

#### Adım 3: Packages Yapılandırması
Her offering için package'ları kontrol et:

**Her Package için:**
1. **Package Identifier**: Örn: `vezu_monthly_premium`
2. **Product ID**: Google Play Console'daki product ID ile eşleşmeli
   - Örn: `vezu_monthly_premium` veya `vezu-monthly-premium`
3. **Package Type**: Monthly, Annual, vb.

**Package Örnekleri:**
- `vezu_monthly_premium` → Product ID: `vezu_monthly_premium`
- `vezu_monthly_pro` → Product ID: `vezu_monthly_pro`
- `vezu_yearly` → Product ID: `vezu_yearly` (veya `vezu_yearly_pro_v2`)

---

### 3. RevenueCat Dashboard - Sandbox Products Kontrolü

#### Adım 1: Products Yapılandırması
1. RevenueCat Dashboard > **Products** menüsüne git
2. Her product için kontrol et:

**Product ID'ler:**
- `vezu_monthly_premium` ✅
- `vezu_monthly_pro` ✅
- `vezu_yearly` (veya `vezu_yearly_pro_v2`) ✅

**Her Product için:**
- ✅ **Platform > Android** aktif olmalı
- ✅ **Product ID** Google Play Console ile eşleşmeli
- ✅ **Entitlements** bağlı olmalı

#### Adım 2: Entitlements Yapılandırması
1. **Entitlements** menüsüne git
2. Her entitlement için:

**Entitlement ID'ler:**
- `vezu_monthly_premium` → Product: `vezu_monthly_premium`
- `vezu_monthly_pro` → Product: `vezu_monthly_pro`
- `vezu_yearly` → Product: `vezu_yearly`

**Kontrol:**
- ✅ Entitlement ID'ler product ID'ler ile eşleşmeli
- ✅ Products entitlement'lara bağlı olmalı

---

### 4. Google Play Console - Sandbox Test Ürünleri

#### Adım 1: Test Ürünlerini Kontrol Et
1. Google Play Console: https://play.google.com/console
2. **Monetize > Subscriptions** menüsüne git
3. Her product için:

**Product Kontrolleri:**
- ✅ Product **Active** olmalı
- ✅ **Base Plan** aktif olmalı
- ✅ **Pricing** tanımlı olmalı
- ✅ **Availability** → Test groups aktif olmalı

#### Adım 2: Test Kullanıcısı Ekle (Önerilen)
1. **Setup > License Testing** menüsüne git
2. **License testers** bölümüne kendi Gmail adresini ekle
3. Bu sayede test satın almaları para çekmeden yapılabilir

---

### 5. Kod Yapılandırması

#### Adım 1: Test API Key'i Aktif Et
`lib/main.dart` dosyasında:

```dart
const revenueCatApiKey = kDebugMode 
    ? 'test_lQruLqRgYNxAuDDyhDtuinudPQL' // Sandbox key - aktive et
    : 'goog_ifBWZzvGcsbWBsIhLAcWaOHhgAG'; // Production key
```

**Önemli:** `test_` ile başlayan key sandbox için kullanılır.

#### Adım 2: Loglama Kontrolü
Kod çalıştığında Logcat'te görmen gerekenler:

```
[RevenueCat] API Key Type: TEST/SANDBOX
[RevenueCat] ✅ Başarıyla yapılandırıldı. Mod: DEBUG
[RevenueCat] API Key Type: TEST/SANDBOX - Sandbox offerings gerekiyor!
```

---

### 6. Test Etme Adımları

#### Adım 1: Uygulamayı Debug Modda Çalıştır
1. Android Studio'da **Run** butonuna bas
2. Debug modda çalışacak → Sandbox API key kullanılacak

#### Adım 2: Logcat'i Kontrol Et
Logcat'te şu logları ara:

```
[RevenueCat] API Key Type: TEST/SANDBOX
[RevenueCatService] Fetching offerings...
[RevenueCatService] ✅ Offerings fetched successfully
```

#### Adım 3: Paywall Sayfasına Git
1. Limit aşıldığında paywall gösterilir
2. Veya manuel olarak subscription sayfasına git

#### Adım 4: Ürünleri Kontrol Et
Logcat'te şunları görmelisin:

```
[SubscriptionPage] Starting to load prices...
[RevenueCatService] Current offering: default (veya offering adı)
[RevenueCatService] Available packages count: 3
Package found: vezu_monthly_premium
  Product ID: vezu_monthly_premium
  Price: ₺139,99
```

#### Adım 5: Test Satın Alma Yap
1. Bir plan seç
2. Satın al butonuna bas
3. Google Play ödeme dialog'u açılır
4. **Test satın alma** yap (para çekilmez)

---

### 7. Yaygın Sorunlar ve Çözümleri

#### Sorun 1: "No offerings found in all map"

**Çözüm:**
1. RevenueCat Dashboard > **Offerings**
2. **Default Offering** > **Current** olarak işaretle
3. Package'ların doğru tanımlı olduğundan emin ol

#### Sorun 2: "Missing productDetails"

**Çözüm:**
1. Google Play Console > **Monetize > Subscriptions**
2. Her product için:
   - Base plan **aktif** olmalı
   - Pricing **tanımlı** olmalı
   - Availability → **Test groups** aktif olmalı

#### Sorun 3: Sandbox API key çalışmıyor

**Çözüm:**
1. RevenueCat Dashboard > **Project Settings > API Keys**
2. **Public SDK Key (Sandbox)** key'ini doğru kopyaladığından emin ol
3. Key formatı: `test_XXXXXXXXXXXXXXXXXX` olmalı
4. Kod'da `test_` ile başladığından emin ol

#### Sorun 4: Offerings yükleniyor ama packages boş

**Çözüm:**
1. RevenueCat Dashboard > **Offerings** > **Default Offering**
2. **Packages** bölümünü kontrol et
3. Her package için:
   - Package identifier doğru olmalı
   - Product ID Google Play ile eşleşmeli
   - Product'lar entitlement'lara bağlı olmalı

#### Sorun 5: Test satın alma yapılamıyor

**Çözüm:**
1. Google Play Console > **Setup > License Testing**
2. Kendi Gmail adresini **License testers** listesine ekle
3. Uygulamayı kapat ve yeniden aç
4. Google hesabının test kullanıcısı olduğundan emin ol

---

### 8. Sandbox vs Production Farkları

| Özellik | Sandbox (Test API Key) | Production (Production API Key) |
|---------|------------------------|--------------------------------|
| API Key | `test_...` ile başlar | `goog_...` ile başlar |
| Offerings | Sandbox offerings | Production offerings |
| Satın Alma | Test işlem (para çekilmez) | Gerçek işlem (para çekilir) |
| Dashboard | Test işlemler yeşil "TEST" badge'i ile işaretlenir | Normal işlemler |
| Kullanım | Development/Testing | Production/Release |

---

### 9. Kontrol Listesi

**RevenueCat Dashboard:**
- [ ] Sandbox API key kopyalandı (`test_...`)
- [ ] Sandbox API key kod'a eklendi
- [ ] Default Offering **Current** olarak işaretlendi
- [ ] Packages doğru tanımlı (vezu_monthly_premium, vezu_monthly_pro, vezu_yearly)
- [ ] Product ID'ler Google Play ile eşleşiyor
- [ ] Products entitlement'lara bağlı

**Google Play Console:**
- [ ] Products aktif
- [ ] Base plans aktif ve pricing tanımlı
- [ ] Availability → Test groups aktif
- [ ] License Testing'de test kullanıcısı eklendi

**Kod:**
- [ ] Test API key aktif (`test_...`)
- [ ] Logcat'te "TEST/SANDBOX" görünüyor
- [ ] Offerings başarıyla yükleniyor
- [ ] Packages görünüyor ve fiyatlar görünüyor

---

### 10. Test Sonrası

**Sandbox test tamamlandıktan sonra:**

1. **Production'a geçiş:**
   - `lib/main.dart`'ta production API key'i aktif et
   - Release build al
   - Google Play Console'da License Testing'i yapılandır

2. **Sandbox key'i tutmak için:**
   - Debug modda test API key kullanmaya devam et
   - Release build'de production API key kullan

---

## 📞 Destek

Sorun yaşarsan:
1. Logcat'teki hata mesajlarını kontrol et
2. RevenueCat Dashboard'da offerings kontrol et
3. Google Play Console'da products kontrol et
4. Test kullanıcısı olarak eklendiğinden emin ol

---

## ✅ Hızlı Başlangıç

1. ✅ RevenueCat Dashboard > Project Settings > API Keys > **Sandbox key** kopyala
2. ✅ `lib/main.dart` > Test API key'i aktif et (`test_...`)
3. ✅ RevenueCat Dashboard > Offerings > Default Offering > **Current** yap
4. ✅ Google Play Console > License Testing > **Test kullanıcısı ekle**
5. ✅ Uygulamayı **debug modda** çalıştır
6. ✅ Logcat'te **"TEST/SANDBOX"** göründüğünü kontrol et
7. ✅ Paywall sayfasına git ve **ürünleri kontrol et**
