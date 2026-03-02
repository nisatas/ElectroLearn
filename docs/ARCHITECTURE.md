# ElectroLearn – Mimari ve Teknoloji Yığını

## Teknoloji seçimleri

| Amaç               | Dil / Teknoloji      |
| ------------------ | -------------------- |
| **App UI**         | Flutter (Dart)       |
| **Devre simülasyonu** | JavaScript        |
| **Devre çizimi**   | HTML5 Canvas         |
| **Kod editörü**    | Monaco Editor (JS)   |
| **Kod vurgulama** | JavaScript           |
| **Backend**        | Supabase             |

## Entegrasyon

- **Flutter ↔ JavaScript:** Devre simülasyonu (ve ileride kod editörü) uygulama içinde **WebView** ile yüklenir. Flutter, konfigürasyonu WebView'a enjekte eder; simülasyon tamamlanınca **JavaScript channel** (`CircuitBridge`) ile Flutter'a haber verilir.
- **Backend:** Kimlik (Supabase Auth) ve ileride veri (ilerleme, projeler) Supabase ile yönetilir; Flutter doğrudan Supabase client kullanır.
- **Yerel depolama:** İlerleme (XP, seri, tamamlanan beceriler, mini görevler) Hive ile cihazda saklanır.

## Dosya yapısı (özet)

- `lib/` – Flutter (Dart): ekranlar, state (Riverpod), tema, router (go_router).
- `assets/content/` – Ünite/beceri içeriği (unit1.json).
- `assets/circuit_simulator/` – Devre simülasyonu: HTML + JS, Canvas ile çizim ve bağlantı doğrulama.
- `docs/` – Mimari (ARCHITECTURE.md) ve wiki (WIKI.md).

## Notlar

- **Monaco Editor:** İleride Arduino kodu yazmak için WebView içinde Monaco kullanılabilir; sözdizimi vurgulama JS tarafında yapılır.
- **Devre simülasyonu:** Bağlantı grafiği (5V → R → LED → GND) doğrulanıyor; ileride gerçek zamanlı akım/gerilim simülasyonu JS'e eklenebilir.
