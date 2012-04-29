set term pdf enhanced color
set output "elephant_bw_new.pdf"   
set size 1,1
set title "Elephant Utilization (Improved)"               
set xlabel "Time (s)"       
set ylabel "Bandwidth Utilization (kbps)"                 
plot "elephant_bw_new.dat" using 1:2 with lines title "Elephant 0", \
    "elephant_bw_new.dat" using 1:3 with lines title "Elephant 1", \
    "elephant_bw_new.dat" using 1:4 with lines title "Elephant 2", \
    "elephant_bw_new.dat" using 1:5 with lines title "Total Elephants"
exit
