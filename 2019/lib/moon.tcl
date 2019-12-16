#!/usr/bin/env tclsh

package provide moon 1.0
package require miscUtils

oo::class create Moons {
    variable moons debug

    constructor {initialPositions {Debug false}} {
        if {[llength $initialPositions] != 4} {
            error "incorrect number of initial positions"
        }
        set names {Io Europa Ganymede Callisto}
        foreach name $names pos $initialPositions {
            lappend moons [Moon new $name $pos]
        }
        set debug $Debug
    }

    method moons {} {return $moons}

    method toString {} {
        set out {}
        foreach moon $moons {
            lappend out [$moon toString]
        }
        return [join $out \n]
    }

    method state {} {
        return [binary format s6s6s6s6 {*}[lmap moon $moons {$moon state}]]
    }

    method step {{n 1}} {
        for {set i 1} {$i <= $n} {incr i} {
            set deltas {}
            foreach moon $moons {
                lappend deltas [my _delta $moon]
            }
            foreach moon $moons delta $deltas {
                $moon applyDelta $delta
            }
        }
    }

    method _delta {moon} {
        set delta {x 0 y 0 z 0}
        foreach other $moons {
            if {$moon eq $other} then continue
            set pairDelta [$moon deltaFor $other]
            foreach i {x y z} {
                dict incr delta $i [dict get $pairDelta $i]
            }
        }
        return $delta
    }

    method totalEnergy {} {
        set e 0
        foreach moon $moons {
            incr e [$moon energy]
        }
        return $e
    }

    method stepsUntilRepeatedState {} {
        set step 0
        set states [dict create]
        set t [clock seconds]
        while true {
            set state [my state]
            if {[dict exists $states $state]} {
                break
            }
            dict set states $state $step
            my step
            incr step
            if {$step % 100000 == 0} {
                set tt [clock seconds]
                puts [list [incr tt -$t] [commify $step]]
                incr t $tt
            }
        }
        return $step
    }
}

oo::class create Moon {
    variable name position velocity

    constructor {Name Position} {
        set name $Name
        foreach key {x y z} {
            if {![dict exists $Position $key]} {
                error "invalid position: $key missing"
            }
        }
        set position $Position
        set velocity {x 0 y 0 z 0}
    }

    method toString {} {
        return [list $name pos $position vel $velocity]
    }

    method state {} {
        return [concat [dict values $position] [dict values $velocity]]
    }

    method position {} {return $position}
    method velocity {} {return $velocity}

    method x {} {dict get $position x}
    method y {} {dict get $position y}
    method z {} {dict get $position z}

    method deltaFor {other} {
        set delta {x 0 y 0 z 0}
        foreach i {x y z} {
            set result 0
            if {[my $i] < [$other $i]} {
                set result 1
            } elseif {[my $i] > [$other $i]} {
                set result -1
            }
            dict set delta $i $result
        }
        return $delta
    }

    method applyDelta {delta} {
        foreach i {x y z} {
            dict incr position $i [dict get $delta $i]
            dict incr position $i [dict get $velocity $i]
            dict incr velocity $i [dict get $delta $i]
        }
    }

    method energy {} {
        set potential [my _sum $position]
        set kinetic   [my _sum $velocity]
        return [expr {$potential * $kinetic}]
    }

    method _sum {vector} {
        set values [lmap v [dict values $vector] {expr {abs($v)}}]
        return [::tcl::mathop::+ {*}$values]
    }
}
