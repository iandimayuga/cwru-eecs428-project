# Ian Dimayuga (icd3)

all: exp_on_off packet_size delack delack_count endtime

trace.tr: sim.tcl
	@echo "Running Simulation..."
	@ns sim.tcl | tee sim.out

routers.out: trace.tr
	@grep 'router' sim.out | awk '{print $$1}' > routers.out

elephants.out: trace.tr
	@grep 'elephant' sim.out | awk '{print $$1}' > elephants.out

exp_on_off: trace.tr
	@echo "Calculating Mean Exponential burst and idle times..."
	@grep '^r' trace.tr | grep ' exp ' | python exp_on_off.py > exp_on_off.out

packet_size:
	@echo "Verifying packet sizes..."
	@grep '^r' trace.tr | grep -v ' ack ' | python packet_size.py > packet_size.out

delack: routers.out
	@echo "Verifying DelAck timeouts..."
	@egrep '(^r|^\+)' trace.tr | python delack.py | sort | uniq -c > delack.out

delack_count:
	@echo "Verifying DelAck ratio..."
	@grep '^r' trace.tr | python delack_count.py > delack_count.out

endtime: elephants.out
	@echo "Identifying Elephant stop times..."
	@grep '^r' trace.tr | grep ' tcp ' | python endtime.py > endtime.out

