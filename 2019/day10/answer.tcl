#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require asteroidMonitoring

set fh [open "$scriptDir/input" r]
set map [read -nonewline $fh]
close $fh

set mon [AsteroidMonitoring new $map]
set best [$mon bestLocation]
$mon base {*}$best
puts [list $best [$mon seen]]

# part 2

set vaporized [$mon vaporize]
set wanted [lindex $vaporized 200-1]
lassign $wanted x y
puts [expr {100 * $x + $y}]
