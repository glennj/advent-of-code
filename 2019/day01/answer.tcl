#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require fuelCounter

proc answer {} {
    set fh [open "$::scriptDir/input" r]
    set modules [regexp -all -inline {\d+} [read $fh]]
    # part 1
    puts [fuelCounter::requiredFuel $modules]
    # part 2
    puts [fuelCounter::requiredFuelAccountingForWeightOfFuel $modules]
}

answer
