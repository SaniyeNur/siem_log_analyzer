#!/bin/bash

# SIEM Log Analyz Script
# Yazar: Saniye
# Amaç: SIEM log dosyasını analiz ederek şüpheli olayları tespit etmek

LOG_FILE="/var/log/auth.log"  # Analiz edilecek log dosyası
OUTPUT_FILE="suspect_activity.log"  # Çıktı dosyası
THRESHOLD=2  # Şüpheli girişim sayısı eşiği

echo "=== SIEM Log Analiz Scripti Çalışıyor ==="
echo "Analiz edilen log dosyası: $LOG_FILE"
echo "Çıktılar $OUTPUT_FILE dosyasına kaydediliyor..."

# Çıktı dosyasını sıfırla
echo "=== SIEM Log Analizi Raporu ===" > $OUTPUT_FILE
echo "Analiz edilen dosya: $LOG_FILE" >> $OUTPUT_FILE
echo "Tarih: $(date)" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE

# SSH brute force girişimlerini tespit et
echo "[+] SSH Brute Force Girişimlerini Tespit Etme..." | tee -a $OUTPUT_FILE
grep "Failed password" $LOG_FILE | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | while read count ip; do
    if [ "$count" -ge "$THRESHOLD" ]; then
        echo "Şüpheli IP: $ip - $count başarısız girişim" | tee -a $OUTPUT_FILE
    fi
done

# Kritik hata mesajlarını yakala
echo "[+] Kritik Hata Mesajları Aranıyor..." | tee -a $OUTPUT_FILE
grep -i "error\|failed\|unauthorized\|denied" $LOG_FILE | tee -a $OUTPUT_FILE

# Anormal aktiviteleri kontrol et
echo "[+] Anormal Aktiviteler Aranıyor..." | tee -a $OUTPUT_FILE
grep "root" $LOG_FILE | grep -i "login" | tee -a $OUTPUT_FILE

echo "=== Analiz Tamamlandı! ==="
echo "Bulgular $OUTPUT_FILE içinde kayıtlı."

