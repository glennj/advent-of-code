#!/usr/bin/env tclsh

lappend auto_path ../lib
package require space_image_format

cd ../day08
set fh [open "./input" r]
set input [read -nonewline $fh]
close $fh

set image [SpaceImageFormat new 25 6 $input]

set layers [$image layers]
set zeroes [lmap layer $layers {regexp -all {0} [join $layer ""]}]
set min [::tcl::mathfunc::min {*}$zeroes]
set idx [lsearch -exact $zeroes $min]
set layer [lindex $layers $idx]
set ones [regexp -all 1 $layer]
set twos [regexp -all 2 $layer]
puts [expr {$ones * $twos}]

# part 2

foreach row [$image decode] {
    puts [string map {0 " " 1 *} [join $row ""]]
}
