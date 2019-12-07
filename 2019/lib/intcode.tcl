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
                5 { my _jump true }
                6 { my _jump false }
                7 { my _cmp < }
                8 { my _cmp == }
            }
        }

        return [join $seq ,]
    }

    method _jump {trueFalse} {
        set opcode [lindex $seq $ptr]
        set value [my _getOperand 1 $opcode]
        set dest  [my _getOperand 2 $opcode]
        set msg [list $ptr [list $opcode $value $dest]]
        if {($trueFalse && $value != 0) || (!$trueFalse && $value == 0)} {
            set ptr $dest
        } else {
            incr ptr 3
        }
        lappend msg $ptr
        my _debug $msg
    }

    method _cmp {func} {
        set opcode [lindex $seq $ptr]
        set op1 [my _getOperand 1 $opcode]
        set op2 [my _getOperand 2 $opcode]
        set dest [lindex $seq $ptr+3]
        set result [::tcl::mathop::$func $op1 $op2]
        my _debug [list $ptr [list $opcode $op1 $op2 $dest] $result]
        my setAt $dest $result
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
        set divisor [expr {100 * 10**($idx - 1)}]
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
