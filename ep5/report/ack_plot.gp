set term pdf enhanced color
set output "ack_plot.pdf"
set size 1,1
set title "Bytes ACKed over time"
set xlabel "Time (s)"
set ylabel "Bytes ACKed"
plot "ack_plot.dat" with lines title ""
