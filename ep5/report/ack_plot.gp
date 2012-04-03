set terminal latex
set output "ack_plot.tex"
set title "Bytes ACKed over time"
set xlabel "Time (s)"
set ylabel "Bytes ACKed"
plot "ack_plot.dat" title ""
set output
set terminal pop
