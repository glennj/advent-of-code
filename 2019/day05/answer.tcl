#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require intCode

set fh [open "$scriptDir/input" r]
set program [read -nonewline $fh]
close $fh

# part 1
set intcode [IntCode new $program false]
puts [$intcode evaluate {1}]

# part 2
set intcode [IntCode new $program false]
puts [$intcode evaluate {5}]
