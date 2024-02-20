# video ve alt yazı i̇şleme betiği

bu betik, belirli bir alt yazı indeks aralığına göre video dosyalarını kesmek ve ilgili alt yazıları bu kesimlere uygun şekilde düzenlemek için kullanılır.

bu betiği [moyi](https://github.com/ademavsar/moyi) için deste hazırlamak amacıyla oluşturdum.

## test
![test gif](test.gif)

## özellikler

- birden fazla video formatını destekler (mkv, mp4, avi vb.).
- belirtilen alt yazı indeks aralığına göre videoyu keser.
- kesilen video bölümleri için alt yazıları uygun şekilde düzenler.
- birden fazla segmenti tek bir komutla işleyebilme yeteneği.

## kullanım

betiği kullanmak için aşağıdaki komutu terminalde çalıştırın:

```bash
./script.sh <video dosyası> <alt yazı dosyası> <başlangıç indeksi> [bitiş indeksi]
```

- `<video dosyası>`: i̇şlenecek video dosyasının yolu.
- `<alt yazı dosyası>`: alt yazı dosyasının yolu.
- `<başlangıç indeksi>`: alt yazılarda işlem yapılacak başlangıç indeksi.
- `[bitiş indeksi]`: opsiyonel, alt yazılarda işlem yapılacak bitiş indeksi. belirtilmezse, başlangıç indeksi ile aynı kabul edilir.

## 3 farklı kullanım şekli

```bash
./script.sh example.mp4 subtitles.srt 5
```

```bash
./script.sh example.mp4 subtitles.srt 5 9
```

```bash
./script.sh example.mp4 subtitles.srt 5, 5 9
```

## gereklilikler

- `ffmpeg`: video işleme için gereklidir. sisteminizde `ffmpeg` kurulu olmalıdır.

### güncelleme notları

- video dosyası adı ve uzantısı işlemede iyileştirmeler yapıldı; artık betik, .mkv dahil olmak üzere farklı uzantılara sahip video dosyalarını destekliyor.
- çıktı video dosyasının uzantısı, orijinal video dosyasının uzantısına dinamik olarak uyum sağlayacak şekilde güncellendi.
- betik, genel kullanım kolaylığı ve esnekliği artıracak şekilde yeniden düzenlendi. artık birden fazla segmenti tek bir komutla işleyebilir.
