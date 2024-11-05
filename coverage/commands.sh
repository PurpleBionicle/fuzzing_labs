# Пересоберем проект, чтобы вставить инструментарий, который позволяет собрать покрытие
sudo apt install lcov
sudo CC="gcc --coverage" CXX="g++ --coverage" ./configure --disable-shared --without-zenmap
sudo make

#Выполним наши корпуса на проекте, чтобы собрать покрытие 

for file in out/default/queue/*; do ./nmap $file; done
find . -name "*.gcda"

#Приведем в человекочитаемый вид 
sudo lcov -o cov.info -c -d .
genhtml -o cov_data cov.info
