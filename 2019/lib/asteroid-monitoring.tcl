#!/usr/bin/env tclsh

package provide asteroidMonitoring 1.0
package require miscUtils

oo::class create AsteroidMonitoring {
    variable asteroids
    variable base

    constructor {map} {
        foreachWithIndex {y row} [split $map \n] {
            foreachWithIndex {x char} [split $row ""] {
                if {$char eq "#"} {
                    lappend asteroids [list $x $y]
                }
            }
        }
    }

    method asteroids {} {
        return $asteroids
    }

    method base {x y} {
        set base [list $x $y]
    }

    # return the number of asteroids seen from the given position
    method seen {} {
        if {![info exists base]} then {error "base not set"}
        set slopes [my _slopes]
        return [dict size [my _slopes]]
    }

    method _slopes {} {
        set slopes {}
        foreach asteroid $asteroids {
            if {$base eq $asteroid} then continue
            set slope [my _slopeBetween $base $asteroid]
            set dist [my _distanceBetween $base $asteroid]
            dict lappend slopes $slope [list $asteroid $dist]
        }
        return $slopes
    }

    method _slopeBetween {a b} {
        lassign [my _dxdy $a $b] dx dy
        set gcd [expr {gcd($dx, $dy)}]
        return [list [expr {$dx / $gcd}] [expr {$dy / $gcd}]]
    }

    method _distanceBetween {a b} {
        lassign [my _dxdy $a $b] dx dy
        return [expr {sqrt($dx**2 + $dy**2)}]
    }

    method _dxdy {a b} {
        lassign $a ax ay
        lassign $b bx by
        set dy [expr {$ay - $by}]
        set dx [expr {$bx - $ax}]
        return [list $dx $dy]
    }

    method bestLocation {} {
        set num {}
        foreach asteroid $asteroids {
            my base {*}$asteroid
            dict lappend num [my seen] $asteroid
        }
        set best [::tcl::mathfunc::max {*}[dict keys $num]]
        return [lindex [dict get $num $best] 0]
    }

    method vaporize {} {
        set vaporized [list]
        set slopes [my _slopes]
        set iter 1
        while {[dict size $slopes] > 0} {
            set ordered [my _order [dict keys $slopes]]
            foreach slope $ordered {
                set asteroids [lsort -real -index 1 [dict get $slopes $slope]]
                set asteroids [lassign $asteroids closest]
                if {[llength $asteroids] == 0} {
                    dict unset slopes $slope
                } else {
                    dict set slopes $slope $asteroids
                }
                lappend vaporized [lindex $closest 0]
            }
            incr iter
        }
        return $vaporized
    }

    method _order {slopes} {
        set toRadian {slope {
            set pi [expr {atan2(0, -1)}]
            lassign $slope dx dy
            set theta [expr {atan2($dx, $dy)}] ;# flipped args
            expr {($theta < 0 ? 2*$pi : 0) + $theta}
        }}
        set keys [lmap slope $slopes {list $slope [apply $toRadian $slope]}]
        return [lmap tuple [lsort -real -index 1 $keys] {lindex $tuple 0}]
    }
}
