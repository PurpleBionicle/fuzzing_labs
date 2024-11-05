git clone https://github.com/AFLplusplus/AFLplusplus.git
cd AFLplusplus/
make

#пересоберем проект с фаззером

sudo CC=afl-gcc CXX=afl-gcc++ ./configure --without-zenmap --disable-shared

#Создадим согласно заданию 2 корпуса (серый и белый ip)

mkdir nmap_corpus
cd ./nmap_corpus/
echo "192.168.1.1" > ip1.txt
echo ya.ru > ip2.txt

#Запустим фаззинг

afl-gcc -i nmap_corpus/ -o out/ -- ./nmap @@

#Посмотрим на статистику
sudo apt install gnuplot
afl-plot ./out/default/ plot_data
