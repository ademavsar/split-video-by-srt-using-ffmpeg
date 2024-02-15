#!/bin/bash

# Kullanım kontrolü - En az 3 argüman gerekiyor, bitiş indeksi opsiyonel
if [ "$#" -lt 3 ]; then
    echo "Kullanım: $0 <video dosyası> <alt yazı dosyası> <başlangıç indeksi> [bitiş indeksi]"
    exit 1
fi

# Argümanlar alınıyor
VIDEO_FILE=$1           # Video dosyası yolu
SUBTITLE_FILE=$2        # Alt yazı dosyası yolu
START_INDEX=$3          # Başlangıç indeksi
END_INDEX=${4:-$START_INDEX}  # Bitiş indeksi, opsiyonel (varsayılan olarak başlangıç indeksi ile aynı)

# Video dosyası adından temel isim oluşturuluyor
BASE_NAME=$(basename "$VIDEO_FILE" .mkv)

# Çıktı dizini oluşturuluyor
OUTPUT_DIR="${BASE_NAME}"
mkdir -p "$OUTPUT_DIR"

# İşlem adlarının belirlenmesi - Bitiş indeksi kullanılmadığında farklı bir isimlendirme
if [ -z "$4" ]; then  # 4. argüman boşsa
    OUTPUT_NAME="${START_INDEX}-${BASE_NAME}"
else
    OUTPUT_NAME="${START_INDEX}_${END_INDEX}-${BASE_NAME}"
fi

# Alt yazı dosyası işleniyor
awk -v start_index="$START_INDEX" -v end_index="$END_INDEX" -v video_file="$VIDEO_FILE" -v output_name="$OUTPUT_NAME" -v output_dir="$OUTPUT_DIR" '
BEGIN {
    RS = "";            # Kayıt ayırıcı boş satır
    FS = "\n";          # Alan ayırıcı yeni satır
    start_time = "";    # Başlangıç zamanı
    end_time = "";      # Bitiş zamanı
    output_subtitle_content = "";  # Çıktı alt yazı içeriği
    current_index = 1;  # Alt yazı sıra numarası
    first_time_offset = -1;  # İlk zaman damgası offseti
}
{
    # Geçerli alt yazının indeksi belirtilen aralıkta ise işleme alınır
    if ($1 >= start_index && $1 <= end_index) {
        if (start_time == "") {
            split($2, times, " --> ");
            start_time = times[1];  # İlk alt yazı zaman damgası
        }
        split($2, times, " --> ");
        end_time = times[2];  # Son alt yazı zaman damgası

        # İlk zaman damgası offsetinin hesaplanması
        if (first_time_offset == -1) {
            split(times[1], start_time_parts, ",");
            split(start_time_parts[1], start_hms, ":");
            first_time_offset = start_hms[1] * 3600 + start_hms[2] * 60 + start_hms[3] + start_time_parts[2] / 1000;
        }

        $1 = current_index++;  # Alt yazı indeksini güncelle

        # Zaman damgalarını yeni formatına çevirme
        split($2, times, " --> ");
        for (i=1; i<=2; i++) {
            split(times[i], time_parts, ",");
            split(time_parts[1], hms, ":");
            total_seconds = hms[1] * 3600 + hms[2] * 60 + hms[3] + time_parts[2] / 1000 - first_time_offset;
            new_hms = sprintf("%02d:%02d:%02d", int(total_seconds / 3600), int(total_seconds / 60) % 60, int(total_seconds) % 60);
            new_ms = sprintf("%03d", int((total_seconds - int(total_seconds)) * 1000));
            times[i] = new_hms "," new_ms;
        }
        $2 = times[1] " --> " times[2];  # Yeni zaman damgası formatı

        # Çıktı alt yazı içeriğini oluşturma
        for (i = 1; i <= NF; i++) {
            output_subtitle_content = output_subtitle_content $i "\n";
        }
        output_subtitle_content = output_subtitle_content "\n";
    }
}
END {
    # Başlangıç ve bitiş zamanları belirlenmişse işlem yapılır
    if (start_time != "" && end_time != "") {
        gsub(",", ".", start_time);
        gsub(",", ".", end_time);
        output_video = sprintf("%s/%s.mkv", output_dir, output_name);
        # ffmpeg ile video kesme işlemi
        cmd_video = sprintf("ffmpeg -i \"%s\" -ss %s -to %s -c:v libx264 -c:a copy \"%s\" -y", video_file, start_time, end_time, output_video);
        system(cmd_video);

        # Alt yazı içeriği varsa dosyaya yazılır
        if (output_subtitle_content != "") {
            output_subtitle = sprintf("%s/%s.srt", output_dir, output_name);
            print output_subtitle_content > output_subtitle;
        }
    }
}
' "$SUBTITLE_FILE"

# İşlem tamamlandı
echo "İşlem tamamlandı. Çıktılar '$OUTPUT_DIR' dizininde."
