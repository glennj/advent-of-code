#!/usr/bin/env tclsh

package provide thrusters 1.0

package require intcode
package require Thread

oo::class create Thrusters {
    variable num
    variable program
	variable debug

    constructor {_program {_debug false}} {
        set num 5
        set program $_program
		set debug $_debug
    }

    method run {settings} {
		my _validate_run $settings
        set result 0
        for {set i 0} {$i < $num} {incr i} {
            set amp [IntCode new $program]
            set input [list [lindex $settings $i] $result]
			my _debug [list $input]
            set result [$amp evaluate $input]
			my _debug ">> $result"
        }
        return $result
    }

	method _validate_run {settings} {
		set msg "expecting a list of $num integers between 0 and 4"
		if {[llength $settings] != 5} {
			error $msg
		}
		foreach setting $settings {
			if {![string is integer -strict $setting] || $setting < 0 || $setting > 4} {
				error $msg
			}
		}
	}

	method _debug {msg} {
		if {$debug} {puts $msg}
	}
}
