#!/usr/bin/env tclsh

package provide orbit_map 1.0

oo::class create OrbitMap {
    variable root nodes

    method parse {input} {
        array set nodes {}
        set root ""

        set lines [split [string trim $input] \n]
        if {[llength $lines] == 0} {
            error "empty input"
        }
        foreach line $lines {
            lassign [split $line ")"] parent child
            if {![info exists nodes($parent)]} {
                # this is the root
                set nodes($parent) [OrbitalNode new $parent]
                if {$parent eq "COM"} {
                    set root $nodes($parent)
                }
                #puts "> created parent node $parent"
            }
            if {[info exists nodes($child)]} {
                $nodes($child) setParent $nodes($parent)
            } else {
                set nodes($child) [$nodes($parent) addSatelite $child]
                #puts "> created child node $child orbiting $parent"
            }
        }

        #puts  "map root is [$root name]"
        #puts "there are [array size nodes] nodes"
    }

    method totalOrbits {} {
        return [$root totalOrbits]
    }

    method root {} {
        return $root
    }

    method getNode {name} {
        if {![info exists nodes($name)]} {
            error "no such node in map"
        }
        return $nodes($name)
    }   

    method numOrbitalTransfers {name1 name2} {
        set path1 [[my getNode $name1] path]
        set path2 [[my getNode $name2] path]
        set l1 [llength $path1]
        set l2 [llength $path2]
        set minPathLength [expr {min($l1, $l2)}]
        set i 0
        while {$i <= $minPathLength && [lindex $path1 $i] eq [lindex $path2 $i]} {
            incr i
        }
        return [expr {$l1 + $l2 - 2 * $i}]
    }
}

oo::class create OrbitalNode {
    variable name level children parent

    constructor {Name {Parent ""}} {
        set name $Name
        set parent $Parent
        if {$parent eq ""} {
            set level 0
        } else {
            set level [expr {[$parent orbits] + 1}]
        }
        set children [list]
    }

    method name {} {
        return $name
    }

    method orbits {} {
        return $level
    }

    method parent {} {
        return $parent
    }

    method setParent {node} {
        #puts "> resetting parent for [my name] to [$node name]"
        set parent $node
        my resetOrbits
        $node addSatelite $name [self]
    }

    method resetOrbits {} {
        set level [expr {[$parent orbits] + 1}]
        #puts "> setting level for [my name] to $level"
        my foreach child {$child resetOrbits}
    }

    method addSatelite {name {node ""}} {
        if {$node eq ""} {
            set node [[self class] new $name [self]]
        }
        lappend children $node
        return $node
    }

    method foreach {nodeVar body} {
        upvar 1 $nodeVar node
        foreach node $children {
            uplevel 1 $body
        }
    }

    method totalOrbits {} {
        set sum [my orbits]
        my foreach child {incr sum [$child totalOrbits]}
        return $sum
    }

    method path {} {
        if {$parent ne ""} {
            return [concat [$parent path] [$parent name]]
        }
    }
}
