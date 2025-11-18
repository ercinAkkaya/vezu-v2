# Firebase Security Rules - Abonelik Koruması

## ⚠️ KRİTİK: Bu rules'ları Firebase Console'da ayarlayın

## 📋 Önerilen Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Kullanıcı dokümanları
    match /users/{userId} {
      // Okuma: Sadece kendi kullanıcısı
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Yazma: Kendi kullanıcısı ANCAK kritik alanları değiştiremez
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && !request.resource.data.diff(resource.data).affectedKeys()
          .hasAny([
            'subscriptionPlan',           // Kullanıcı değiştiremez
            'subscriptionStartDate',       // Kullanıcı değiştiremez
            'subscriptionEndDate',         // Kullanıcı değiştiremez
            'subscriptionPeriodStartDate', // Kullanıcı değiştiremez
            'subscriptionPeriodEndDate',   // Kullanıcı değiştiremez
            'subscriptionLastRenewalDate', // Kullanıcı değiştiremez
            'monthlyCombinationsUsed',     // Kullanıcı değiştiremez
            'totalOutfitsCreated'          // Kullanıcı değiştiremez
          ]);
      
      // İzin verilen alanlar:
      // - firstName, lastName, age, gender
      // - profilePhotoUrl
      // - notificationEnabled
      // - deviceToken
    }
    
    // Garderobe items
    match /users/{userId}/wardrobe/{itemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Kaydedilmiş kombinler
    match /users/{userId}/saved_combinations/{combinationId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🔒 Güvenlik Açıklaması

### Korunan Alanlar:
1. **subscriptionPlan**: Premium/Pro/Free durumu
2. **subscriptionStartDate**: Abonelik başlangıç tarihi
3. **subscriptionEndDate**: Abonelik bitiş tarihi
4. **subscriptionPeriodStartDate**: Dönem başlangıcı
5. **subscriptionPeriodEndDate**: Dönem bitişi
6. **subscriptionLastRenewalDate**: Son yenileme
7. **monthlyCombinationsUsed**: Kullanılan kombin sayısı
8. **totalOutfitsCreated**: Toplam kombin sayısı

### Kullanıcının Değiştirebileceği Alanlar:
- ✅ firstName, lastName
- ✅ age, gender
- ✅ profilePhotoUrl
- ✅ notificationEnabled
- ✅ deviceToken

---

## 🧪 Test Senaryoları

### ✅ İzin Verilmesi Gereken:
```javascript
// Kullanıcı kendi profilini okuyabilir
firebase.firestore().collection('users').doc(currentUserId).get()

// Kullanıcı adını değiştirebilir
firebase.firestore().collection('users').doc(currentUserId).update({
  firstName: 'Yeni Ad'
})
```

### ❌ İzin Verilmemesi Gereken:
```javascript
// Kullanıcı abonelik planını değiştiremez
firebase.firestore().collection('users').doc(currentUserId).update({
  subscriptionPlan: 'premium' // ❌ BLOKE EDİLİR
})

// Kullanıcı kombin sayısını manipüle edemez
firebase.firestore().collection('users').doc(currentUserId).update({
  monthlyCombinationsUsed: 0 // ❌ BLOKE EDİLİR
})
```

---

## 🚀 Firebase Console'da Ayarlama

1. **Firebase Console'a Git**
   - https://console.firebase.google.com
   - Projenizi seçin

2. **Firestore Database**
   - Sol menüden "Firestore Database"
   - "Rules" sekmesi

3. **Rules'ları Yapıştır**
   - Yukarıdaki rules'ları kopyala
   - Yapıştır
   - "Publish" butonuna tıkla

4. **Test Et**
   - "Simulator" sekmesi
   - Test senaryolarını dene

---

## ⚠️ Önemli Notlar

1. **Admin SDK**: Backend'den (Cloud Functions veya Admin SDK) yazarken bu kurallar geçerli DEĞİLDİR
2. **Client SDK**: Flutter app'ten yazarken bu kurallar geçerlidir
3. **SubscriptionService**: Flutter app'ten çalıştığı için bu kuralları bypass edemez (GÜVENLİ)

---

## 🔍 Güvenlik Kontrolü

### Soru: SubscriptionService nasıl yazıyor o zaman?

**Cevap**: SubscriptionService zaten `subscriptionPlan` gibi alanları değiştirmiyor. Sadece okuyor:

```dart
// subscription_service.dart
await _firestore.collection('users').doc(userId).update({
  'subscriptionPlan': planId, // Bu Flutter app'ten çalışıyor
  // ...
});
```

**Sorun**: Bu update BAŞARISIZ OLACAK ❗

**Çözüm**: Backend'e taşı veya Cloud Functions kullan

---

## 🛠️ ÖNERİLEN MİMARİ

### Seçenek 1: Cloud Functions (ÖNERİLEN)

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.updateSubscription = functions.https.onCall(async (data, context) => {
  // Authentication kontrolü
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
  }
  
  const userId = context.auth.uid;
  const { planId, subscriptionStartDate, subscriptionEndDate } = data;
  
  // RevenueCat'ten doğrula (server-side)
  // ... RevenueCat API call
  
  // Firebase'e yaz (Admin SDK - rules bypass)
  await admin.firestore().collection('users').doc(userId).update({
    subscriptionPlan: planId,
    subscriptionStartDate: subscriptionStartDate,
    subscriptionEndDate: subscriptionEndDate,
    // ...
  });
  
  return { success: true };
});
```

### Seçenek 2: RevenueCat Webhook (EN GÜVENLİ)

```javascript
// functions/index.js
exports.revenueCatWebhook = functions.https.onRequest(async (req, res) => {
  // RevenueCat webhook signature doğrula
  // ...
  
  const event = req.body;
  const userId = event.app_user_id;
  
  // Event tipine göre işlem yap
  if (event.type === 'INITIAL_PURCHASE' || event.type === 'RENEWAL') {
    await admin.firestore().collection('users').doc(userId).update({
      subscriptionPlan: determinePlan(event),
      subscriptionStartDate: new Date(event.purchased_at_ms),
      subscriptionEndDate: new Date(event.expiration_at_ms),
      // ...
    });
  }
  
  res.status(200).send('OK');
});
```

---

## 🎯 Önerilen Implementasyon

### Kısa Vadeli (Hızlı Deploy):
```javascript
// Geçici olarak izin ver (güvenlik riski var ama çalışır)
allow write: if request.auth != null && request.auth.uid == userId;
```

### Uzun Vadeli (Güvenli):
1. Cloud Functions ekle
2. RevenueCat webhook kullan
3. Security rules'ları sıkılaştır

---

## ✅ Sonuç

**Şu an için**:
- Geçici olarak izinleri gevşet (yukarıdaki basit rule)
- Production'a deploy et
- Yakın zamanda Cloud Functions ekle

**İdeal**:
- Cloud Functions + RevenueCat Webhook
- Sıkı security rules
- Kullanıcı bypass yapamaz

