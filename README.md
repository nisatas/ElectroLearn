# ElectroLearn

ElectroLearn, elektrik ve elektronii (Arduino, breadboard odakl1) ad1m ad1m öreten **Duolingo tarz1** bir mobil uygulamad1r. Hedef kitle: ortaokul, lise ve ba_lang1ç üniversite.

![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter)  
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

---

## Özellikler

- **Konular, Testler, Projeler**  Ana ekranda ayr1 bölümler; her konunun alt ba_l1klar1 listelenir.
- **Ders kartlar1**  Sesli okuma (TTS), mini görev listesi.
- **Quiz**  Çoktan seçmeli / doru-yanl1_, aç1klamal1 sorular, XP kazan1m1.
- **Devre simülasyonu**  Test sonras1 Devreyi kur: WebViewda JavaScript + HTML5 Canvas ile kablo balama, LEDi yakma.
- **Rozetler**  Beceri tamamland1kça profil sayfas1nda rozetler (LED Master, Trafik Lambas1 Projesi vb.).
- **Profil**  XP, seri (streak), tamamlanan konular, rozetler, giri_/kay1t (Supabase).

---

## Teknoloji y11n1

| Amaç               | Dil / Teknoloji   |
| ------------------ | ----------------- |
| Uygulama arayüzü   | Flutter (Dart)    |
| Devre simülasyonu  | JavaScript        |
| Devre çizimi       | HTML5 Canvas      |
| Kod editörü (planlanan) | Monaco Editor (JS) |
| Backend / Auth     | Supabase          |

Detay: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Kurulum ve çal1_t1rma

1. **Projeyi klonlay1n** (veya indirin).
2. **Ba1ml1l1klar1 yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Çal1_t1r1n:**
   ```bash
   flutter run
   ```
   Emülatör veya bal1 cihaz otomatik seçilir; farkl1 cihaz için: `flutter run -d <device_id>`.

### Supabase (opsiyonel)

Giri_/kay1t kullanmak için `lib/app/supabase_config.dart` dosyas1nda `supabaseUrl` ve `supabaseAnonKey` deerlerini kendi Supabase projenizden doldurun. Deerler `YOUR_` ile ba_l1yorsa uygulama kimlik dorulama olmadan (misafir) çal1_1r.

---

## Dokümantasyon

- **[Wiki](docs/WIKI.md)**  Özellikler, kullan1c1 ak1_1, proje yap1s1, içerik format1, yap1land1rma ve geni_letme rehberi.
- **[Mimari](docs/ARCHITECTURE.md)**  Teknoloji seçimleri, FlutterJS entegrasyonu, dosya yap1s1.

---

## Proje yap1s1 (k1sa)

```
lib/
  app/          # Tema, renkler, router, providerlar, rozet/devre config
  domain/       # Modeller (course, lesson, question, badge, progress, circuit)
  data/         # 0çerik (unit1.json), ilerleme (Hive)
  features/     # Auth, home, lesson, quiz, result, profile, circuit
  shared/       # Ortak widgetlar ve servisler (TTS)
assets/
  content/      # unit1.json
  circuit_simulator/   # index.html (devre simülasyonu)
docs/
  WIKI.md       # Detayl1 wiki
  ARCHITECTURE.md
```

---

## Lisans

Bu proje eitim amaçl1d1r. Kullan1m ko_ullar1 proje sahibine aittir.
