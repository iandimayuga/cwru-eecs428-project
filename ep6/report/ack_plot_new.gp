set term pdf enhanced color
set output "ack_plot_new.pdf"
set size 1,1
set title "Bytes ACKed over time (Improved)"
set xlabel "Time (s)"
set ylabel "Bytes ACKed"
plot "ack_plot_new.dat" with lines title ""

