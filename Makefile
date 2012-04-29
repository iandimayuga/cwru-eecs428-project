# Ian Dimayuga (icd3)

all: exp_on_off.out pareto_on_off.out total_pareto_exp.out packet_size.out delack.out delack_count.out endtime.out ack_plot.dat elephant_bw.dat

trace.tr: sim.tcl
	@echo "Running Simulation..."
	@ns sim.tcl | tee sim.log

sim.log: sim.tcl
	@echo "Running Simulation..."
	@ns sim.tcl | tee sim.log

routers.log: trace.tr sim.log
	@grep 'router' sim.log | awk '{print $$1}' > routers.log

elephants.log: trace.tr sim.log
	@grep 'elephant' sim.log | awk '{print $$1}' > elephants.log

exp_on_off.out: exp_on_off.py trace.tr routers.log
	@echo "Calculating Mean Exponential burst and idle times..."
	@grep '^r' trace.tr | grep ' exp ' | python exp_on_off.py | tee exp_on_off.out

pareto_on_off.out: pareto_on_off.py trace.tr routers.log
	@echo "Calculating Mean Pareto burst and idle times..."
	@grep '^r' trace.tr | grep ' pareto ' | python pareto_on_off.py | tee pareto_on_off.out

packet_size.out: packet_size.py trace.tr
	@echo "Verifying packet sizes..."
	@grep '^r' trace.tr | grep -v ' ack ' | python packet_size.py | tee packet_size.out

delack.out: delack.py trace.tr routers.log
	@echo "Verifying DelAck timeouts..."
	@egrep '(^r|^\+)' trace.tr | python delack.py | sort | uniq -c | tee delack.out

delack_count.out: delack_count.py trace.tr
	@echo "Verifying DelAck ratio..."
	@grep '^r' trace.tr | python delack_count.py | tee delack_count.out

total_pareto_exp.out: total_pareto_exp.py trace.tr routers.log
	@echo "Calculating total Pareto and Exponential data..."
	@grep '^r' trace.tr | egrep '( pareto | exp )' | python total_pareto_exp.py | tee total_pareto_exp.out

endtime.out: endtime.py trace.tr elephants.log
	@echo "Identifying Elephant stop times..."
	@grep '^r' trace.tr | grep ' tcp ' | python endtime.py | tee endtime.out

ack_plot.dat: ack_plot.py trace.tr routers.log
	@echo "Generating ACK plot..."
	@grep '^r' trace.tr | grep ' ack ' | python ack_plot.py | tee ack_plot.dat

elephant_bw.dat: elephant_bw.py trace.tr elephants.log
	@echo "Generating Elephant bandwidth utilization plot..."
	@grep '^-' trace.tr | grep ' tcp ' | python elephant_bw.py | tee elephant_bw.dat

clean:
	rm *.out *.dat

traceclean: clean
	rm trace.tr sim.log
