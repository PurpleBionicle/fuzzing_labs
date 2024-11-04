# Сертификация СЗИ (5 курс)

[ЛР1 - Контрольное суммирование](#1) <br>
[ЛР2 - Фаззинг](#2) <br>
[ЛР3 - Сбор покрытия проведенного фаззинг тестирования](#3) <br>

<h2 id="0">Контрольное суммирование и сборка проекта</h2>

Для фаззинг тестирования был выбран проект nmap (https://github.com/nmap/nmap)
- Релизов нет, так что скачаем актуальную версию (на 03.11.24)
- Для контрольного суммирования воспользуемся утилитой cpverify от КриптоПро
1) Вычислим хэш-значение для исходных текстов с использованием алгоритма  ГОСТ 34.11 и длиной ключа 256 бит 
```
bionic@Ubuntu-MSI:~$ ./cpverify.sh -mk ./Загрузки/nmap-master.zip -alg GR3411_2012_256
15655DC2CE60FF626569F0E82BEE968FA48BB2A6542CFD403A16322BDF4B818A
```

2) Так как установочный дистрибутив отсутствует, то для него контрольное суммирование не проводилось
3) Соберем проект, установим нужные зависимости 
```
bionic@Ubuntu-MSI:~/Загрузки/nmap-master$ history | tail -n 10
 1945  ./cpverify.sh -mk ./Загрузки/nmap-master.zip -alg GR3411_2012_256
 1946  cd ./Загрузки/
 1947  unzip ./nmap-master.zip 
 1948  sudo apt-get update
 1949  sudo apt-get install build-essential libssl-dev libpcap-dev zlib1g-dev
 1950  cd ./nmap-master/
 1951  sudo ./configure --without-zenmap
 1952  sudo make
```
Из сборки проекта уберем GUI (zenmap), так как для фаззинга будет использоваться консольная версия

4) Проведем контрольное суммирование для установленного дистрибутива / неизменяемых файлов
Выполним контрольное суммирование для следующих файлов и директорий:
- /usr/local/bin/nmap — главный исполняемый файл.
- /usr/local/bin/nping — инструмент для создания сетевого трафика, который входит в комплект поставки nmap.
- /etc/nmap/ — папка с настройками и конфигурационными файлами
- /usr/local/share/nmap/ - вспомогательные данные и ресурсы.

Cpverify умеет делать пофайловое вычисление хэшей только для файлов, которые добавлены в перечень контролируемых
(для этого их нужно описать в xml файле и добавить в реестр остлеживаемых файлов) <br>
Сделаем проще и напишем простой скрипт cpverify_for_directories.sh для пофайлового отхода <br> 
Для директорий хэш был записыван в файл hashes.txt <br>
Для остальных показано ниже: <br>

```
bionic@Ubuntu-MSI:~$ ./cpverify.sh -mk /usr/local/bin/nmap -alg GR3411_2012_256
02099953F2A28225D0D1E5892BFB5670A6A6C8CE67A620F134E493C84A75DBA8```
bionic@Ubuntu-MSI:~$ ./cpverify.sh -mk /usr/local/bin/nping -alg GR3411_2012_256
0FC0D4AC415E2FF3BDF43A7A10AEFBCA17E545BE449BE522AAA09DA7A79FD917
bionic@Ubuntu-MSI:~$ ./cpverify.sh -mk /usr/local/bin/ndiff -alg GR3411_2012_256
2E31DF10B8B961A461862709264ED7CF28F035FCD6B167C9E2E75622D8EB4DA0

bionic@Ubuntu-MSI:~$ sudo chmod +x cpverify_for_directories.sh 
bionic@Ubuntu-MSI:~$ ./cpverify_for_directories.sh 
Хэширование завершено. Результаты сохранены в hashes.txt.
```
<h2 id="2">Фаззинг</h2>

- соберем AFlplusplus
```shell
git clone https://github.com/AFLplusplus/AFLplusplus.git
cd AFLplusplus/
make
```
- пересоберем проект с фаззером
```shell
sudo CC=afl-gcc CXX=afl-gcc++ ./configure --without-zenmap --disable-shared
```
- Создадим согласно заданию 2 корпуса (серый и белый ip)
```shell
mkdir nmap_corpus
cd ./nmap_corpus/
echo "192.168.1.1" > ip1.txt
echo ya.ru > ip2.txt
```
- Запустим фаззинг
```shell
2120  sudo CC=afl-clang-fast CXX=afl-clang-fast++ ./configure  --disable-shared --without-zenmap
2121  sudo make
```
- Посмотрим на статистику
```shell
sudo apt install gnuplot
afl-plot ./out/default/ plot_data
```
- Полученные результаты лежат в папке фаззинга 


<h2 id="3">Сбор покрытия проведенного фаззинг тестирования</h2>

- Пересоберем проект, чтобы вставить инструментарий, который позволяет собрать покрытие

```shell
sudo apt install lcov
sudo CC="gcc --coverage" CXX="g++ --coverage" ./configure --disable-shared --without-zenmap
sudo make
for file in out/default/queue/*; do ./nmap $file; done
find . -name "*.gcda"
```
- Отсутствуют gcda файлы 
```shell
bionic@Ubuntu-MSI:~/nmap-maste$ lcov -o cov.info -c -d .
Capturing coverage data from .
Subroutine read_intermediate_text redefined at /usr/bin/geninfo line 2623.
Subroutine read_intermediate_json redefined at /usr/bin/geninfo line 2655.
Subroutine intermediate_text_to_info redefined at /usr/bin/geninfo line 2703.
Subroutine intermediate_json_to_info redefined at /usr/bin/geninfo line 2792.
Subroutine get_output_fd redefined at /usr/bin/geninfo line 2872.
Subroutine print_gcov_warnings redefined at /usr/bin/geninfo line 2900.
Subroutine process_intermediate redefined at /usr/bin/geninfo line 2930.
Found gcov version: 11.4.0
Using intermediate gcov format
Scanning . for .gcda files ...
geninfo: WARNING: no .gcda files found in . - skipping!
Finished .info-file creation
bionic@Ubuntu-MSI:~/nmap-maste$ genhtml -o cov_data cov.info
Reading data file cov.info
genhtml: ERROR: no valid records found in tracefile cov.info
```
- cov.info - 0 байт
