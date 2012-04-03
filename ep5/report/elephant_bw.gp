set term postscript eps enhanced color
set output "elephant_bw.eps"   
set size 0.7,0.7                         
set title "Elephant Rates"               
set xlabel "Simulation Time (sec)"       
set ylabel "Bandwidth utilization (Bps)"                 
plot "elephant_bw.dat" using 1:2 with lines title "Elephant 1", \
    "elephant_bw.dat" using 1:4 with lines title "Elephant 2", \
    "elephant_bw.dat" using 1:3 with lines title "Elephant 3", \
    "elephant_bw.dat" using 1:5 with lines title "Sum Of Elephant Rates"
exit
