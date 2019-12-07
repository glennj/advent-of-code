#!/usr/bin/env tclsh

source ../lib/orbit-map.tcl

set fh [open "./input.txt" r]
set input [read -nonewline $fh]
close $fh

# part 1
set orbitMap [OrbitMap new]
$orbitMap parse $input
puts [$orbitMap totalOrbits]

# part 2
puts [$orbitMap numOrbitalTransfers YOU SAN]
