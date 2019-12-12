#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require orbitMap

set fh [open "$scriptDir/input.txt" r]
set input [read -nonewline $fh]
close $fh

# part 1
set orbitMap [OrbitMap new]
$orbitMap parse $input
puts [$orbitMap totalOrbits]

# part 2
puts [$orbitMap numOrbitalTransfers YOU SAN]
