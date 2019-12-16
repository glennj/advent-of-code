#!/bin/sh
cd "$(dirname "$0")/lib"
echo 'pkg_mkIndex -verbose . *.tcl' | tclsh
ls -l ./pkgIndex.tcl
