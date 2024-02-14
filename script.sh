#!/bin/bash

# Kullanım kontrolü
if [ "$#" -lt 4 ]; then
    echo "Kullanım: $0 <video dosyası> <alt yazı dosyası> <başlangıç indeksi> <bitiş indeksi>"
    exit 1
fi

VIDEO_FILE=$1
SUBTITLE_FILE=$2
START_INDEX=$3
END_INDEX=$4
BASE_NAME=$(basename "$VIDEO_FILE" .mkv)
OUTPUT_DIR="${BASE_NAME}"

# Çıktı klasörünü oluştur
mkdir -p "$OUTPUT_DIR"

# Video ve alt yazı işleme
awk -v start_index="$START_INDEX" -v end_index="$END_INDEX" -v video_file="$VIDEO_FILE" -v base_name="$BASE_NAME" -v output_dir="$OUTPUT_DIR" '
BEGIN {
    RS = "";
    FS = "\n";
    start_time = "";
    end_time = "";
    output_subtitle_content = "";
    current_index = 1;
    first_time_offset = -1;
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
        output_video = sprintf("%s/%s_%s-%s.mkv", output_dir, start_index, end_index, base_name);
        cmd_video = sprintf("ffmpeg -i \"%s\" -ss %s -to %s -c:v libx264 -c:a copy \"%s\" -y", video_file, start_time, end_time, output_video);
        system(cmd_video);

        if (output_subtitle_content != "") {
            output_subtitle = sprintf("%s/%s_%s-%s.srt", output_dir, start_index, end_index, base_name);
            print output_subtitle_content > output_subtitle;
        }
    } else {
        print "Belirtilen zaman kodları arasında alt yazı bulunamadı.";
    }
}' "$SUBTITLE_FILE"

if [ $? -eq 0 ]; then
    echo "İşlem tamamlandı."
else
    echo "Bir hata oluştu."
fi
