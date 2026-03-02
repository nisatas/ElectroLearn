# ElectroLearn Wiki

Bu doküman, ElectroLearn uygulamasının özellikleri, yapısı ve geliştirme rehberini içerir.

---

## İçindekiler

1. [Proje Özeti](#proje-özeti)
2. [Özellikler](#özellikler)
3. [Kullanıcı Akışı](#kullanıcı-akışı)
4. [Teknoloji Yığını](#teknoloji-yığını)
5. [Proje Yapısı](#proje-yapısı)
6. [İçerik ve Veri](#içerik-ve-veri)
7. [Kurulum ve Çalıştırma](#kurulum-ve-çalıştırma)
8. [Yapılandırma](#yapılandırma)
9. [Katkı ve Genişletme](#katkı-ve-genişletme)

---

## Proje Özeti

**ElectroLearn**, elektrik ve elektroniği (özellikle Arduino ve breadboard odaklı) adım adım öğreten, Duolingo tarzı bir mobil uygulamadır.

- **Hedef kitle:** Ortaokul, lise ve başlangıç seviyesi üniversite öğrencileri.
- **Yaklaşım:** Konu → Ders kartları → Test → Mini görevler (simülasyon) → Rozetler ve projeler.
- **Platform:** Flutter ile Android / iOS; backend ve kimlik için Supabase.

---

## Özellikler

| Özellik | Açıklama |
|--------|----------|
| **Ana ekran** | Konular, Testler ve Projeler ayrı bölümlerde; her konunun alt başlıkları (ders kartları) listelenir. |
| **Dersler** | Kartlar halinde içerik, "Sesle oku" (TTS / opsiyonel harici ses), mini görev listesi. |
| **Testler** | Çoktan seçmeli ve doğru/yanlış sorular, açıklama, XP kazanımı. |
| **Sonuç ekranı** | Puan, XP, test sonrası mini görevler (metin işaretleme veya simülasyon). |
| **Devre simülasyonu** | WebView içinde JavaScript + HTML5 Canvas; 5V–direnç–LED–GND bağlama, doğru devrede LED yanar ve görev tamamlanır. |
| **Rozetler** | Beceri tamamlandıkça profil sayfasında rozetler (LED Master, Trafik Lambası Projesi vb.). |
| **Profil** | XP, seri (streak), tamamlanan konular, rozetler, hesap ve çıkış. |
| **Kimlik** | E-posta/şifre ile giriş ve kayıt (Supabase Auth). |

---

## Kullanıcı Akışı

1. **Giriş / Kayıt** → Supabase yapılandırılmışsa login/signup, değilse uygulama misafir devam eder.
2. **Ana sayfa** → Konular (alt başlıklarla), Testler, Projeler listelenir.
3. **Konu seçimi** → Ders ekranına gider; kartlar okunur, "Sesle oku" kullanılabilir.
4. **Teste geç** → Quiz ekranı; sorular cevaplanır, sonunda sonuç ekranına gidilir.
5. **Sonuç** → Puan + XP; mini görevler (metin işaretleme veya "Devreyi kur" simülasyonu); tüm görevler bitince bonus XP.
6. **Profil** → İstatistikler, tamamlanan konular, rozetler, çıkış.

---

## Teknoloji Yığını

| Amaç | Dil / Teknoloji |
|------|-----------------|
| Uygulama arayüzü | Flutter (Dart) |
| Devre simülasyonu | JavaScript |
| Devre çizimi | HTML5 Canvas |
| Kod editörü (planlanan) | Monaco Editor (JS) |
| Kod vurgulama | JavaScript |
| Backend / Auth | Supabase |

- Flutter ekranları: Material 3, Riverpod (state), go_router (yönlendirme).
- Yerel ilerleme: Hive (XP, seri, tamamlanan beceriler, mini görev anahtarları).
- Simülasyon: `assets/circuit_simulator/index.html` WebView'da yüklenir; Flutter konfigürasyonu enjekte eder, tamamlanınca JavaScript channel (`CircuitBridge`) ile Flutter'a bildirilir.

---

## Proje Yapısı

```
electrolearn/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── domain/
│   ├── data/
│   ├── features/
│   └── shared/
├── assets/
│   ├── content/
│   └── circuit_simulator/
├── docs/
│   ├── ARCHITECTURE.md
│   └── WIKI.md
├── pubspec.yaml
└── README.md
```

---

## İçerik ve Veri

- **unit1.json:** Course → units → skills; her skill'de lessonCards, questions, miniTasks.
- **Devre config:** `lib/app/circuit_challenges_config.dart` – hangi mini görevin simülasyonu olduğu.
- **İlerleme (Hive):** XP, seri, tamamlanan beceri id'leri, mini görev anahtarları.

---

## Kurulum ve Çalıştırma

```bash
flutter pub get
flutter run
```

Supabase için `lib/app/supabase_config.dart` içinde URL ve anon key doldurun.

---

## Yapılandırma

| Dosya | Açıklama |
|-------|----------|
| `lib/app/supabase_config.dart` | Supabase URL ve anon key. |
| `lib/app/colors.dart` | Uygulama renkleri. |
| `lib/app/badges_config.dart` | Beceri → rozet eşlemesi. |
| `lib/app/circuit_challenges_config.dart` | Simülasyon görevleri (skillId, taskIndex → CircuitChallenge). |

---

## Katkı ve Genişletme

- **Yeni konu:** `assets/content/unit1.json` içine yeni skill ekleyin.
- **Yeni rozet:** `lib/app/badges_config.dart` içine Badge ekleyin.
- **Yeni simülasyon:** `circuit_challenges_config.dart` içinde getCircuitChallenge için yeni dal ekleyin.
