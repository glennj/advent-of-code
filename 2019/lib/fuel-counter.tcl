#!/usr/bin/env tclsh

package provide fuelCounter 1.0

namespace eval ::fuelCounter {
    namespace export *

    proc requiredFuel {modules} {
        set fuelNeeded 0
        foreach module $modules {
            incr fuelNeeded [fuelFor $module]
        }
        return $fuelNeeded
    }

    proc fuelFor {module} {
        set fuel [expr {int($module / 3) - 2}]
        return [expr {max($fuel, 0)}]
    }

    proc requiredFuelAccountingForWeightOfFuel {modules} {
        set total 0
        foreach module $modules {
            set fuel [fuelFor $module]
            while {$fuel > 0} {
                incr total $fuel
                set fuel [fuelFor $fuel]
            }
        }
        return $total
    }
}
