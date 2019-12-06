#!/usr/bin/env tclsh

source ../lib/fuel-counter-upper.tcl

proc answer {} {
    set fh [open "./input.day01" r]
    set modules [regexp -all -inline {\d+} [read $fh]]
    # part 1
    puts [requiredFuel $modules]
    # part 2
    puts [requiredFuelAccountingForWeightOfFuel $modules]
}

answer
