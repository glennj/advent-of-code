#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require thrusters

set fh [open "$scriptDir/input" r]
set input [read -nonewline $fh]
close $fh

# part 1
# taken from https://wiki.tcl-lang.org/page/Combinatorial+mathematics+functions
proc permutations { list size } {
    if { $size == 0 } {
        return [list [list]]
    }
    set retval {}
    for { set i 0 } { $i < [llength $list] } { incr i } {
        set firstElement [lindex $list $i]
        set remainingElements [lreplace $list $i $i]
        foreach subset [permutations $remainingElements [expr { $size - 1 }]] {
            lappend retval [linsert $subset 0 $firstElement]
        }
    }
    return $retval 
}

set max -1
foreach settings [permutations {0 1 2 3 4} 5] {
    set thrusters [Thrusters new $input]
    set output [$thrusters run $settings]
    set max [expr {max($max, $output)}]
}
puts $max


# part 2
