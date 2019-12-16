#!/usr/bin/env tclsh

package provide intCode 1.0

oo::class create IntCode {
    variable program debug ptr
    #variable input
    #variable output
    variable opcode
    variable relativeBase

    constructor {Program {Debug false}} {
        set program {}
        set idx -1
        foreach elem [split $Program ,] {
            if {![string is entier -strict $elem]} {
                error "invalid program: $elem is not an integer"
            }
            dict set program [incr idx] $elem
        }
        set debug $Debug
        set relativeBase 0
    }

    method at {position {value ""}} {
        if {[string is entier -strict $value]} {
            my _setAt $position $value
        } else {
            return [my _getAt $position]
        }
    }

    method _setAt {position value} {
        if {$position < 0} {
            error "invalid position: $position"
        }
        my _debug "-- store $value at $position"
        dict set program $position $value
    }

    method _getAt {position} {
        if {$position < 0} {
            error "invalid position: $position"
        }
        if {![dict exists $program $position]} {
            dict set program $position 0
        }
        return [dict get $program $position]
    }

    method program {} {
        set p {}
        foreach idx [lsort -integer [dict keys $program]] {
            lappend p [dict get $program $idx]
        }
        return [join $p ,]
    }

    method evaluate {{inputs {}}} {
        coroutine producer apply {{inputs} {
            yield
            foreach input $inputs {yield $input}
        }} $inputs
        coroutine executor [self] execute producer
        set output [list]
        while true {
            set value [executor]
            if {[info command executor] eq ""} then break
            #puts "got output value >$value<"
            lappend output $value
        }
        return $output
    }

#    method _getInput {} {
#        # shift the next value from the inputs
#        set input [lassign $input value]
#        return $value
#        return [yield]
#    }

    method execute {{producer ""}} {
        if {$producer ne ""} {yield [info coroutine]}
        set ptr 0

        while true {
            set opcode [my at $ptr]
            set op [expr {$opcode % 100}]
            switch -exact -- $op {
                99 {
                    my _debug "exit"
                    incr ptr 1
                    break
                }
                1 { my _binaryMathOperation + }
                2 { my _binaryMathOperation * }
                3 { my _getInput $producer }
                4 { my _output }
                5 { my _jump true }
                6 { my _jump false }
                7 { my _cmp < }
                8 { my _cmp == }
                9 { my _setRelativeBase }
                default { error "unknown opcode: $opcode" }
            }
        }
    }

    method _setRelativeBase {} {
        incr relativeBase [my _getOperand 1]
        incr ptr 2
    }

    method _getInput {producer} {
        set value [$producer]
        #puts [list [info level 0] $producer $value]
        my at [my _getPosition 1] $value
        incr ptr 2
    }

    method _output {} {
        #lappend output [my at [my _getPosition 1]]
        set value [my at [my _getPosition 1]]
        #puts "about to yield >$value<"
        yield $value
        incr ptr 2
    }

    method _jump {trueFalse} {
        set value [my _getOperand 1]
        set dest  [my _getOperand 2]
        set msg [list [list $value $dest] "jump-if-[expr {$trueFalse ? "true" : "false"}]"]
        if {($trueFalse && $value != 0) || (!$trueFalse && $value == 0)} {
            set ptr $dest
        } else {
            incr ptr 3
        }
        lappend msg $ptr
        my _debug $msg
    }

    method _cmp {func} {
        set op1  [my _getOperand 1]
        set op2  [my _getOperand 2]
        set dest [my _getPosition 3]
        set result [::tcl::mathop::$func $op1 $op2]
        my _debug [list [list $func $op1 $op2 $dest] $result]
        my at $dest $result
        incr ptr 4
    }


    # a binary math operation looks like
    #     a,b,c,d
    # where
    #     a = the op code
    #     b = the first operand parameter
    #     c = the second operand parameter
    #     d = the position where the result is written
    method _binaryMathOperation {operation} {
        set op1  [my _getOperand 1]
        set op2  [my _getOperand 2]
        set dest [my _getPosition 3]
        set result [::tcl::mathop::$operation $op1 $op2]
        my _debug [list $operation $op1 $op2 $result $dest]
        my at $dest $result
        incr ptr 4
    }

    method _getOperand {idx} {
        set param [my at [expr {$ptr + $idx}]]
        set divisor [expr {100 * 10**($idx - 1)}]
        set mode [expr {($opcode / $divisor) % 10}]
        # when we want to get an operand,
        # mode 0 is "position" -- return the value at the position
        #                           given by the parameter
        # mode 1 is "immediate" -- return the parameter
        # mode 2 is "relative"
        switch -exact -- $mode {
            0 {return [my at $param]}
            1 {return $param}
            2 {return [my at [expr {$param + $relativeBase}]]}
            default {error "unknown mode $mode in opcode $opcode at position $ptr"}
        }
    }

    method _getPosition {idx} {
        set param [my at [expr {$ptr + $idx}]]
        set divisor [expr {100 * 10**($idx - 1)}]
        set mode [expr {($opcode / $divisor) % 10}]

        # when we want to get a *position*, 
        # mode 0 is "immediate" -- return the parameter
        # mode 1 is "position" -- return the current pointer plus idx
        # mode 2 is "relative"
        switch -exact -- $mode {
            0 {return $param}
            1 {return [expr {$ptr + $idx}]}
            2 {return [expr {$param + $relativeBase}]}
            default {error "unknown mode $mode in opcode $opcode at position $ptr"}
        }
    }

    method _debug {msg} {
        if {$debug} {puts [list $ptr $opcode $msg]}
    }
}
