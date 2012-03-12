# Ian Dimayuga (icd3)

all: exp_on_off packet_size delack delack_count endtime

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

exp_on_off: trace.tr routers.log
	@echo "Calculating Mean Exponential burst and idle times..."
	@grep '^r' trace.tr | grep ' exp ' | python exp_on_off.py > exp_on_off.out

packet_size: trace.tr
	@echo "Verifying packet sizes..."
	@grep '^r' trace.tr | grep -v ' ack ' | python packet_size.py > packet_size.out

delack: trace.tr routers.log
	@echo "Verifying DelAck timeouts..."
	@egrep '(^r|^\+)' trace.tr | python delack.py | sort | uniq -c > delack.out

delack_count: trace.tr
	@echo "Verifying DelAck ratio..."
	@grep '^r' trace.tr | python delack_count.py > delack_count.out

endtime: trace.tr elephants.log
	@echo "Identifying Elephant stop times..."
	@grep '^r' trace.tr | grep ' tcp ' | python endtime.py > endtime.out

clean:
	rm *.out

traceclean: clean
	rm trace.tr sim.log
