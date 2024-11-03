#!/bin/bash


output_file="hashes.txt"

# Функция для обработки файлов в заданной директории
process_files() {
  local dir=$1
  for file in "$dir"/*; do
    if [ -f "$file" ]; then
      # Запуск cpverify.sh для файла и извлечение хэша
      hash_output=$(./cpverify.sh -mk "$file" -alg GR3411_2012_256)
      # Запись имени файла и хэш-значения в выходной файл
      echo "$file : $hash_output" >> "$output_file"
    fi
  done
}

# Обработка файлов в указанных директориях
process_files "/etc/nmap/nmap-master"
process_files "/usr/local/share/nmap"

echo "Хэширование завершено. Результаты сохранены в $output_file."
