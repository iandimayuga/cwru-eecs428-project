# Ian Dimayuga (icd3)

all:
	@echo "Please specify an Episode."

ep2: ep2.tr ep2_test

ep2_test: ep2_exp_on_off ep2_packet_size ep2_delack ep2_delack_count ep2_endtime

ep2.tr:
	@echo "Running Episode 2..."
	@ns ep2/ep2.tcl | tee ep2/ep2.out

ep2_exp_on_off:
	@echo "Calculating Mean Exponential burst and idle times..."
	@grep '^r' ep2/ep2.tr | grep ' exp ' | python ep2/exp_on_off.py

ep2_packet_size:
	@echo "Verifying packet sizes..."
	@grep '^r' ep2/ep2.tr | grep -v ' ack ' | python ep2/packet_size.py

ep2_delack:
	@echo "Verifying DelAck timeouts..."
	@egrep '(^r|^\+)' ep2/ep2.tr | python ep2/delack.py | sort | uniq -c

ep2_delack_count:
	@echo "Verifying DelAck ratio..."
	@grep '^r' ep2/ep2.tr | python ep2/delack_count.py

ep2_endtime:
	@echo "Identifying Elephant stop times..."
	@grep '^r' ep2/ep2.tr | grep ' tcp ' | python ep2/endtime.py
