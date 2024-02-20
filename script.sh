#!/bin/bash

# Kullanım kontrolü - En az 3 argüman gerekiyor
if [ "$#" -lt 3 ]; then
    echo "Kullanım: $0 <video dosyası> <alt yazı dosyası> <indeksler ve aralıklar>"
    exit 1
fi

VIDEO_FILE=$1  # Video dosyası yolu
SUBTITLE_FILE=$2  # Alt yazı dosyası yolu
shift 2  # İlk iki argümanı kaldır

# İşlem fonksiyonu
process_segment() {
    START_INDEX=$(printf "%04d" $1)
    END_INDEX=$(printf "%04d" ${2:-$1})
    BASE_NAME=$(basename "$VIDEO_FILE" | sed 's/\.[^.]*$//')
    EXTENSION="${VIDEO_FILE##*.}"
    OUTPUT_DIR="${BASE_NAME}"
    mkdir -p "$OUTPUT_DIR"

    if [ "$START_INDEX" == "$END_INDEX" ]; then
        OUTPUT_NAME="${START_INDEX}-${BASE_NAME}"
    else
        OUTPUT_NAME="${START_INDEX}_${END_INDEX}-${BASE_NAME}"
    fi

    awk -v start_index="$START_INDEX" -v end_index="$END_INDEX" -v video_file="$VIDEO_FILE" -v output_name="$OUTPUT_NAME" -v output_dir="$OUTPUT_DIR" -v extension="$EXTENSION" '
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
        if ($1 >= start_index && $1 <= end_index) {
            if (start_time == "") {
                split($2, times, " --> ");
                start_time = times[1];
            }
            split($2, times, " --> ");
            end_time = times[2];

            if (first_time_offset == -1) {
                split(times[1], start_time_parts, ",");
                split(start_time_parts[1], start_hms, ":");
                first_time_offset = start_hms[1] * 3600 + start_hms[2] * 60 + start_hms[3] + start_time_parts[2] / 1000;
            }

            $1 = current_index++;

            split($2, times, " --> ");
            for (i=1; i<=2; i++) {
                split(times[i], time_parts, ",");
                split(time_parts[1], hms, ":");
                total_seconds = hms[1] * 3600 + hms[2] * 60 + hms[3] + time_parts[2] / 1000 - first_time_offset;
                new_hms = sprintf("%02d:%02d:%02d", int(total_seconds / 3600), int(total_seconds / 60) % 60, int(total_seconds) % 60);
                new_ms = sprintf("%03d", int((total_seconds - int(total_seconds)) * 1000));
                times[i] = new_hms "," new_ms;
            }
            $2 = times[1] " --> " times[2];

            for (i = 1; i <= NF; i++) {
                output_subtitle_content = output_subtitle_content $i "\n";
            }
            output_subtitle_content = output_subtitle_content "\n";
        }
    }
    END {
        if (start_time != "" && end_time != "") {
            gsub(",", ".", start_time);
            gsub(",", ".", end_time);
            output_video = sprintf("%s/%s.%s", output_dir, output_name, extension);
            cmd_video = sprintf("ffmpeg -i \"%s\" -ss %s -to %s -c:v libx264 -c:a copy \"%s\" -y", video_file, start_time, end_time, output_video);
            system(cmd_video);

            if (output_subtitle_content != "") {
                output_subtitle = sprintf("%s/%s.srt", output_dir, output_name);
                print output_subtitle_content > output_subtitle;
            }
        }
    }
    ' "$SUBTITLE_FILE"
}

# Argümanları virgülle ayrılmış olarak işle
IFS=',' read -ra ADDR <<< "$*"
for i in "${ADDR[@]}"; do
    # Aralık kontrolü - Eğer aralık varsa
    if [[ $i == *" "* ]]; then
        # Boşlukla ayrılmış başlangıç ve bitiş indekslerini al
        IFS=' ' read -ra RANGE <<< "$i"
        process_segment "${RANGE[0]}" "${RANGE[1]}"
    else
        process_segment "$i"
    fi
done

echo "Tüm işlemler tamamlandı."
