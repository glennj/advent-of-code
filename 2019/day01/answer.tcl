#!/usr/bin/env tclsh

lappend auto_path ../lib
package require fuel_counter_upper

proc answer {} {
    set fh [open "./input" r]
    set modules [regexp -all -inline {\d+} [read $fh]]
    # part 1
    puts [requiredFuel $modules]
    # part 2
    puts [requiredFuelAccountingForWeightOfFuel $modules]
}

answer
