# ⚡ ElectroLearn

ElectroLearn, elektrik ve elektroniği (Arduino & breadboard odaklı) adım adım öğreten **Duolingo tarzı** bir mobil uygulamadır.  

🎯 Hedef kitle: Ortaokul, lise ve başlangıç seviyesindeki üniversite öğrencileri.

![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter)  
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

---

## 🚀 Özellikler

- **Konular, Testler, Projeler**  
  Ana ekranda ayrı bölümler; her konunun alt başlıkları listelenir.

- **Ders Kartları**  
  Sesli okuma (TTS) desteği ve mini görev listeleri.

- **Quiz Sistemi**  
  Çoktan seçmeli, doğru-yanlış ve açıklamalı sorular.  
  Başarıya göre XP kazanımı.

- **Devre Simülasyonu**  
  Test sonrası "Devreyi Kur" bölümü:  
  WebView içinde JavaScript + HTML5 Canvas ile kablo bağlama ve LED yakma simülasyonu.

- **Rozet Sistemi**  
  Beceri tamamlandıkça profil sayfasında rozetler kazanılır (LED Master, Trafik Lambası Projesi vb.).

- **Profil Sayfası**  
  XP, streak (seri), tamamlanan konular ve rozetler.  
  Supabase ile giriş / kayıt sistemi.

---

## 🛠 Teknoloji Yığını

| Amaç | Teknoloji |
|------|-----------|
| Mobil Arayüz | Flutter (Dart) |
| Devre Simülasyonu | JavaScript |
| Devre Çizimi | HTML5 Canvas |
| Kod Editörü (planlanan) | Monaco Editor (JS) |
| Backend / Auth | Supabase |

📄 Detaylı mimari için:  
👉 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## ⚙️ Kurulum ve Çalıştırma

### 1️⃣ Projeyi Klonlayın

```bash
git clone https://github.com/nisatas/electrolearn.git
cd electrolearn
