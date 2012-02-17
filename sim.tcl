# Ian Dimayuga (icd3)
# EECS 428 Episode 1

# Configure Defaults
Agent/TCP/Sack1 set tcpTick_ 0.01 
Agent/TCP/Sack1 set window_ 256
Agent/TCP/Sack1 set maxcwnd_ 256 
Agent/TCP/Sack1 set windowInitOption_ 1 
Agent/TCP/Sack1 set windowInit_ 2 
Agent/TCP/Sack1 set packetSize_ 1500
Agent/TCP/Sack1 set slow_start_restart_ false 
Agent/TCPSink/Sack1/DelAck set interval_ 50ms

#initialize simulator engine
set ns [new Simulator]

Class Elephant
Elephant instproc init {isSource} {
  global ns
  #initialize node
  $self instvar m_node
  set m_node [$ns node]

  #declare agent
  $self instvar m_agent

  #source elephant or sink elephant
  if {$isSource} {
    set m_agent [new Agent/TCP/Sack1]
    $m_agent set class_ 2
  } else {
    set m_agent [new Agent/TCPSink/Sack1/DelAck]
  }
  $ns attach-agent $m_node $m_agent
}

Class Browser
Browser instproc init {} {
  global ns
  #initialize node
  $self instvar m_node
  set m_node [$ns node]

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
  $m_pareto set packetSize_ 1500
  $m_pareto set burst_time_ 500ms
  $m_pareto set idle_time_ 60s

  #given a 500ms burst time and a 1500B packet size with an intended 8k minimum transfer
  $m_pareto set rate_ 128k
  $m_pareto set shape_ 1.5

  set m_udpsrc [new Agent/UDP]
  set m_voip [new Application/Traffic/Exponential]
  $m_voip set packetSize_ 1500
  $m_voip set burst_time_ 60ms 
  $m_voip set idle_time_ 180ms
  $m_voip set rate_ 56k

  #attach applications to agents
  $m_pareto attach-agent $m_tcpsrc
  $m_voip attach-agent $m_udpsrc

  set m_tcpsink [new Agent/TCPSink/Sack1/DelAck]
  set m_udpsink [new Agent/Null]

  #attach agents to nodes
  $ns attach-agent $m_node $m_tcpsrc
  $ns attach-agent $m_node $m_tcpsink
  $ns attach-agent $m_node $m_udpsrc
  $ns attach-agent $m_node $m_udpsink
}

Class Region
Region instproc init {num, isWest} {
  global ns

  #Router node
  $self instvar m_router
  
  #Browsers
  $self instvar m_browsers

  #Elephant
  $self instvar m_elephant

  set m_router [$ns node]
  for {set i 0} {$i < $num} {incr i} {
    set m_browsers($i) [new Browser]

    $ns duplex-link $m_sources($i) $m_router 300k 50ms DropTail
    $ns duplex-link $m_sinks($i) $m_router 300k 50ms DropTail
  }

  set m_elephant [new Elephant $isWest]
  $ns duplex-link $m_elephant $m_router 1G 1ms DropTail
}

#backbone routers
set rWest [$ns node]
set rEast [$ns node]

#backbone
$ns duplex-link $rWest $rEast 

set n 10
set latencies(0) 10ms
set latencies(1) 50ms
set latencies(2) 200ms

set wests(0) [new Region $n "true"]
set wests(1) [new Region $n "true"]