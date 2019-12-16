#!/usr/bin/env tclsh

package provide miscUtils 1.0

# Greatest Common Divisor of two numbers.
# Will always return a positive number.
#
proc ::tcl::mathfunc::gcd {a b} {
    if {$b == 0} then {return [expr {abs($a)}]}
    set procname [lindex [info level 0] 0]
    tailcall $procname $b [expr {$a % $b}]
}

# foreachWithIndex -- maintain an index counter for a foreach loop
#
#     % foreachWithIndex {i elem} {foo bar baz} {puts "$i $elem"}
#     0 foo
#     1 bar
#     2 baz
#
proc ::foreachWithIndex {varNames list script} {
    upvar 1 [lindex $varNames 0] idx
    upvar 1 [lindex $varNames 1] elem
    set idx 0
    foreach elem $list {
        uplevel 1 $script
        incr idx
    }
}

proc ::commify {num} {
    while {[regsub {(\d+)(\d{3})} $num {\1,\2} num]} {}
    return $num
}
