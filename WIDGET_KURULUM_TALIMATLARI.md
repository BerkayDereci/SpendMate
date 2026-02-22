# Widget Extension Kurulum Talimatları

## Xcode'da Yapılması Gerekenler

### 1. Widget Extension Target Ekleme

1. Xcode'da projeyi açın
2. File > New > Target seçin
3. "Widget Extension" seçin
4. Next'e tıklayın
5. Product Name: `SpendMateWidget`
6. "Include Configuration Intent" seçeneğini **KALDIRIN** (işaretlemeyin)
7. Finish'e tıklayın
8. "Activate" butonuna tıklayın (scheme'i aktif etmek için)

### 2. App Group Yapılandırması

#### Ana Uygulama (SpendMate) için:
1. Project Navigator'da SpendMate target'ını seçin
2. "Signing & Capabilities" sekmesine gidin
3. "+ Capability" butonuna tıklayın
4. "App Groups" seçin
5. "+" butonuna tıklayın ve şunu ekleyin: `group.com.spendmate.shared`
6. App Group'u işaretleyin

#### Widget Extension (SpendMateWidget) için:
1. Project Navigator'da SpendMateWidget target'ını seçin
2. "Signing & Capabilities" sekmesine gidin
3. "+ Capability" butonuna tıklayın
4. "App Groups" seçin
5. Aynı App Group'u ekleyin: `group.com.spendmate.shared`
6. App Group'u işaretleyin

### 3. Dosyaları Widget Extension Target'ına Ekleme

Aşağıdaki dosyaları widget extension target'ına eklemeniz gerekiyor:

#### Widget Extension Target'ına Eklenecek Dosyalar:
- `SpendMateWidget/SpendMateWidget.swift`
- `SpendMateWidget/SpendMateTimelineProvider.swift`
- `SpendMateWidget/SmallWidgetView.swift`
- `SpendMateWidget/MediumWidgetView.swift`
- `SpendMateWidget/LargeWidgetView.swift`

#### Her İki Target'a Eklenecek Dosyalar (Shared):
- `Shared/WidgetDataService.swift` (hem ana app hem widget)
- `Shared/WidgetData.swift` (hem ana app hem widget)
- `Shared/Currency.swift` (hem ana app hem widget)
- `Models/Expense.swift` (hem ana app hem widget)
- `Models/ExpenseCategory.swift` (hem ana app hem widget)
- `Models/IncomeCategory.swift` (hem ana app hem widget)
- `Models/TransactionType.swift` (hem ana app hem widget)

**DETAYLI ADIM ADIM NASIL EKLENİR:**

### Yöntem 1: File Inspector ile (En Kolay Yöntem)

**Adım 1: Sağ Paneli Açın**
- Xcode'un sağ üst köşesinde 3 buton var (Editor, Navigator, Inspector butonları)
- En sağdaki butona tıklayın (Inspector butonu - genellikle bir cetvel simgesi)
- Veya klavye kısayolu: `⌘⌥1` (Command + Option + 1)
- Bu işlem sağ paneli (File Inspector) açar

**Adım 2: Bir Dosyayı Seçin**
- Sol panelde (Project Navigator) bir dosyaya tıklayın
- Örneğin: `SpendMateWidget/SpendMateWidget.swift` dosyasına tıklayın

**Adım 3: Target Membership'ı Bulun**
- Sağ panelde (File Inspector) aşağı kaydırın
- "Target Membership" başlığını bulun
- Bu bölümde checkbox'lar göreceksiniz:
  ```
  Target Membership
  ☑ SpendMate
  ☐ SpendMateWidget  ← Bu checkbox'ı işaretleyin
  ```

**Adım 4: Widget Target'ını İşaretleyin**
- "SpendMateWidget" checkbox'ının yanındaki boş kutuya tıklayın
- Checkbox işaretlenmeli: ☑ SpendMateWidget

**Adım 5: Her Dosya İçin Tekrarlayın**
- Yukarıdaki listedeki her dosya için Adım 2-4'ü tekrarlayın

### Yöntem 2: Birden Fazla Dosyayı Seçerek (Daha Hızlı)

**Adım 1: Birden Fazla Dosyayı Seçin**
- Sol panelde (Project Navigator) `⌘` (Command) tuşuna basılı tutun
- Seçmek istediğiniz dosyalara tek tek tıklayın
- Örneğin: Tüm `SpendMateWidget/` klasöründeki 5 dosyayı seçin

**Adım 2: File Inspector'ı Açın**
- Sağ paneli açın (`⌘⌥1` veya Inspector butonu)

**Adım 3: Target Membership'ı Ayarlayın**
- "Target Membership" bölümünde "SpendMateWidget" checkbox'ını işaretleyin
- Tüm seçili dosyalar için aynı anda uygulanır

### Yöntem 3: Project Settings'ten (Toplu İşlem)

**Adım 1: Project Ayarlarını Açın**
- Sol panelin en üstünde mavi proje ikonuna (SpendMate) tıklayın
- Orta panelde "TARGETS" bölümünde "SpendMateWidget" target'ını seçin

**Adım 2: Build Phases Sekmesine Gidin**
- Üstteki sekmelerden "Build Phases" sekmesine tıklayın

**Adım 3: Compile Sources Bölümünü Bulun**
- "Compile Sources" bölümünü genişletin (yukarıdaki ok işaretine tıklayın)

**Adım 4: Dosyaları Ekleme**
- Sol alttaki "+" butonuna tıklayın
- Eklemek istediğiniz dosyaları seçin
- "Add" butonuna tıklayın

**Not:** Bu yöntem daha tekniktir, Yöntem 1 daha kolaydır.

### Görsel Referans - File Inspector Nerede?

Xcode penceresinde:
```
┌─────────────────────────────────────────┐
│ [Sol Panel]  │  [Orta Panel]  │ [Sağ Panel] │
│              │                 │             │
│ Project      │  Editor         │ File        │
│ Navigator    │  (Kod)          │ Inspector   │
│              │                 │             │
│              │                 │ Target      │
│              │                 │ Membership  │
│              │                 │ ☑ SpendMate │
│              │                 │ ☐ Widget    │
└─────────────────────────────────────────┘
```

Sağ paneli açmak için:
- Sağ üst köşedeki Inspector butonuna tıklayın
- Veya `⌘⌥1` tuşlarına basın

### Kontrol Etme

Dosyanın hangi target'lara eklendiğini kontrol etmek için:
1. Dosyayı seçin
2. File Inspector'da "Target Membership" bölümüne bakın
3. İşaretli olan target'ları göreceksiniz

### Önemli Notlar

- **Widget dosyaları** (`SpendMateWidget/` klasöründeki): Sadece "SpendMateWidget" target'ına eklenmeli
- **Shared dosyalar** (`Shared/` klasöründeki): Hem "SpendMate" hem "SpendMateWidget" target'larına eklenmeli
- **Model dosyaları** (`Models/` klasöründeki): Hem "SpendMate" hem "SpendMateWidget" target'larına eklenmeli

### Görsel Referans

File Inspector'da göreceğiniz yapı:
```
Target Membership
☑ SpendMate
☑ SpendMateWidget  ← Bu checkbox'ı işaretleyin
```

Eğer "SpendMateWidget" seçeneği görünmüyorsa:
- Widget Extension target'ı henüz eklenmemiş olabilir
- Önce "1. Widget Extension Target Ekleme" adımını tamamlayın

### 4. Widget Extension Info.plist Yapılandırması

Widget extension'ın Info.plist dosyasında (eğer varsa) gerekli yapılandırmaları kontrol edin.

### 5. Build Settings Kontrolü

1. Widget Extension target'ını seçin
2. Build Settings'e gidin
3. "Swift Language Version" kontrol edin (Swift 5.9+ olmalı)
4. "iOS Deployment Target" kontrol edin (iOS 17.0+ olmalı)

## Test Etme

1. Widget extension scheme'ini seçin
2. Simulator veya cihazda çalıştırın
3. Ana ekranda widget ekleyin:
   - Ana ekranda uzun basın
   - "+" butonuna tıklayın
   - "SpendMate" widget'ını bulun
   - İstediğiniz boyutu seçin ve ekleyin

## Önemli Notlar

- App Group ID'yi değiştirirseniz, `WidgetDataService.swift` ve `SpendMateApp.swift` dosyalarındaki `appGroupIdentifier` değerini de güncellemeniz gerekir
- İlk çalıştırmada widget boş görünebilir - bu normaldir, veri yoksa empty state gösterilir
- Widget'lar otomatik olarak güncellenir, ancak veri değişikliklerinde manuel güncelleme de yapılır

## Sorun Giderme

- **Widget veri göstermiyor**: App Group yapılandırmasını kontrol edin
- **Build hatası**: Tüm shared dosyaların widget target'ına eklendiğinden emin olun
- **Currency.format() hatası**: Currency.swift'in widget target'ına eklendiğinden emin olun

