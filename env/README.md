# Environment Variables

1. Klasörün içinde `.env` dosyası oluştur.
2. Aşağıdaki yapıyı kullan:

```
GPT_API_KEY=sk-...
```

3. Yerel çalıştırma sırasında:

```
flutter run --dart-define=GPT_API_KEY=$GPT_API_KEY
```

```
flutter build apk --dart-define=GPT_API_KEY=$GPT_API_KEY
```

```
flutter build ios --dart-define=GPT_API_KEY=$GPT_API_KEY
```

> Not: `.env` dosyası `.gitignore` ile izleme dışı bırakıldı.

