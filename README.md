# Video ve Alt Yazı İşleme Betiği

Bu betik, belirli bir alt yazı indeks aralığına göre video dosyalarını kesmek ve ilgili alt yazıları bu kesimlere uygun şekilde düzenlemek için kullanılır.

## test
![test gif](test.gif)

## Özellikler

- Birden fazla video formatını destekler (MKV, MP4, AVI vb.).
- Belirtilen alt yazı indeks aralığına göre videoyu keser.
- Kesilen video bölümleri için alt yazıları uygun şekilde düzenler.

## Kullanım

Betiği kullanmak için aşağıdaki komutu terminalde çalıştırın:

```bash
./script.sh <video dosyası> <alt yazı dosyası> <başlangıç indeksi> [bitiş indeksi]
```

- `<video dosyası>`: İşlenecek video dosyasının yolu.
- `<alt yazı dosyası>`: Alt yazı dosyasının yolu.
- `<başlangıç indeksi>`: Alt yazılarda işlem yapılacak başlangıç indeksi.
- `[bitiş indeksi]`: Opsiyonel, alt yazılarda işlem yapılacak bitiş indeksi. Belirtilmezse, başlangıç indeksi ile aynı kabul edilir.

## Örnek Kullanım

```bash
./script.sh example.mp4 subtitles.srt 5 10
```

Bu komut, `example.mp4` video dosyasını ve `subtitles.srt` alt yazı dosyasını kullanarak, 5. ile 10. alt yazı indeksleri arasındaki bölümü keser ve bu kesime ait alt yazıları düzenler.

## Gereklilikler

- `ffmpeg`: Video işleme için gereklidir. Sisteminizde `ffmpeg` kurulu olmalıdır.

### Güncelleme Notları

- Video dosyası adı ve uzantısı işlemede iyileştirmeler yapıldı; artık betik, `.mkv` dahil olmak üzere farklı uzantılara sahip video dosyalarını destekliyor.
- Çıktı video dosyasının uzantısı, orijinal video dosyasının uzantısına dinamik olarak uyum sağlayacak şekilde güncellendi.
- Betik, genel kullanım kolaylığı ve esnekliği artıracak şekilde yeniden düzenlendi.

## Lisans

Bu proje MIT Lisansı ile lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.
