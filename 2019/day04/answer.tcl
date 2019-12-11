#!/usr/bin/env tclsh

lappend auto_path ../lib
package require passwords

proc answer {} {
    set input 256310-732736
    lassign [split $input -] start end
    set numValid1 0
    set numValid2 0
    for {set p $start} {$p <= $end} {incr p} {
        if {[passwords::valid $p]} {
            incr numValid1
        }
        if {[passwords::valid2 $p]} {
            incr numValid2
        }
    }
    puts [list $numValid1 $numValid2]
}

answer
