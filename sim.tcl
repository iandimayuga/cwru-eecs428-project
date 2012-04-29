# Ian Dimayuga (icd3)
# EECS 428 Project

#initialize simulator engine
set ns [new Simulator]

set episode 4
set n 10
set runtime 2000
set nam "false"

# Configure Defaults
Agent/TCP/Sack1 set tcpTick_ 0.01 
Agent/TCP/Sack1 set window_ 256
Agent/TCP/Sack1 set maxcwnd_ 256 
Agent/TCP/Sack1 set windowInitOption_ 1 
Agent/TCP/Sack1 set windowInit_ 2 
Agent/TCP/Sack1 set packetSize_ 1460B
Agent/TCP/Sack1 set slow_start_restart_ false 
Agent/TCPSink/Sack1/DelAck set interval_ 50ms
Agent/UDP set packetSize_ 1500B
Queue set limit_ 512

#flow id counter
set fid 0

if {$nam} {
  set nf [open "ep$episode/ep$episode.nam" w]
  $ns namtrace-all $nf
}

set tf [open "trace.tr" w]
$ns trace-all $tf

proc finish {} {
  global ns tf nam episode
  $ns flush-trace
  #Close the Trace file
  close $tf
  
  if {$nam} {
    global nf
    #Close the NAM trace file
    close $nf
  }

  puts "Simulation complete."

  exit 0
}


Class Elephant
Elephant instproc init {isSource name arena} {
  global ns
  #initialize node
  $self instvar m_node
  set m_node [$ns node]

  #declare agent
  $self instvar m_agent

  #declare application
  $self instvar m_ftp

  #source elephant or sink elephant
  if {$isSource} {
    set m_agent [new Agent/TCP/Sack1]
    $m_agent set class_ 2
    if { $arena == 2} {
      puts "special guy"
      $m_agent set window_ 668
      $m_agent set maxcwnd_ 668
    }

    set m_ftp [new Application/FTP]
    $m_ftp attach-agent $m_agent
    $m_ftp set type_ FTP

    global fid
    $m_agent set fid_ [incr fid]
    puts "[$m_agent set fid_] is an elephant"

    global nam
    if {$nam} {
      $ns color [$m_agent set fid_] Red
    }
  } else {
    set m_agent [new Agent/TCPSink/Sack1/DelAck]
  }
  $ns attach-agent $m_node $m_agent
}
Elephant instproc connect {other starttime} {
  global ns
  $self instvar m_agent
  $ns connect $m_agent [$other set m_agent] 

  $self instvar m_ftp
  $ns at $starttime "$m_ftp send 419430400"
}

Class Browser
Browser instproc init {name} {
  global ns
  #initialize nodes
  $self instvar m_srcnode
  set m_srcnode [$ns node]
  $self instvar m_snknode
  set m_snknode [$ns node]

  #declare agents
  $self instvar m_tcpsrc
  $self instvar m_udpsrc
  $self instvar m_tcpsink
  $self instvar m_udpsink

  #declare applications
  $self instvar m_pareto
  $self instvar m_voip

  set m_tcpsrc [new Agent/TCP/Sack1]
  set m_pareto [new Application/Traffic/Pareto]
  $m_pareto set packetSize_ 1460B
  $m_pareto set burst_time_ 500ms
  $m_pareto set idle_time_ 60s

  #given a 500ms burst time and a 1500B packet size with an intended 8k minimum transfer
  $m_pareto set rate_ 128k
  $m_pareto set shape_ 1.5

  set m_udpsrc [new Agent/UDP]
  set m_voip [new Application/Traffic/Exponential]
  $m_voip set packetSize_ 1500B
  $m_voip set burst_time_ 60s 
  $m_voip set idle_time_ 180s
  $m_voip set rate_ 56k

  global fid
  $m_tcpsrc set fid_ [incr fid]
  #puts "[$m_tcpsrc set fid_] $name pareto"
  $m_udpsrc set fid_ [incr fid]
  #puts "[$m_udpsrc set fid_] $name voip"

  global nam
  if {$nam} {
    $ns color [$m_tcpsrc set fid_] Green
    $ns color [$m_udpsrc set fid_] Blue
  }

  #attach applications to agents
  $m_pareto attach-agent $m_tcpsrc
  $m_voip attach-agent $m_udpsrc

  $ns at 0.0 "$m_pareto start"
  $ns at 0.0 "$m_voip start"

  set m_tcpsink [new Agent/TCPSink/Sack1/DelAck]
  set m_udpsink [new Agent/Null]

  #attach agents to nodes
  $ns attach-agent $m_srcnode $m_tcpsrc
  $ns attach-agent $m_snknode $m_tcpsink
  $ns attach-agent $m_srcnode $m_udpsrc
  $ns attach-agent $m_snknode $m_udpsink
}
Browser instproc connect { other} {
  global ns
  $self instvar m_tcpsrc
  $self instvar m_tcpsink
  $self instvar m_udpsrc
  $self instvar m_udpsink
  $ns connect $m_tcpsrc [$other set m_tcpsink] 
  $ns connect $m_udpsrc [$other set m_udpsink]
  $ns connect [$other set m_tcpsrc] $m_tcpsink
  $ns connect [$other set m_udpsrc] $m_udpsink
}

Class Region
Region instproc init {num isWest arena} {
  global ns

  #Router node
  $self instvar m_router
  
  #Browsers
  $self instvar m_browsers

  #Elephant
  $self instvar m_elephant

  set m_router [$ns node]
  puts "[$m_router id] is a router"

  set m_elephant [new Elephant $isWest "Elephant $arena" $arena]
  $ns duplex-link [$m_elephant set m_node] $m_router 1G 1ms DropTail

  for {set i 0} {$i < $num} {incr i} {
    if {$isWest} {
      set m_browsers($i) [new Browser "Browser_west_arena$arena"]
    } else {
      set m_browsers($i) [new Browser "Browser_east_arena$arena"]
    }

    $ns duplex-link [$m_browsers($i) set m_srcnode] $m_router 300k 50ms DropTail
    $ns duplex-link [$m_browsers($i) set m_snknode] $m_router 300k 50ms DropTail
  }
}

#backbone routers
set rWest [$ns node]
set rEast [$ns node]
puts "[$rWest id] is a router"
puts "[$rEast id] is a router"

#backbone
$ns duplex-link $rWest $rEast 10Mb 20ms DropTail

#elephant start times
set starttime(0) 7
set starttime(1) 6
set starttime(2) 5

#access link latencies
set latencies(0) 10ms
set latencies(1) 50ms
set latencies(2) 200ms

#for each arena
for {set i 0} {$i < 3} {incr i} {
  set wests($i) [new Region $n "true" [expr $i+1]]
  set easts($i) [new Region $n "false" [expr $i+1]]

  $ns duplex-link [$wests($i) set m_router] $rWest 100Mb $latencies($i) DropTail
  $ns duplex-link [$easts($i) set m_router] $rEast 100Mb $latencies($i) DropTail

  [$wests($i) set m_elephant] connect [$easts($i) set m_elephant] $starttime($i)

  for {set j 0} {$j < $n} {incr j} {
    [$wests($i) set m_browsers($j)] connect [$easts($i) set m_browsers($j)]
  }
}

for {set i 0} {$i <= $runtime} {incr i 10} {
  $ns at $i "puts \"$i seconds\""
}

$ns at $runtime "finish"

if {$nam} {
  puts "NAM trace active."
}

puts "Starting simulation..."
$ns run
