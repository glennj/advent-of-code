#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require intCode

set fh [open "$scriptDir/input" r]
set input [read -nonewline $fh]
close $fh

set intcode [IntCode new $input ]
puts [$intcode evaluate 1]

# part 2
set intcode [IntCode new $input ]
puts [$intcode evaluate 2]
