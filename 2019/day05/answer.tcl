#!/usr/bin/env tclsh

source ../lib/intcode.tcl

set fh [open "./input" r]
set program [read -nonewline $fh]
close $fh

# part 1
set intcode [IntCode new $program false]
$intcode evaluate {1}

# part 2
set intcode [IntCode new $program false]
$intcode evaluate {5}
