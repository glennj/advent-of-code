#!/usr/bin/env tclsh

lappend auto_path ../lib
package require intcode

set fh [open "./input" r]
set program [read -nonewline $fh]
close $fh

# part 1
set intcode [IntCode new $program false]
puts [$intcode evaluate {1}]

# part 2
set intcode [IntCode new $program false]
puts [$intcode evaluate {5}]
