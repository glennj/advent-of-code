#!/usr/bin/env tclsh

package provide passwords 1.0

namespace eval passwords {
    proc containsDouble {pw} {
        regexp {(\d)\1} $pw
    }

    proc containsExactDouble {pw} {
        set runs [list]
        set digits [split $pw ""]
        set prev [lindex $digits 0]
        set run 1
        for {set i 1} {$i <= 5} {incr i} {
            set digit [lindex $digits $i]
            if {$digit == $prev} {
                incr run
            } else {
                lappend runs $run
                set run 1
            }
            set prev $digit
        }
        lappend runs $run
        return [expr {2 in $runs}]
    }

    proc nonDecreasing {pw} {
        set digits [split $pw ""]
        for {set i 0} {$i < 5} {incr i} {
            lassign [lrange $digits $i $i+1] a b
            if {$a > $b} {
                return 0
            }
        }
        return 1
    }

    proc valid {pw} {
        return [expr {
            [regexp {^\d{6}$} $pw] &&
            [containsDouble $pw] &&
            [nonDecreasing $pw]
        }]
    }

    proc valid {pw} {
        return [expr {
            [regexp {^\d{6}$} $pw] &&
            [containsDouble $pw] &&
            [nonDecreasing $pw]
        }]
    }

    proc valid2 {pw} {
        return [expr {
            [regexp {^\d{6}$} $pw] &&
            [containsExactDouble $pw] &&
            [nonDecreasing $pw]
        }]
    }
}
