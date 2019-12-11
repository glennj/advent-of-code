#!/usr/bin/env tclsh

package provide space_image_format 1.0

oo::class create SpaceImageFormat {
    variable height width data layers

    constructor {Width Height Data} {
        set width $Width
        set height $Height
        set data $Data
        set layers [list]
    }

    method layers {} {
        if {[llength $layers] == 0} {
            set size [expr {$height * $width}]
            foreach layerData [regexp -inline -all ".{$size}" $data] {
                set rows [regexp -inline -all ".{$width}" $layerData]
                lappend layers [lmap row $rows {split $row ""}]
            }
        }
        return $layers
    }

    method decode {} {
        set result [lrepeat $height [lrepeat $width ""]]
        for {set row 0} {$row < $height} {incr row} {
            for {set col 0} {$col < $width} {incr col} {
                lset result $row $col [my _getPixel $row $col]
            }
        }
        return $result
    }

    method _getPixel {row col} {
        set colors [lmap layer [my layers] {lindex $layer $row $col}]
        # find first non-transparent color
        set color [lsearch -inline -regex $colors {[^2]}]
        if {$color eq ""} {set color 2}
        return $color
    }
}
