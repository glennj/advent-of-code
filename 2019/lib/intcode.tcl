#!/usr/bin/env tclsh

oo::class create IntCode {
    variable prog input seq dbg ptr

    constructor {program {debug false}} {
        set prog $program
        set seq [split $program ,]
        set dbg $debug

        # validate
        foreach elem $seq {
            if {![string is integer -strict $elem]} {
                error "invalid program: $elem is not an integer"
            }
        }
    }

    method setAt {position value} {
        lset seq $position $value
    }

    method evaluate {{inputs {}}} {
        set input $inputs
        my execute
        return [lindex $seq 0]
    }

    method _getInput {} {
        set input [lassign $input value]
        return $value
    }

    method execute {} {
        set ptr 0

        while {$ptr < [llength $seq]} {
            set opcode [lindex $seq $ptr]
            set op [expr {$opcode % 100}]
            switch -exact -- $op {
                99 {
                    my _debug [list $ptr $opcode]
                    incr ptr 1
                    break
                }
                1 { my _binaryMathOperation + }
                2 { my _binaryMathOperation * }
                3 {
                    set position [lindex $seq $ptr+1]
                    lset seq $position [my _getInput]
                    incr ptr 2
                }
                4 {
                    set position [lindex $seq $ptr+1]
                    set value [lindex $seq $position]
                    puts $value
                    incr ptr 2
                }
            }
        }

        return [join $seq ,]
    }

    # a binary math operation looks like
    #     a,b,c,d
    # where
    #     a = the op code
    #     b = the first operand parameter
    #     c = the second operand parameter
    #     d = the position where the result is written
    method _binaryMathOperation {operation} {
        lassign [lrange $seq $ptr $ptr+3] opcode param1 param2 dest
        set op1 [my _getOperand 1 $opcode]
        set op2 [my _getOperand 2 $opcode]
        set result [::tcl::mathop::$operation $op1 $op2]
        my _debug [list $ptr [list $opcode $param1 $param2 $dest] $op1 $op2 $result]
        lset seq $dest $result
        incr ptr 4
    }

    method _getOperand {idx opcode} {
        set param [lindex $seq $ptr+$idx]
        set divisor [expr {100 * 10**(2 - $idx)}]
        set mode [expr {($opcode / $divisor) % 10}]
        if {$mode == 0} {
            # position mode
            return [lindex $seq $param]
        } else {
            # immediate mode
            return $param
        }
    }

    method _debug {msg} {
        if {$dbg} {puts $msg}
    }
}
