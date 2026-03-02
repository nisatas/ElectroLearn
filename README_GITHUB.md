# ElectroLearn

ElectroLearn, elektrik ve elektroniği (Arduino, breadboard odaklı) adım adım öğreten **Duolingo tarzı** bir mobil uygulamadır. Hedef kitle: ortaokul, lise ve başlangıç üniversite.

![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

---

## Özellikler

- **Konular, Testler, Projeler** – Ana ekranda ayrı bölümler; her konunun alt başlıkları listelenir.
- **Ders kartları** – Sesli okuma (TTS), mini görev listesi.
- **Quiz** – Çoktan seçmeli / doğru-yanlış, açıklamalı sorular, XP kazanımı.
- **Devre simülasyonu** – Test sonrası "Devreyi kur": WebView'da JavaScript + HTML5 Canvas ile kablo bağlama, LED'i yakma.
- **Rozetler** – Beceri tamamlandıkça profil sayfasında rozetler (LED Master, Trafik Lambası Projesi vb.).
- **Profil** – XP, seri (streak), tamamlanan konular, rozetler, giriş/kayıt (Supabase).

---

## Teknoloji yığını

| Amaç | Dil / Teknoloji |
|------|-----------------|
| Uygulama arayüzü | Flutter (Dart) |
| Devre simülasyonu | JavaScript |
| Devre çizimi | HTML5 Canvas |
| Kod editörü (planlanan) | Monaco Editor (JS) |
| Backend / Auth | Supabase |

Detay: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Kurulum ve çalıştırma

1. **Projeyi klonlayın** (veya indirin).
2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Çalıştırın:**
   ```bash
   flutter run
   ```
   Emülatör veya bağlı cihaz otomatik seçilir; farklı cihaz için: `flutter run -d <device_id>`.

### Supabase (opsiyonel)

Giriş/kayıt kullanmak için `lib/app/supabase_config.dart` dosyasında `supabaseUrl` ve `supabaseAnonKey` değerlerini kendi Supabase projenizden doldurun. Değerler `YOUR_` ile başlıyorsa uygulama kimlik doğrulama olmadan (misafir) çalışır.

---

## Dokümantasyon

- **[Wiki](docs/WIKI.md)** – Özellikler, kullanıcı akışı, proje yapısı, içerik formatı, yapılandırma ve genişletme rehberi.
- **[Mimari](docs/ARCHITECTURE.md)** – Teknoloji seçimleri, Flutter–JS entegrasyonu, dosya yapısı.

---

## Proje yapısı (kısa)

```
lib/
  app/          # Tema, renkler, router, provider'lar, rozet/devre config
  domain/       # Modeller (course, lesson, question, badge, progress, circuit)
  data/         # İçerik (unit1.json), ilerleme (Hive)
  features/     # Auth, home, lesson, quiz, result, profile, circuit
  shared/       # Ortak widget'lar ve servisler (TTS)
assets/
  content/      # unit1.json
  circuit_simulator/   # index.html (devre simülasyonu)
docs/
  WIKI.md       # Detaylı wiki
  ARCHITECTURE.md
```

---

## Lisans

Bu proje eğitim amaçlıdır. Kullanım koşulları proje sahibine aittir.
