#!/usr/bin/env tclsh

set scriptDir [file dirname [info script]]
lappend auto_path [file join $scriptDir .. lib]
package require moon

set initialPositions {
    {x 14 y 2 z 8}
    {x 7 y 4 z 10}
    {x 1 y 17 z 16}
    {x -4 y -1 z 1}
}

set moons [Moons new $initialPositions]
$moons step 1000
puts [$moons totalEnergy]

set moons [Moons new $initialPositions]
puts [$moons stepsUntilRepeatedState]
