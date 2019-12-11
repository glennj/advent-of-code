#!/usr/bin/env tclsh

lappend auto_path ../lib
package require intcode

cd ../day09
set fh [open "./input" r]
set input [read -nonewline $fh]
close $fh

set intcode [IntCode new $input ]
puts [$intcode evaluate 1]

# part 2
set intcode [IntCode new $input ]
puts [$intcode evaluate 2]
