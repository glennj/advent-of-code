#!/usr/bin/env tclsh

package provide crossed_wires 1.0

namespace eval wires {
    proc manhattanDistance {wire1 wire2} {
        set path1 [path $wire1]
        set path2 [path $wire2]
        set crossings [intersection $path1 $path2]
        set distances [lmap point $crossings {distance $point}]
        return [lindex [lsort -integer $distances] 0]
    }

    proc path {wire} {
        set path [list]
        set x [set y 0]
        foreach leg [split $wire ,] {
            if {[scan $leg {%[UDLR]%d} dir len] != 2} {
                error "invalid leg $leg"
            }
            for {set i 1} {$i <= $len} {incr i} {
                switch -exact -- $dir {
                    R { lappend path [list [incr x]    $y] }
                    L { lappend path [list [incr x -1] $y] }
                    U { lappend path [list $x [incr y]] }
                    D { lappend path [list $x [incr y -1]] }
                }
            }
        }
        return $path
    }

    proc intersection {path1 path2} {
        set intersections [list]
        set p1 [dict create]
        foreach point $path1 {
            dict set p1 $point 1
        }
        foreach point $path2 {
            if {[dict exists $p1 $point]} {
                lappend intersections $point
            }
        }
        return $intersections
    }

    proc distance {point} {
        lassign $point x y
        return [expr {abs($x) + abs($y)}]
    }

    proc stepsTo {path point} {
        set idx [lsearch $path $point]
        if {$idx == -1} {
            error "point {$point} not in path {$path}"
        }
        return [incr idx]
    }

    proc signalDelay {path1 path2 point} {
        set delay 0
        incr delay [stepsTo $path1 $point]
        incr delay [stepsTo $path2 $point]
        return $delay
    }

    proc minimumSignalDelay {wire1 wire2} {
        set path1 [path $wire1]
        set path2 [path $wire2]
        set intersections [intersection $path1 $path2]
        set delays [lmap point $intersections {signalDelay $path1 $path2 $point}]
        return [lindex [lsort -integer $delays] 0]
    }
}
