#: ext_area
# {{{
proc ext_area {} {
  upvar vars vars
  read_file inputs/area.rpt
  while {[llength $flist]} {
    set line [shift $flist]
    if {[regexp {Design  WNS: (\S+)} $line whole WNS]} {
      puts $WNS
    }
  }
}
# }}}
#: ext_capture
# {{{
proc ext_capture {} {
  upvar vars vars
# 2 means capture path
  set ilist $vars(capture_clock_path)
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {<-} $line {} line
    regsub {\(gclock source\)} $line {} line
    set colno [llength [split_by_space $line]]
    #puts "$colno $line"
    if {[regexp {\(net\)} $line]} {
      set netline [split_by_space $line]
      set netname [lindex $netline 0]
      set fanout  [lindex $netline 2]
      set netcap  [lindex $netline 3]
      lappend vars(nets_list) $netname
      set vars(capture,$netname,fanout) $fanout
      set vars(capture,$netname,netcap) $netcap
# cellin
      set cellin [split_by_space [shift ilist]]
      set inst [file dirname [lindex $cellin 0]]
      lappend vars(capture_inst_list) $inst
      set vars(capture,$inst,innet)          $netname
      set vars(capture,$inst,inpin)          [lindex $cellin 0]
      set vars(capture,$inst,refname)        [lindex $cellin 1]
      set vars(capture,$inst,dtrans)         [lindex $cellin 2]
      set vars(capture,$inst,in_trans)       [lindex $cellin 3]
      set vars(capture,$inst,net_derate)     [lindex $cellin 4]
      set vars(capture,$inst,delta)          [lindex $cellin 5]
      set vars(capture,$inst,net_delay)      [lindex $cellin 6]
      set vars(capture,$inst,incr_delay_in)  [lindex $cellin 8]
    }
  }
# cellout line and outnet
  set ilist $vars(capture_clock_path)
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
    regsub {<-} $line {} line
    
    set colno [llength [split_by_space $line]]
    if {$colno == 8} {
      set cellout [split_by_space $line]]
      set inst [file dirname [lindex $cellout 0]]
      set vars(capture,$inst,cell_out_tran)   [lindex $cellout 2]
      set vars(capture,$inst,cell_derate)     [lindex $cellout 3]
      set vars(capture,$inst,cell_delay)      [lindex $cellout 4]
      set vars(capture,$inst,incr_delay_out)  [lindex $cellout 5]
      set netline [split_by_space [shift ilist]]
      set vars(capture,$inst,outnet)          [lindex $netline 0]
    }

# cppr
    set vars(cppr) 0
    if {[regexp {clock reconvergence pessimism         \s+(\S+) } $line whole matched]}  { set vars(cppr)  $matched }
# uncertainty
    set vars(uncertainty) 0
    if {[regexp {uncertainty\s+(\S+) } $line whole matched]}  { set vars(uncertainty)  $matched }
# slack
    if {[regexp {slack \(.*\)\s+(\S+)} $line whole matched]} {set vars(slack) $matched}
  }
}
# ext_launch
# }}}
#: ext_launch
# {{{
proc ext_launch {} {
  upvar vars vars
# 1 means launch path
  #set ilist $vars(1)
  set ilist [concat $vars(launch_clock_path) $vars(data_path)]

  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
    regsub {<-} $line {} line

    set colno [llength [split_by_space $line]]
    #puts "$colno $line"
    if {[regexp {\(net\)} $line]} {
      set netline [split_by_space $line]
      set netname [lindex $netline 0]
      set fanout  [lindex $netline 2]
      set netcap  [lindex $netline 3]
      lappend vars(nets_list) $netname
      set vars(launch,$netname,fanout) $fanout
      set vars(launch,$netname,netcap) $netcap
# cellin
      set cellin [split_by_space [shift ilist]]
      set inst [file dirname [lindex $cellin 0]]
      lappend vars(launch_inst_list) $inst
      set vars(launch,$inst,innet) $netname
      set vars(launch,$inst,inpin)           [lindex $cellin 0]
      set vars(launch,$inst,refname)         [lindex $cellin 1]
      set vars(launch,$inst,dtrans)          [lindex $cellin 2]
      set vars(launch,$inst,in_trans)        [lindex $cellin 3]
      set vars(launch,$inst,net_derate)      [lindex $cellin 4]
      set vars(launch,$inst,delta)           [lindex $cellin 5]
      set vars(launch,$inst,net_delay)       [lindex $cellin 6]
      set vars(launch,$inst,incr_delay_in)   [lindex $cellin 8]
    }
  }
  #set ilist $vars(1)
  set ilist [concat $vars(launch_clock_path) $vars(data_path)]
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
    regsub {<-} $line {} line

    set colno [llength [split_by_space $line]]
    if {$colno == 8} {
      set cellout [split_by_space $line]]
      set inst [file dirname [lindex $cellout 0]]
      set vars(launch,$inst,cell_out_tran)   [lindex $cellout 2]
      set vars(launch,$inst,cell_derate)     [lindex $cellout 3]
      set vars(launch,$inst,cell_delay)      [lindex $cellout 4]
      set vars(launch,$inst,incr_delay_out)  [lindex $cellout 6]
      set netline [split_by_space [shift ilist]]
      set vars(launch,$inst,outnet) [lindex $netline 0]
    }
  }
  #foreach i $vars(launch_inst_list) {
  #  puts $vars(launch,$i,innet)
  #}
}
# }}}
#: ext_qor
# {{{
proc ext_qor {} {
  upvar vars vars
  read_file inputs/qor.rpt
  while {[llength $flist]} {
    set line [shift flist]
    if {[regexp {Design  WNS: (\S+)} $line whole WNS]} {
      puts $WNS
    }
    #if [regexp {Timing Path Group} $line] {
    #  puts $line
    #  puts [shift flist]
    #}
  }
}
# }}}
#: puts_info
# {{{
proc puts_info {} {
  upvar vars vars
  puts [format "%-15s : %s" startpoint $vars(startpoint)]
  puts [format "%-15s : %s" etartpoint $vars(endpoint)]
  #puts [format "%-15s : %s" common $vars(common)]
  puts [format "%-15s : %s" path_group $vars(path_group)]
  puts [format "%-15s : %s" path_type $vars(path_type)]
  puts [format "%-15s : %s" cppr $vars(cppr)]
  puts [format "%-15s : %s" uncertainty $vars(uncertainty)]
  set last_common_inst [lindex $vars(common_inst) end]
  #puts ""
  #foreach i $vars(b1_inst) {
  #  puts [format "%.2f %s" $vars(launch,$i,incr_delay_in) $i]
  #}
  #puts ""
  #set b1_start [lindex $vars(b1_inst) 0]
  #set b1_end   [lindex $vars(b1_inst) end]
  #set b1_delay [expr $vars(launch,$b1_end,incr_delay_in) - $vars(launch,$b1_start,incr_delay_in)]
  #puts $b1_delay
  #puts ""
  foreach i $vars(b2_inst) {
    puts [format "%.2f %s" $vars(capture,$i,incr_delay_in) $i]
  }
  #puts ""
  #set b2_start [lindex $vars(b2_inst) 0]
  #set b2_end   [lindex $vars(b2_inst) end]
  #set b2_delay [expr $vars(capture,$b2_end,incr_delay_in) - $vars(capture,$b2_start,incr_delay_in)]
  #puts $b2_delay
  puts "$last_common_inst"
  #set launch_clock_latency $vars(launch,$b1_end,incr_delay_in)
  #puts $launch_clock_latency
  #set capture_clock_latency [expr $vars(capture,$b2_end,incr_delay_in) - $vars(capture_clock_edge)]
  #puts $capture_clock_latency
  puts "b1_inst_count : $vars(b1_inst_count)"
  puts "b2_inst_count : $vars(b2_inst_count)"
  puts "slack: $vars(slack)"
  dqi_puts common_inst_count
}

# }}}
#: clkana_paths_file
# {{{
proc clkana_paths_file {infile} {
# pa_extract_info_list2
#
# Get path list in curs($path_num,all)
  split_by $infile
  set count $curs(size)
  set svars(path_count) $count
  set svars(infile)     $infile

  lappend alist startpoint
  lappend alist endpoint
  lappend alist endpoint_pin
  lappend alist slack
  lappend alist skew
  lappend alist path_group
  lappend alist path_type
  lappend alist cppr
  lappend alist uncertainty
  #lappend alist last_common_inst
  lappend alist b1_inst_count
  lappend alist b2_inst_count
  lappend alist b1_net_sum
  lappend alist b1_cell_sum
  lappend alist b2_net_sum
  lappend alist b2_cell_sum
  lappend alist b1_latency
  lappend alist b2_latency
  lappend alist clock_launch_latency
  lappend alist clock_capture_latency



  file mkdir pa.$infile
# Process each path
  for {set i 1} {$i <= $count} {incr i} {
    puts "Process..$i"
    file mkdir pa.$infile/p$i
    set fout_b1      [open "pa.$infile/p$i/b1.rpt" w]
    set fout_b2      [open "pa.$infile/p$i/b2.rpt" w]
# write out timing path snip for debugging
    write_list_to_file $curs($i,all) pa.$infile/p$i/raw_path.rpt
    array_reset vars
# Main timing path processing proc
    pa_extract_info_list2 $curs($i,all)

    # Branch1
    # {{{
    puts $fout_b1 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
    set b1_net_sum 0
    set b1_cell_sum 0
    foreach inst $vars(b1_inst) {
      set net_delay  [format "%.2f" $vars(launch,$inst,net_delay)]
      set cell_delay [format "%.2f" $vars(launch,$inst,cell_delay)]
      #incr b1_net_sum  $net_delay
      set b1_net_sum  [expr $b1_net_sum + $net_delay]
      #incr b1_cell_sum $cell_delay
      set b1_cell_sum [expr $b1_cell_sum + $cell_delay]
      set in_tran    [format "%.2f" $vars(launch,$inst,in_trans)]
      set netname $vars(launch,$inst,outnet)
      set netcap $vars(launch,$netname,netcap)
      puts $fout_b1 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_tran    \
                                                                $net_delay  \
                                                                $cell_delay \
                                                                $netcap     \
                                                                $vars(launch,$inst,refname) \
                                                                $vars(launch,$inst,cell_derate) \
                                                                $inst]
    }
    puts $fout_b1 "net_total : $b1_net_sum"
    puts $fout_b1 "cell_total: $b1_cell_sum"
    set vars(b1_net_sum) $b1_net_sum
    set vars(b1_cell_sum) $b1_cell_sum
    set sumb1 [expr $b1_net_sum + $b1_cell_sum]
    #set vars(b1_cell_delay_ratio) [format "%.2f" [expr double($b1_cell_sum) / $sumb1]]
    close $fout_b1
    # }}}
    # Branch2
    # {{{
    puts $fout_b2 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
    set b2_net_sum 0
    set b2_cell_sum 0
    foreach inst $vars(b2_inst) {
      set net_delay  [format "%.2f" $vars(capture,$inst,net_delay)]
      set cell_delay [format "%.2f" $vars(capture,$inst,cell_delay)]
      set in_trans   [format "%.2f" $vars(capture,$inst,in_trans)]
      set b2_net_sum [expr $b2_net_sum + $net_delay]
      set b2_cell_sum [expr $b2_cell_sum + $cell_delay]
      set netname $vars(capture,$inst,outnet)
      set netcap $vars(capture,$netname,netcap)
      puts $fout_b2 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_trans   \
                                                         $net_delay  \
                                                         $cell_delay \
                                                         $netcap \
                                                         $vars(capture,$inst,refname) \
                                                         $vars(capture,$inst,cell_derate) \
                                                         $inst]
    }
    puts $fout_b2 "net_total : $b2_net_sum"
    puts $fout_b2 "cell_total: $b2_cell_sum"
    set vars(b2_net_sum) $b2_net_sum
    set vars(b2_cell_sum) $b2_cell_sum
    set sumb2 [expr $b2_net_sum + $b2_cell_sum]
    #set vars(b2_cell_delay_ratio) [format "%.2f" [expr double($b2_cell_sum) / $sumb2]]
    close $fout_b2
    # }}}
    # data path
    # {{{
    set fout_datapath [open "pa.$infile/p$i/datapath.rpt" w]
      puts -nonewline $fout_datapath [format "%10s "  trans]
      puts -nonewline $fout_datapath [format "%10s "  net]
      puts -nonewline $fout_datapath [format "%10s "  cell]
      puts -nonewline $fout_datapath [format "%10s "  net]
      puts -nonewline $fout_datapath [format "%13s "  incr_in]
      puts -nonewline $fout_datapath [format "%19s "  refname]
      puts -nonewline $fout_datapath [format "%s "    inst]
      puts            $fout_datapath ""
      puts -nonewline $fout_datapath [format "%10s "  ""]
      puts -nonewline $fout_datapath [format "%10s "  delay]
      puts -nonewline $fout_datapath [format "%10s "  delay]
      puts -nonewline $fout_datapath [format "%10s "  cap]
      puts -nonewline $fout_datapath [format "%13s "  delay]
      puts -nonewline $fout_datapath [format "%19s "  ""]
      puts -nonewline $fout_datapath [format "%s "    ""]
      puts            $fout_datapath ""
    foreach inst $vars(data_path_inst) {
      #set netname $vars(launch,$inst,outnet)
      #set netcap $vars(launch,$netname,netcap)
      puts -nonewline $fout_datapath [format "%10.f " $vars(launch,$inst,in_trans)]
      puts -nonewline $fout_datapath [format "%10.f " $vars(launch,$inst,net_delay)]
      puts -nonewline $fout_datapath [format "%10.f " $vars(launch,$inst,cell_delay)]
      puts -nonewline $fout_datapath [format "%10.f " $netcap]
      puts -nonewline $fout_datapath [format "%13.f " $vars(launch,$inst,incr_delay_in)]
      puts -nonewline $fout_datapath [format "%s "    $vars(launch,$inst,refname)]
      puts -nonewline $fout_datapath [format "%s "    $inst]
      puts $fout_datapath ""
    }
    close $fout_datapath
    # }}}

    foreach a $alist {
      set svars(p$i,$a) $vars($a)
    }

    array_save svars "pa.$infile/svars.tcl"
  }

  set fout [open "pa.$infile/startpoints.rpt" w]
  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    puts [format "%s" $svars(p$i,startpoint)]
  }
  close $fout

  # Print index
  set fout [open "index.pa.$infile.html" w]
  dqi_html_header $fout index.pa.$infile.html
  puts $fout "<pre>"
  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    puts [format "%-4d %-5.f %-4d %-4d %-5.f %s" \
              $i \
              $svars(p$i,slack) \
              $svars(p$i,b2_inst_count) \
              $svars(p$i,b1_inst_count) \
              $svars(p$i,skew) \
              $svars(p$i,endpoint)
    ]
    puts -nonewline $fout "<a href=pa.$infile/p$i/index.html>$i</a>"
    puts $fout [format "%5.f   %-4d %-4d %-5.f %s" \
              $svars(p$i,slack) \
              $svars(p$i,b2_inst_count) \
              $svars(p$i,b1_inst_count) \
              $svars(p$i,skew) \
              $svars(p$i,endpoint)
    ]
  }
  puts $fout "</pre>"
  #puts $fout "</tbody>"
  #puts $fout "</TABLE>"
  puts $fout "</body>"
  puts $fout "</html>"
  close $fout

  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    set fout [open "pa.$infile/p$i/index.html" w]
      dqi_html_header $fout p$i.index.html
      puts $fout "<a href=\"raw_path.rpt\" type=\"text/rpt\">raw_path.rpt</a><br>"
      puts $fout "<a href=\"datapath.rpt\" type=\"text/rpt\">datapath.rpt</a><br>"
      puts $fout "<a href=\"b1.rpt\" type=\"text/rpt\">b1.rpt</a><br>"
      puts $fout "<a href=\"b2.rpt\" type=\"text/rpt\">b2.rpt</a><br>"
      puts $fout "<pre>"
      puts $fout [format "%-25s: %.f" Slack                 $svars(p$i,slack)]
      puts $fout [format "%-25s: %s"  Startpoint            $svars(p$i,startpoint)]
      puts $fout [format "%-25s: %s"  Endpoint              $svars(p$i,endpoint)]
      puts $fout [format "%-25s: %s"  Path_Group            $svars(p$i,path_group)]
      puts $fout [format "%-25s: %s"  Path_Type             $svars(p$i,path_type)]
      puts $fout [format "%-25s: %.f" CPPR                  $svars(p$i,cppr)]
      puts $fout [format "%-25s: %.f" Skew                  $svars(p$i,skew)]
      puts $fout [format "%-25s: %.f" Uncertainty           $svars(p$i,uncertainty)]
      puts $fout [format "%-25s: %.f" Clock_Launch_Latency  $svars(p$i,clock_launch_latency)]
      puts $fout [format "%-25s: %.f" Clock_Capture_Latency $svars(p$i,clock_capture_latency)]
      puts $fout [format "%-25s: %.f" B1_Latency            $svars(p$i,b1_latency)]
      puts $fout [format "%-25s: %.f" B2_Latency            $svars(p$i,b2_latency)]
      puts $fout "</pre>"
      #puts $fout "</tbody>"
      #puts $fout "</TABLE>"
      puts $fout "</body>"
      puts $fout "</html>"
    close $fout
  }
}
# }}}
#: collect_inst
# {{{
proc collect_inst {name} {
  upvar vars vars
  set inst [list]
  set ilist $vars($name)
  while {[llength $ilist]} {
    set line [shift ilist]
    set colnum [llength [split_by_space $line]]
    #puts "$colnum $line"
    if {$colnum == 10} {
      lappend inst [file dirname [lindex $line 0]]
    }
  }
  return $inst
}
# }}}
#: pa_extract_info_list
# {{{
proc pa_extract_info_list {alist} {
  upvar vars vars

  #set fin [open "fullpath.rpt" r]
  set num 0
  set common XXXXXXXX
  set startpoint XXXXXXX
  set endpoint XXXXXXX
  foreach line $alist {
    #puts "$num $line"
    lappend vars($num) $line
    if {[regexp {Last common pin: (\S+)$} $line whole matched]} { set vars(common) $matched }
    if {[regexp {Startpoint: (\S+)$} $line whole matched]}      { set vars(startpoint) $matched }
    if {[regexp {Endpoint: (\S+)$} $line whole matched]}      { set vars(endpoint) $matched }
# path_group
    if {[regexp {Path Group: (\S+)$} $line whole matched]}      { set vars(path_group) $matched }
# path_type
    if {[regexp {Path Type: (\S+)} $line whole matched]}       { set vars(path_type)  $matched }
# cppr
    if {[regexp {clock reconvergence pessimism         \s+(\S+) } $line whole matched]}  { set vars(cppr)  $matched }
# uncertainty
    if {[regexp {uncertainty\s+(\S+) } $line whole matched]}  { set vars(uncertainty)  $matched }
# slack
    if {[regexp {total derate : slack} $line]} {
    } elseif {[regexp {total derate : slack} $line]} {
    } elseif {[regexp {slack \(with derating applied\)} $line]} {
    } elseif {[regexp {slack \(with no derating\)} $line]} {
    } elseif {[regexp {slack \(.*\)\s+(\S+)} $line whole matched]} {set vars(slack) $matched}
    #if {[regexp {Startpoint:} $line]} { incr num }
    if {[regexp "Point " $line]} { incr num }
    #if {[regexp $common $line]} { incr num }
    #if {[regexp $startpoint $line]} { incr num }
    #if {[regexp $endpoint $line]} { incr num }
    if {[regexp {data arrival time} $line]} { incr num }
  }
  ext_launch
  ext_capture
  pa_inst_type2_list
}
# }}}
#: pa_inst_type2_list
# {{{
proc pa_inst_type2_list {} {
  upvar vars vars
# common_list
  set vars(data_path_inst)    [collect_inst data_path]
# launch_clock_inst
  set vars(launch_clock_inst) [collect_inst launch_clock_path]
  set vars(launch_clock_inst) [lreplace $vars(launch_clock_inst) end end]
# b1_list
  set vars(b1_inst) $vars(launch_clock_inst)
# capture_clock_inst
  set vars(capture_clock_inst) [collect_inst capture_clock_path]
  set vars(capture_clock_inst) [lreplace $vars(capture_clock_inst) end end]
# b2_list
  set vars(b2_inst) $vars(capture_clock_inst)
# common_inst
  set vars(common_inst) [list]
  set count [llength $vars(launch_clock_inst)]
  if {[llength $vars(capture_clock_inst)] < $count} {
    set count [llength $vars(capture_clock_inst)]
  }
  for {set i 1} {$i <= $count} {incr i} {
    set inst_launch [lindex $vars(launch_clock_inst) $i]
    set inst_capture [lindex $vars(capture_clock_inst) $i]
    if {$inst_launch == $inst_capture} {
      lappend vars(common_inst) $inst_launch
      set vars(b1_inst) [lreplace $vars(b1_inst) 0 0]
      set vars(b2_inst) [lreplace $vars(b2_inst) 0 0]
    } else {
      break
    }
  }
  set vars(common_inst_count) [llength $vars(common_inst)]
  set vars(b1_inst_count) [llength $vars(b1_inst)]
  set vars(b2_inst_count) [llength $vars(b2_inst)]
# capture_clock_edge
  foreach line $vars(capture_clock_path) {
    if [regexp {\s+clock\D+(\d+)} $line whole matched] {
      set vars(capture_clock_edge) $matched
      break
    }
  }
# endpoint_pin
  foreach line [lreverse $vars(data_path)] {
    if [regexp $vars(endpoint) $line whole matched] {
      set vars(endpoint_pin) [get_column $line 0]
      break
    }
  }
  # When the capture is an output pin, the endpoint_pin = endpoint
  if ![info exist vars(endpoint_pin)] {set vars(endpoint_pin) $vars(endpoint)}

  if ![info exist vars(capture,$vars(endpoint),incr_delay_in)] { set vars(capture,$vars(endpoint),incr_delay_in) 0}
  if ![info exist vars(launch,$vars(startpoint),incr_delay_in)] { set vars(launch,$vars(startpoint),incr_delay_in) 0}
  set vars(skew) [expr $vars(capture,$vars(endpoint),incr_delay_in) - $vars(launch,$vars(startpoint),incr_delay_in) + $vars(cppr)]
  set vars(clock_launch_latency)  $vars(launch,$vars(startpoint),incr_delay_in)
  set vars(clock_capture_latency) $vars(capture,$vars(endpoint),incr_delay_in)
  set vars(pod)                   [lindex $vars(common_inst) end]
  if {$vars(pod) == ""} {
    set vars(b1_latency)            0
    set vars(b2_latency)            0
  } else {
    set vars(b1_latency)            [expr $vars(clock_launch_latency) - $vars(launch,$vars(pod),incr_delay_in)]
    set vars(b2_latency)            [expr $vars(clock_capture_latency) - $vars(capture,$vars(pod),incr_delay_in)]
  }

  set vars(launch,$vars(endpoint),cell_delay) 0
}
# }}}
#: slack_dist
# {{{
proc slack_dist {infile} {
  set fin [open $infile r]
  set num 1
  while {[gets $fin line] >= 0} {
    if {[regexp {slack \(.*\)\s+(\S+)} $line whole matched]} {
      puts "$num $matched"
    }
    incr num
  }
  close $fin
}
# }}}
#: plist
# {{{
proc plist {ll} {
  foreach i $ll {
    puts $i
  }
}
# }}}
#: pcollection_list
# {{{
proc pcollection_list {ll} {
  foreach_in_collection i $ll {
    puts [get_attribute $i full_name]
  }
}
# }}}
#: split_proc
# {{{
proc split_proc {fname} {
  split_by_proc $fname
  #puts $curs(size)
  file mkdir o_split_proc
  set count $curs(size)
  for {set i 1} {$i <= $count} {incr i} {
    foreach line $curs($i,all) {
      if [regexp {^proc\s+(\S+) } $line whole matched] {
        #puts $matched
        #set curs($i,proc_name) $matched
        set ofile_name $matched
        break
      }
    }
    #puts $ofile_name
    set fout [open "o_split_proc/$ofile_name.tcl" w]
      foreach line $curs($i,all) {
        puts $fout $line
      }
    close $fout
  }
  #puts $curs(3,proc_name)
}
# }}}
#: split_by_proc
# {{{
proc split_by_proc {afile} {
  upvar curs curs
  array_reset curs
  set fin [open $afile r]
  set num 0
  set process_no 0
  while {[gets $fin line] >= 0} {
    if {[regexp {^proc} $line]} {
      incr num
    }
    if [regexp {^#: } $line] {
    } elseif [regexp {^# \{\{\{} $line] {
    } elseif [regexp {^# \}\}\}} $line] {
    } elseif [regexp {^# vim} $line] {
    } else {
      lappend curs($num,all) $line
    }
  }
  close $fin
  set curs(size) $num
  #unset curs(0,all)
}
# }}}
#: ln_hainan
# {{{
proc ln_hainan {module version path} {
  set fout [open "~/.tmp" w]
  puts $fout "ln -sf $path/log/$module/$version/run.log"
  puts $fout "ln -sf $path/rpt/$module/$version/area.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/check.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/clock_gating.rpt"
  #puts $fout "ln -sf $path/rpt/$module/$version/comp1_area.rpt"
  #puts $fout "ln -sf $path/rpt/$module/$version/comp1_vios.rpt"
  #puts $fout "ln -sf $path/rpt/$module/$version/comp2_area.rpt"
  #puts $fout "ln -sf $path/rpt/$module/$version/comp2_vios.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/constraint.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/derate.rpt"
  #puts $fout "ln -sf $path/rpt/$module/$version/ma0_top.dont_touch.tcl"
  #puts $fout "ln -sf $path/rpt/$module/$version/ma0_top.vt.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/multibit.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/printvar.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/qor.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/ref.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/timing.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/timing_max.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/violator_all.rpt"
  puts $fout "ln -sf $path/rpt/$module/$version/vios.rpt"
  
  close $fout
}
# }}}
#: ln_intel
# {{{
proc ln_intel {module stage path } {
  set fout [open "~/.tmp" w]
  puts $fout "ln -sf $path/syn/reports/$module.$stage.area.rpt         area.rpt"
  puts $fout "ln -sf $path/syn/reports/$module.$stage.vars             printvar.rpt"
  puts $fout "ln -sf $path/syn/reports/$module.$stage.clock_gating.rpt clock_gating.rpt"
  close $fout
}
# }}}
#: array_save
# {{{
proc array_save {aname ofile} {
  upvar $aname arr
  set fout [open $ofile w]
    foreach {key value} [array get arr] {
      puts $fout [format "set %-40s \"%s\"" [set aname]($key) $value]
    }
  close $fout
}
# }}}
#: array_reset
# {{{
proc array_reset {arrname} {
  upvar $arrname arr
  foreach {key value} [array get arr] {
    unset arr($key)
  }
}
# }}}
#: merge_proc
# {{{
proc merge_proc {plist ofile} {
  set fout [open $ofile w]
  foreach p $plist {
    set fin [open "dc_tcl/$p.tcl"]
      puts $fout "#: $p"
      puts $fout "# {{{"
      while {[gets $fin line] >= 0} {
        puts $fout $line
      }
      puts $fout "# }}}"
    close $fin
  }
  puts $fout "# vim:fdm=marker"
  close $fout
}
# }}}
#: shift
# {{{
proc shift {ls} {
  upvar 1 $ls LIST
  if {[llength $LIST]} {
    set ret [lindex $LIST 0]
    set LIST [lreplace $LIST 0 0]
    return $ret
  } else {
    error "Ran out of list elements."
  }
}
# }}}
#: split_by_space
# {{{
proc split_by_space {line} {
# Remove leading space
      regsub -all {^\s+} $line "" line
# Replace space with +
      regsub -all {\s+} $line "+" line
      set c [split $line +]
      return $c
}
# }}}
#: get_column
# {{{
proc get_column {line num} {
      regsub {<-} $line "" line
      regsub {\(gclock source\)} $line "" line
# Remove leading space
      regsub -all {^\s+} $line "" line
# Replace space with +
      regsub -all {\s+} $line "+" line
      set c [split $line +]
      set column_string [lindex $c $num]
}
# }}}
#: get_current_time
# {{{
proc get_current_time {} {
  return [clock format [clock seconds] -format "%Y-%m-%d %R"]
}
#proc puts_current_time {{title -}} {
  #puts "[clock format [clock seconds] -format "%Y-%m-%d %R"] $title"
#}
# }}}
#: cmd_runtime
# {{{
proc cmd_runtime {args} {
  set begintime [clock seconds]
  uplevel $args
  set endtime   [clock seconds]
  set diff [expr $endtime - $begintime]
  set elapse [clock format $diff -gmt 1 -format %H:%M:%S]
  return $elapse
}
# }}}
#: split_by
# {{{
proc split_by {afile} {
  upvar curs curs
  array_reset curs
  set fin [open $afile r]
  set num 0
  set no 0
  set process_no 0
  while {[gets $fin line] >= 0} {
    if {[regexp {Startpoint:} $line]} {
      incr num
    }
    lappend curs($num,all) $line
    incr no
    if {[expr $no%100000]} {
    } else {
      incr process_no
      puts $process_no
    }
  }
  close $fin
  set curs(size) $num
  if [info exist curs(0,all)] {
    unset curs(0,all)
  }
}
# }}}
#: write_arr
# {{{
proc write_arr {aname out {add 0}} {
  upvar 1 $aname rpt
  if {$add} {
    if [file exist $out] {
      source $out
    }
  }
  array set db [array get rpt]
  set ofile [open $out w]
    puts $ofile [list array set $aname [array get db]]
    if {$add} {
      puts "Append $aname to $out"
    } else {
      puts "Write $aname to $out"
    }
  close $ofile
}
# }}}
#: save_ses
# {{{
proc save_ses {corner outname} {
  upvar 1 $corner rpt
  set ofile [open $outname w]
    puts $ofile [list array set $corner [array get rpt]]
    puts $ofile "set myname $corner"
    puts "Save session $outname"
  close $ofile
}
# process_report_constraint_burnin
# }}}
#: plot_trend_chart
# {{{
proc plot_trend_chart {} {
  source /home/selina/york/icf/plotdb/trend.tcl
  source /home/selina/york/icf/plotdb/to_plot.tcl
  upvar run_type run_type
  upvar run_version run_version
  if {[lsearch $dates $run_version] < 0} {
    lappend dates $run_version
  }
  gen_trend_plt Trend_chart "$run_type Trend Chart" $run_type
  set fout [open .tmp w]
  foreach d $dates {
    if {[info exist trend($run_type,$d)] } {
        puts $fout "$d $trend($run_type,$d)"
    } else {
        puts $fout "$d"
    }
  }
  close $fout
  exec tcsh -fc "/tools/opensources/gnuplot-5.0.3/bin/gnuplot -c trend.plt"
}
# }}}
#: gen_trend_plt
# {{{
proc gen_trend_plt {ofile title corner} {
  set fout [open "trend.plt" w]
    puts $fout "set term png truecolor medium size 1000,500"
    puts $fout "set output \"$ofile.png\""
    #puts $fout "set xlabel \"WW\""
    #puts $fout "set ylabel \"NVP\""
    puts $fout "set title \"$title\""
    puts $fout "set grid"
   # puts $fout "set yrange \[0:110000\]"
    puts $fout "plot \".tmp\" using 0:2:xticlabels(1) with linespoints lc 3 lw 2 pt 7 ps 1 notitle, \\"
    puts $fout "     \"\"                     using 0:2:2 with labels center offset 0,1 notitle"
  close $fout
   # puts $fout "     \"\"                     using 0:3:xticlabels(1) with linespoints lc 4 lw 2 pt 7 ps 1 title \"Unique endpoints from all FUNC MAX corners\", \\"
   # puts $fout "     \"\"                     using 0:3:3 with labels center offset 0,1 notitle"
}
# }}}
#: gen_nvp_wns
# {{{
proc gen_nvp_wns {title ofile} {
  set fout [open "nvp_wns.plt" w]
    puts $fout "set title \"$title\""
    puts $fout "set term png truecolor size 1000,400 medium"
    puts $fout "set output \"$ofile.png\""
    puts $fout "set style data histogram"
    puts $fout "set style histogram clustered gap 1"
    puts $fout "set style fill transparent solid 0.4 border"
    puts $fout "set grid"
    puts $fout "set size 1,1"
    puts $fout "set ylabel \"NVP\""
    puts $fout "set y2label \"WNS\""
    puts $fout "set ytics nomirror"
    puts $fout "set y2tics"
    puts $fout "plot \".tmp\" using 2:xticlabels(1) axis x1y1  title \"NVP\", \\"
    puts $fout "     \"\"     using 0:2:2 with labels center offset 0,1 notitle, \\"
    puts $fout "     \"\"     using 3:xticlabels(1) with linespoints lc 3 lw 2 pt 7 ps 1 axis x1y2  title \"WNS\", \\"
    puts $fout "     \"\"     using 0:3:(sprintf(\"-%d\",\$3)) with labels center offset -0.5,2 axis x1y2 notitle lc 3"
   close $fout
}
# }}}
#: gen_nvp_of_each_corner
# {{{
proc gen_nvp_of_each_corner {title date} {
  set fout [open "nvp_of_each_corner.plt" w]
    puts $fout "set title \"$date NVP of each $title corners\""
    puts $fout "set term png truecolor size 1000,200 medium"
    puts $fout "set output \"$title.png\""
    puts $fout "set style data histogram"
    puts $fout "set style histogram clustered gap 1"
    puts $fout "set style fill solid 0.4 border"
    puts $fout "set grid"
    puts $fout "set ylabel \"NVP\""
    puts $fout "set xlabel \"Corners\""
    puts $fout "set yrange \[0:120000\]"
    puts $fout "plot \".tmp\" using 0:2:3:xticlabels(1)  with boxes lc variable notitle, \\"
    puts $fout "     \"\"        using 0:2:2 with labels center offset -1,1 notitle"
   close $fout
}
# }}}
#: dio_sub_hier
# {{{
proc dio_sub_hier {inst} {
  pcollection_list [sort_collection [get_cells $inst -filter "is_hierarchical == true"] full_name]
}
# }}}
#: dio_ref_name
# {{{
proc dio_ref_name {inst} {
  get_attribute [get_cells $inst] ref_name
}
# }}}
#: set:intersection
# {{{
proc set:intersection {a b} {
  #set a "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  aon_ddr1_clk_clk_dmc_1x  "
  #set b "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  JTAG_SD1_D1"
  set o {}
  foreach i $a {
    if {[lsearch $b $i] >= 0} {lappend o $i}
  }
  return $o
}
# All element in a and b once i.e. join
# }}}
#: set:union
# {{{
proc set:union {a b} {
  #set a "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  aon_ddr1_clk_clk_dmc_1x  "
  #set b "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  JTAG_SD1_D1"
  set o {}
  foreach i $a {
    if {[lsearch $b $i] < 0} {lappend o $i}
  }
  set o [concat $o $b]
  return $o
}
# }}}
#: set:restrict
# {{{
proc set:restrict {a b} {
  #set a "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  aon_ddr1_clk_clk_dmc_1x  "
  #set b "sdio1_PADOUT_EMMC_SDR_CLK cam_ISP_clk_iowr  JTAG_SD1_D1"
  set o {}
  foreach i $a {
    if {[lsearch $b $i] < 0} {lappend o $i}
  }
  return $o
}
# Both in a and b
# }}}
#: write_list_to_file
# {{{
proc write_list_to_file {ilist ofile} {
  set fout [open $ofile w]
  foreach i $ilist {
    puts $fout $i
  }
  close $fout
}
# }}}
#: pa_extract_info_list2
# {{{
proc pa_extract_info_list2 {alist} {
  upvar vars vars
  cut_in_half_by "data arrival time" $alist
  set first $half(1)
  set second $half(2)
  cut_in_half_by "------" $first
# header
  set vars(header) $half(1)
  set launch_n_data $half(2)
  foreach line $vars(header) {
      # startpoint
      if {[regexp {Startpoint: (\S+)} $line whole matched]}      { set vars(startpoint) $matched }
      # endpoint
      if {[regexp {Endpoint: (\S+)} $line whole matched]}        { set vars(endpoint)   $matched }
      # path_group
      if {[regexp {Path Group: (\S+)$} $line whole matched]}      { set vars(path_group) $matched }
      # path_type
      if {[regexp {Path Type: (\S+)} $line whole matched]}       { set vars(path_type)  $matched }
  }
  cut_in_half_by $vars(startpoint) $launch_n_data

  # launch_clock_path
  set vars(launch_clock_path) $half(1)
  # data_path
  set vars(data_path)         [concat $half(pattern) $half(2)]

  cut_in_half_by "  slack " $second
  # capture_clock_path
  set vars(capture_clock_path) $half(1)

  ext_launch
  ext_capture
  pa_inst_type2_list
}
# }}}
#: dqi_html_header
# {{{
proc dqi_html_header {fout title} {
  puts $fout ""
  puts $fout "<html>"
  puts $fout "<HEAD>"
  puts $fout "<title> $title </title>"
  puts $fout "<STYLE>"
  puts $fout "table, th, td {"
  puts $fout "  border: 1px solid black;"
  puts $fout "  border-collapse: collapse;"
  puts $fout "}"
  puts $fout "th, td {"
  puts $fout "  padding: 5px;"
  puts $fout "  text-align: left;"
  puts $fout "}"
  puts $fout "table #t01 tr:nth-child(even) {"
  puts $fout "  background-color: #eee;"
  puts $fout "}"
  puts $fout "table #t01 tr:nth-child(odd) {"
  puts $fout "  background-color: #fff;"
  puts $fout "}"
  puts $fout "table #t01 {"
  puts $fout "  color: white"
  puts $fout "  background-color: black;"
  puts $fout "}"
  puts $fout "td ul li {"
  puts $fout "    padding:0;"
  puts $fout "    margin:0;"
  puts $fout "}"
  puts $fout "</STYLE>"
  puts $fout "</HEAD>"
  puts $fout " <br>"
  puts $fout "<body>"
  #puts $fout "<TABLE width=\"100%\" border=\"1\" id=\"t01\">"
  #puts $fout "<TABLE border=\"1\" id=\"t01\">"
  #puts $fout "<tbody>"
  
}
# }}}
#: cut_in_half_by
# {{{
proc cut_in_half_by {pattern ilist} {
  set flag 0
  upvar half half
  regsub -all {\[} $pattern {\\[} pattern
  regsub -all {\]} $pattern {\\]} pattern

  array_reset half

  foreach i $ilist {
    if {$flag} {
      lappend half(2) $i
    } else {
      lappend half(1) $i
    }

    if [regexp "$pattern" $i] {
      lappend half(pattern) $i
      set flag 1
    } 
    
  }
}
# }}}
#: pa_create_index_html
# {{{
proc pa_create_index_html {} {
  upvar svars svars
  # Print index
  set fout [open "index.pa.$svars(infile).html" w]
  dqi_html_header $fout index.pa.$svars(infile).html
  puts $fout "<pre>"
  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    if [info exist svars(p$i,slack)] {
      puts -nonewline $fout "<a href=pa.$svars(infile)/p$i/index.html>$i</a> "
      puts -nonewline $fout [format "%5.f "  $svars(p$i,slack)]
      puts -nonewline $fout [format "%-4s "  $svars(p$i,path_type)]
      puts -nonewline $fout [format "%5d "   $svars(p$i,skew)]
      puts -nonewline $fout [format "%s "    $svars(p$i,endpoint_pin)]
      puts $fout ""
    } else {
      break
    }
  }
  puts $fout "</pre>"
  #puts $fout "</tbody>"
  #puts $fout "</TABLE>"
  puts $fout "</body>"
  puts $fout "</html>"
  close $fout

  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    if [info exist svars(p$i,slack)] {
      set fout [open "pa.$svars(infile)/p$i/index.html" w]
        dqi_html_header $fout p$i.index.html
        puts $fout "<a href=\"b1.rpt\" type=\"text/rpt\">b1.rpt</a><br>"
        puts $fout "<a href=\"b2.rpt\" type=\"text/rpt\">b2.rpt</a><br>"
        puts $fout "<a href=\"path.rpt\" type=\"text/rpt\">path.rpt</a><br>"
        puts $fout "<pre>"
        puts $fout [format "%-25s: %.f" Slack $svars(p$i,slack)]
        puts $fout [format "%-25s: %s" Startpoint $svars(p$i,startpoint)]
        puts $fout [format "%-25s: %s" Endpoint $svars(p$i,endpoint)]
        puts $fout [format "%-25s: %s" Path_Group $svars(p$i,path_group)]
        puts $fout [format "%-25s: %s" Path_Type $svars(p$i,path_type)]
        puts $fout [format "%-25s: %.f" CPPR $svars(p$i,cppr)]
        puts $fout [format "%-25s: %.f" Skew $svars(p$i,skew)]
        puts $fout [format "%-25s: %.f" Uncertainty $svars(p$i,uncertainty)]
        puts $fout [format "%-25s: %.f" Clock_Launch_Latency $svars(p$i,clock_launch_latency)]
        puts $fout [format "%-25s: %.f" Clock_Capture_Latency $svars(p$i,clock_capture_latency)]
        puts $fout [format "%-25s: %.f" B1_Latency $svars(p$i,b1_latency)]
        puts $fout [format "%-25s: %.f" B2_Latency $svars(p$i,b2_latency)]
        puts $fout "</pre>"
        #puts $fout "</tbody>"
        #puts $fout "</TABLE>"
        puts $fout "</body>"
        puts $fout "</html>"
      close $fout
    } else {
      break
    }
  }
}

# }}}
#: pa_get_svars_list
# {{{
proc pa_get_svars_list {type} {
  upvar svars svars
  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    lappend thelist $svars(p$i,$type)
  }
  return $thelist
}
# }}}
#: pa_plot_slack
# {{{
proc pa_plot_slack {} {
  gen_trend_plt trend.plt kk kk
}

# }}}
#: pa_sort_slack
# {{{
proc pa_sort_slack {} {
  upvar svars svars

  for {set i 1} {$i <= $svars(path_count)} { incr i} {
    if [info exist svars(p$i,slack)] {
      lappend slacks [list $svars(p$i,slack) $svars(p$i,endpoint) $i]
    } else {
      break
    }
  }

  foreach i [lsort -index 0 -integer $slacks] {
    set slack [lindex $i 0]
    set endpoint [lindex $i 1]
    set num [lindex $i 2]
    puts -nonewline [format "%5d "  $num]
    puts -nonewline [format "%5.f " $slack]
    puts -nonewline [format "%s"    $endpoint]
    #puts "$num $slack $endpoint"
    puts ""
  }
}
# }}}
#: slack_distribution
# {{{
proc slack_distribution {bin_size inlist} {
  set inlist [lsort -real $inlist]
  set smallest [lindex $inlist 0]
  set biggest  [lindex $inlist end]

  set begin [expr round($smallest/$bin_size) + 1]
  set end   [expr round($biggest/$bin_size) + 1]


  for {set i $begin} {$i <= $end} {incr i} {
    lappend binlist [expr $i * $bin_size]
  }

  #puts $binlist
  #puts $inlist

  foreach bin $binlist {
    set count 0
    foreach num $inlist {
      if {$num >= $bin} {
        if {$num == $bin} {
          incr count
        }
        break
      } else {
        incr count
      }
    }
    puts "$bin $count"
    set vars($bin) $count
  }
}

# }}}
#: split_paths
# {{{
proc split_paths {infile} {
# Get path list in curs($path_num,all)
  split_by $infile
  set count $curs(size)
  set svars(path_count) $count

  lappend alist startpoint
  lappend alist endpoint
  lappend alist endpoint_pin
  lappend alist slack
  #lappend alist skew
  #lappend alist path_group
  #lappend alist path_type
  #lappend alist cppr
  #lappend alist uncertainty
  ##lappend alist last_common_inst
  #lappend alist b1_inst_count
  #lappend alist b2_inst_count
  #lappend alist b1_net_sum
  #lappend alist b1_cell_sum
  #lappend alist b2_net_sum
  #lappend alist b2_cell_sum
  #lappend alist b1_latency
  #lappend alist b2_latency
  #lappend alist clock_launch_latency
  #lappend alist clock_capture_latency



  file mkdir pa.$infile
# Process each path
  for {set i 1} {$i <= $count} {incr i} {
    puts "Process..$i"
    file mkdir pa.$infile/p$i
    #set fout_b1      [open "pa.$infile/p$i/b1.rpt" w]
    #set fout_b2      [open "pa.$infile/p$i/b2.rpt" w]
    write_list_to_file $curs($i,all) pa.$infile/p$i/path.rpt
    #array_reset vars
    #pa_pocv_extract_info_list2 $curs($i,all)
#
#    # Branch1
#    # {{{
#    puts $fout_b1 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
#    set b1_net_sum 0
#    set b1_cell_sum 0
#    foreach inst $vars(b1_inst) {
#      set net_delay  [format "%.2f" $vars(launch,$inst,net_delay)]
#      set cell_delay [format "%.2f" $vars(launch,$inst,cell_delay)]
#      #incr b1_net_sum  $net_delay
#      set b1_net_sum  [expr $b1_net_sum + $net_delay]
#      #incr b1_cell_sum $cell_delay
#      set b1_cell_sum [expr $b1_cell_sum + $cell_delay]
#      set in_tran    [format "%.2f" $vars(launch,$inst,in_trans)]
#      set netname $vars(launch,$inst,outnet)
#      set netcap $vars(launch,$netname,netcap)
#      puts $fout_b1 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_tran    \
#                                                                $net_delay  \
#                                                                $cell_delay \
#                                                                $netcap     \
#                                                                $vars(launch,$inst,refname) \
#                                                                $vars(launch,$inst,cell_derate) \
#                                                                $inst]
#    }
#    puts $fout_b1 "net_total : $b1_net_sum"
#    puts $fout_b1 "cell_total: $b1_cell_sum"
#    set vars(b1_net_sum) $b1_net_sum
#    set vars(b1_cell_sum) $b1_cell_sum
#    set sumb1 [expr $b1_net_sum + $b1_cell_sum]
#    #set vars(b1_cell_delay_ratio) [format "%.2f" [expr double($b1_cell_sum) / $sumb1]]
#    # }}}
#    # Branch2
#    # {{{
#    puts $fout_b2 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
#    set b2_net_sum 0
#    set b2_cell_sum 0
#    foreach inst $vars(b2_inst) {
#      set net_delay  [format "%.2f" $vars(capture,$inst,net_delay)]
#      set cell_delay [format "%.2f" $vars(capture,$inst,cell_delay)]
#      set in_trans   [format "%.2f" $vars(capture,$inst,in_trans)]
#      set b2_net_sum [expr $b2_net_sum + $net_delay]
#      set b2_cell_sum [expr $b2_cell_sum + $cell_delay]
#      set netname $vars(capture,$inst,outnet)
#      set netcap $vars(capture,$netname,netcap)
#      puts $fout_b2 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_trans   \
#                                                         $net_delay  \
#                                                         $cell_delay \
#                                                         $netcap \
#                                                         $vars(capture,$inst,refname) \
#                                                         $vars(capture,$inst,cell_derate) \
#                                                         $inst]
#    }
#    puts $fout_b2 "net_total : $b2_net_sum"
#    puts $fout_b2 "cell_total: $b2_cell_sum"
#    set vars(b2_net_sum) $b2_net_sum
#    set vars(b2_cell_sum) $b2_cell_sum
#    set sumb2 [expr $b2_net_sum + $b2_cell_sum]
#    #set vars(b2_cell_delay_ratio) [format "%.2f" [expr double($b2_cell_sum) / $sumb2]]
#    # }}}

    #foreach a $alist {
      #set svars(p$i,$a) $vars($a)
    #}

    #close $fout_b1
    #close $fout_b2
  }

  #array_save svars "pa.$infile/svars.tcl"

  # Print index
  #set fout [open "index.pa.$infile.html" w]
  #dqi_html_header $fout
  #puts $fout "<pre>"
  #for {set i 1} {$i <= $svars(path_count)} {incr i } {
  #  puts [format "%-4d %-5.f %s" \
  #            $i \
  #            $svars(p$i,slack) \
  #            $svars(p$i,endpoint_pin)
  #  ]
  #  puts -nonewline $fout "<a href=pa.$infile/p$i/index.html>$i</a>"
  #  puts $fout [format "%5.f %s" \
  #            $svars(p$i,slack) \
  #            $svars(p$i,endpoint_pin)
  #  ]
  #}
  #puts $fout "</pre>"
  ##puts $fout "</tbody>"
  ##puts $fout "</TABLE>"
  #puts $fout "</body>"
  #puts $fout "</html>"
  #close $fout

  #for {set i 1} {$i <= $svars(path_count)} {incr i } {
  #  set fout [open "pa.$infile/p$i/index.html" w]
  #    dqi_html_header $fout
  #    puts $fout "<a href=\"b1.rpt\" type=\"text/rpt\">b1.rpt</a><br>"
  #    puts $fout "<a href=\"b2.rpt\" type=\"text/rpt\">b2.rpt</a><br>"
  #    puts $fout "<a href=\"path.rpt\" type=\"text/rpt\">path.rpt</a><br>"
  #    puts $fout "<pre>"
  #    puts $fout [format "%-25s: %.f" Slack $svars(p$i,slack)]
  #    puts $fout [format "%-25s: %s" Startpoint $svars(p$i,startpoint)]
  #    puts $fout [format "%-25s: %s" Endpoint $svars(p$i,endpoint)]
# #     puts $fout [format "%-25s: %s" Path_Group $svars(p$i,path_group)]
# #     puts $fout [format "%-25s: %s" Path_Type $svars(p$i,path_type)]
# #     puts $fout [format "%-25s: %.f" CPPR $svars(p$i,cppr)]
# #     puts $fout [format "%-25s: %.f" Skew $svars(p$i,skew)]
# #     puts $fout [format "%-25s: %.f" Uncertainty $svars(p$i,uncertainty)]
# #     puts $fout [format "%-25s: %.f" Clock_Launch_Latency $svars(p$i,clock_launch_latency)]
# #     puts $fout [format "%-25s: %.f" Clock_Capture_Latency $svars(p$i,clock_capture_latency)]
# #     puts $fout [format "%-25s: %.f" B1_Latency $svars(p$i,b1_latency)]
# #     puts $fout [format "%-25s: %.f" B2_Latency $svars(p$i,b2_latency)]
  #    puts $fout "</pre>"
  #    #puts $fout "</tbody>"
  #    #puts $fout "</TABLE>"
  #    puts $fout "</body>"
  #    puts $fout "</html>"
  #  close $fout
  #}


  # York
  #foreach inst $vars(data_path_inst) {
  #  puts $inst
  #  puts [format "%-10.f %30s %s" \
  #    $vars(launch,$inst,incr_delay_in) \
  #    $vars(launch,$inst,refname) \
  #    $inst \
  #  ]
  #}
  #puts [format "%-20s %s" Data_path_delay $vars(data_path_delay)]
  #puts [format "%-20s %s" Skew            $vars(skew)]
  #puts [format "%-20s %s" CPPR            $vars(cppr)]
  #puts [format "%-20s %s" uncertainty     $vars(uncertainty)]
  #puts [format "%-20s %s" Path_Group      $vars(path_group)]
  #puts [format "%-20s %s" Path_Type      $vars(path_type)]

}
# }}}
#: clkana_pocv_paths_file
# {{{
proc clkana_pocv_paths_file {infile} {
# Get path list in curs($path_num,all)
  split_by $infile
  set count $curs(size)
  set svars(path_count) $count

  lappend alist startpoint
  lappend alist endpoint
  lappend alist endpoint_pin
  lappend alist slack
  lappend alist skew
  lappend alist path_group
  lappend alist path_type
  lappend alist cppr
  lappend alist uncertainty
  #lappend alist last_common_inst
  lappend alist b1_inst_count
  lappend alist b2_inst_count
  lappend alist b1_net_sum
  lappend alist b1_cell_sum
  lappend alist b2_net_sum
  lappend alist b2_cell_sum
  lappend alist b1_latency
  lappend alist b2_latency
  lappend alist clock_launch_latency
  lappend alist clock_capture_latency



  file mkdir pa.$infile
# Process each path
  for {set i 1} {$i <= $count} {incr i} {
    puts "Process..$i"
    file mkdir pa.$infile/p$i
    set fout_b1      [open "pa.$infile/p$i/b1.rpt" w]
    set fout_b2      [open "pa.$infile/p$i/b2.rpt" w]
    write_list_to_file $curs($i,all) pa.$infile/p$i/path.rpt
    array_reset vars
    pa_pocv_extract_info_list2 $curs($i,all)

    # Branch1
    # {{{
    puts $fout_b1 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
    set b1_net_sum 0
    set b1_cell_sum 0
    foreach inst $vars(b1_inst) {
      set net_delay  [format "%.2f" $vars(launch,$inst,net_delay)]
      set cell_delay [format "%.2f" $vars(launch,$inst,cell_delay)]
      #incr b1_net_sum  $net_delay
      set b1_net_sum  [expr $b1_net_sum + $net_delay]
      #incr b1_cell_sum $cell_delay
      set b1_cell_sum [expr $b1_cell_sum + $cell_delay]
      set in_tran    [format "%.2f" $vars(launch,$inst,in_trans)]
      set netname $vars(launch,$inst,outnet)
      set netcap $vars(launch,$netname,netcap)
      puts $fout_b1 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_tran    \
                                                                $net_delay  \
                                                                $cell_delay \
                                                                $netcap     \
                                                                $vars(launch,$inst,refname) \
                                                                $vars(launch,$inst,cell_derate) \
                                                                $inst]
    }
    puts $fout_b1 "net_total : $b1_net_sum"
    puts $fout_b1 "cell_total: $b1_cell_sum"
    set vars(b1_net_sum) $b1_net_sum
    set vars(b1_cell_sum) $b1_cell_sum
    set sumb1 [expr $b1_net_sum + $b1_cell_sum]
    #set vars(b1_cell_delay_ratio) [format "%.2f" [expr double($b1_cell_sum) / $sumb1]]
    # }}}
    # Branch2
    # {{{
    puts $fout_b2 [format "%10s %10s %10s %10s" in_tran net_delay cell_delay OutNetCap]
    set b2_net_sum 0
    set b2_cell_sum 0
    foreach inst $vars(b2_inst) {
      set net_delay  [format "%.2f" $vars(capture,$inst,net_delay)]
      set cell_delay [format "%.2f" $vars(capture,$inst,cell_delay)]
      set in_trans   [format "%.2f" $vars(capture,$inst,in_trans)]
      set b2_net_sum [expr $b2_net_sum + $net_delay]
      set b2_cell_sum [expr $b2_cell_sum + $cell_delay]
      set netname $vars(capture,$inst,outnet)
      set netcap $vars(capture,$netname,netcap)
      puts $fout_b2 [format "%10.f %10.f %10.f %10.f    %s  %10.2f  %s" $in_trans   \
                                                         $net_delay  \
                                                         $cell_delay \
                                                         $netcap \
                                                         $vars(capture,$inst,refname) \
                                                         $vars(capture,$inst,cell_derate) \
                                                         $inst]
    }
    puts $fout_b2 "net_total : $b2_net_sum"
    puts $fout_b2 "cell_total: $b2_cell_sum"
    set vars(b2_net_sum) $b2_net_sum
    set vars(b2_cell_sum) $b2_cell_sum
    set sumb2 [expr $b2_net_sum + $b2_cell_sum]
    #set vars(b2_cell_delay_ratio) [format "%.2f" [expr double($b2_cell_sum) / $sumb2]]
    # }}}

    foreach a $alist {
      set svars(p$i,$a) $vars($a)
    }

    close $fout_b1
    close $fout_b2
    array_save svars "pa.$infile/svars.tcl"
  }

  array_save svars "pa.$infile/svars.tcl"

  # Print index
  set fout [open "index.pa.$infile.html" w]
  dqi_html_header $fout index.pa.$infile.html
  puts $fout "<pre>"
  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    puts [format "%-4d %-5.f %s" \
              $i \
              $svars(p$i,slack) \
              $svars(p$i,endpoint_pin)
    ]
    puts -nonewline $fout "<a href=pa.$infile/p$i/index.html>$i</a>"
    puts $fout [format "%5.f %s %s" \
              $svars(p$i,slack) \
              $svars(p$i,path_type) \
              $svars(p$i,endpoint_pin)
    ]
  }
  puts $fout "</pre>"
  #puts $fout "</tbody>"
  #puts $fout "</TABLE>"
  puts $fout "</body>"
  puts $fout "</html>"
  close $fout

  for {set i 1} {$i <= $svars(path_count)} {incr i } {
    set fout [open "pa.$infile/p$i/index.html" w]
      dqi_html_header $fout p$i.index.html
      puts $fout "<a href=\"b1.rpt\" type=\"text/rpt\">b1.rpt</a><br>"
      puts $fout "<a href=\"b2.rpt\" type=\"text/rpt\">b2.rpt</a><br>"
      puts $fout "<a href=\"path.rpt\" type=\"text/rpt\">path.rpt</a><br>"
      puts $fout "<pre>"
      puts $fout [format "%-25s: %.f" Slack $svars(p$i,slack)]
      puts $fout [format "%-25s: %s" Startpoint $svars(p$i,startpoint)]
      puts $fout [format "%-25s: %s" Endpoint $svars(p$i,endpoint)]
      puts $fout [format "%-25s: %s" Path_Group $svars(p$i,path_group)]
      puts $fout [format "%-25s: %s" Path_Type $svars(p$i,path_type)]
      puts $fout [format "%-25s: %.f" CPPR $svars(p$i,cppr)]
      puts $fout [format "%-25s: %.f" Skew $svars(p$i,skew)]
      puts $fout [format "%-25s: %.f" Uncertainty $svars(p$i,uncertainty)]
      puts $fout [format "%-25s: %.f" Clock_Launch_Latency $svars(p$i,clock_launch_latency)]
      puts $fout [format "%-25s: %.f" Clock_Capture_Latency $svars(p$i,clock_capture_latency)]
      puts $fout [format "%-25s: %.f" B1_Latency $svars(p$i,b1_latency)]
      puts $fout [format "%-25s: %.f" B2_Latency $svars(p$i,b2_latency)]
      puts $fout "</pre>"
      #puts $fout "</tbody>"
      #puts $fout "</TABLE>"
      puts $fout "</body>"
      puts $fout "</html>"
    close $fout
  }


  # York
  foreach inst $vars(launch_clock_inst) {
    puts [format "%-10.f %30s %s" \
      $vars(launch,$inst,incr_delay_in) \
      $vars(launch,$inst,refname) \
      $inst \
    ]
  }
  puts "# data"
  foreach inst $vars(data_path_inst) {
    puts [format "%-10.f %30s %s" \
      $vars(launch,$inst,incr_delay_in) \
      $vars(launch,$inst,refname) \
      $inst \
    ]
  }
  #puts [format "%-20s %s" Data_path_delay $vars(data_path_delay)]
  #puts [format "%-20s %s" Skew            $vars(skew)]
  #puts [format "%-20s %s" CPPR            $vars(cppr)]
  #puts [format "%-20s %s" uncertainty     $vars(uncertainty)]
  #puts [format "%-20s %s" Path_Group      $vars(path_group)]
  #puts [format "%-20s %s" Path_Type      $vars(path_type)]

}
# }}}
#: ext_pocv_capture
# {{{
proc ext_pocv_capture {} {
  upvar vars vars
# 2 means capture path
  set ilist $vars(capture_clock_path)
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {<-} $line {} line
    regsub {\(gclock source\)} $line {} line
    set colno [llength [split_by_space $line]]
    #puts "$colno $line"
    if {[regexp {\(net\)} $line]} {
      set netline [split_by_space $line]
      set netname [lindex $netline 0]
      set fanout  [lindex $netline 2]
      set netcap  [lindex $netline 3]
      lappend vars(nets_list) $netname
      set vars(capture,$netname,fanout) $fanout
      set vars(capture,$netname,netcap) $netcap
# cellin
      set cellin [split_by_space [shift ilist]]
      set inst [file dirname [lindex $cellin 0]]
      lappend vars(capture_inst_list) $inst
      set vars(capture,$inst,innet) $netname
# inpin
      set vars(capture,$inst,inpin) [lindex $cellin 0]
# refname
      set vars(capture,$inst,refname)       [lindex $cellin 1]
      set vars(capture,$inst,dtrans)        [lindex $cellin 2]
      set vars(capture,$inst,in_trans)      [lindex $cellin 3]
      set vars(capture,$inst,net_derate)    [lindex $cellin 4]
      set vars(capture,$inst,delta)         [lindex $cellin 5]
      set vars(capture,$inst,net_mean)      [lindex $cellin 6]
      set vars(capture,$inst,net_sensit)    [lindex $cellin 7]
      set vars(capture,$inst,net_delay)     [lindex $cellin 8]
      set vars(capture,$inst,incr_delay_in) [lindex $cellin 10]
    }
  }
# cellout line and outnet
  set ilist $vars(capture_clock_path)
  set vars(slack) 9999
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
   regsub {<-} $line {} line
    
    set colno [llength [split_by_space $line]]
    if {$colno == 10} {
      set cellout [split_by_space $line]]
      set inst [file dirname [lindex $cellout 0]]
      set vars(capture,$inst,cell_out_tran)      [lindex $cellout 2]
      set vars(capture,$inst,cell_derate)        [lindex $cellout 3]
      set vars(capture,$inst,cell_mean)          [lindex $cellout 4]
      set vars(capture,$inst,cell_sensit)        [lindex $cellout 5]
      set vars(capture,$inst,cell_delay)         [lindex $cellout 6]
      set vars(capture,$inst,incr_delay_out)     [lindex $cellout 8]
      set netline [split_by_space [shift ilist]]
      set vars(capture,$inst,outnet)             [lindex $netline 0]
    }

# cppr
    if {[regexp {clock reconvergence pessimism         \s+(\S+) } $line whole matched]}  { set vars(cppr)  $matched }
# uncertainty
    if {[regexp {uncertainty\s+(\S+) } $line whole matched]}  { set vars(uncertainty)  $matched }
# slack
    if {[regexp {slack \(.*\)\s+(\S+)} $line whole matched]} {set vars(slack) $matched}
  }
}
# }}}
#: ext_pocv_launch
# {{{
proc ext_pocv_launch {} {
  upvar vars vars
  set ilist [concat $vars(launch_clock_path) $vars(data_path)]

  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
    regsub {<-} $line {} line

    set colno [llength [split_by_space $line]]
    #puts "$colno $line"
    if {[regexp {\(net\)} $line]} {
      set netline [split_by_space $line]
      set netname [lindex $netline 0]
      set fanout  [lindex $netline 2]
      set netcap  [lindex $netline 3]
      lappend vars(nets_list) $netname
      set vars(launch,$netname,fanout) $fanout
      set vars(launch,$netname,netcap) $netcap
# cellin
      set cellin [split_by_space [shift ilist]]
      set inst [file dirname [lindex $cellin 0]]
      lappend vars(launch_inst_list) $inst
      set vars(launch,$inst,innet) $netname
# inpin
      set vars(launch,$inst,inpin) [lindex $cellin 0]
# refname
      set vars(launch,$inst,refname)         [lindex $cellin 1]
      set vars(launch,$inst,dtrans)          [lindex $cellin 2]
      set vars(launch,$inst,in_trans)        [lindex $cellin 3]
      set vars(launch,$inst,net_derate)      [lindex $cellin 4]
      set vars(launch,$inst,delta)           [lindex $cellin 5]
      set vars(launch,$inst,net_mean)        [lindex $cellin 6]
      set vars(launch,$inst,net_sensit)      [lindex $cellin 7]
      set vars(launch,$inst,net_delay)       [lindex $cellin 8]
      set vars(launch,$inst,incr_delay_in)   [lindex $cellin 10]
    }
  }
  #set ilist $vars(1)
  set ilist $vars(launch_clock_path)
  while {[llength $ilist]} {
    set line [shift ilist]
    regsub {\(gclock source\)} $line {} line
    regsub {<-} $line {} line

    set colno [llength [split_by_space $line]]
    if {$colno == 10} {
      set cellout [split_by_space $line]]
      set inst [file dirname [lindex $cellout 0]]
      set vars(launch,$inst,cell_out_tran)  [lindex $cellout 2]
      set vars(launch,$inst,cell_derate)    [lindex $cellout 3]
      set vars(launch,$inst,cell_mean)      [lindex $cellout 4]
      set vars(launch,$inst,cell_sensit)    [lindex $cellout 5]
      set vars(launch,$inst,cell_delay)     [lindex $cellout 6]
      set vars(launch,$inst,incr_delay_out) [lindex $cellout 8]
      set netline [split_by_space [shift ilist]]
      set vars(launch,$inst,outnet)         [lindex $netline 0]
    }
  }
  #foreach i $vars(launch_inst_list) {
  #  puts $vars(launch,$i,innet)
  #}
}
# }}}
#: pa_pocv_extract_info_list2
# {{{
proc pa_pocv_extract_info_list2 {alist} {
  upvar vars vars
  cut_in_half_by "data arrival time" $alist
  set first $half(1)
  set second $half(2)
  cut_in_half_by "------" $first
  set vars(header) $half(1)
  set launch_n_data $half(2)
  foreach line $vars(header) {
      # startpoint
      if {[regexp {Startpoint: (\S+)} $line whole matched]}      { set vars(startpoint) $matched }
      # endpoint
      if {[regexp {Endpoint: (\S+)} $line whole matched]}        { set vars(endpoint)   $matched }
      # path_group
      if {[regexp {Path Group: (\S+)$} $line whole matched]}      { set vars(path_group) $matched }
      # path_type
      if {[regexp {Path Type: (\S+)} $line whole matched]}       { set vars(path_type)  $matched }
  }
#puts $vars(startpoint)
  cut_in_half_by $vars(startpoint) $launch_n_data

  # launch_clock_path
  set vars(launch_clock_path) $half(1)
  # data_path
  set vars(data_path)         [concat $half(pattern) $half(2)]

  cut_in_half_by "  slack " $second
  # capture_clock_path
  set vars(capture_clock_path) $half(1)

  ext_pocv_launch
  ext_pocv_capture

#array_save vars ak
  pa_pocv_inst_type2_list
  #set vars(data_path_delay) [expr $vars(launch,$vars(endpoint),incr_delay_in) - $vars(launch,$vars(startpoint),incr_delay_in)]
}
# }}}
#: pa_pocv_inst_type2_list
# {{{
proc pa_pocv_inst_type2_list {} {
  upvar vars vars
# common_list
  set vars(data_path_inst)    [collect_inst data_path]
# launch_clock_inst
  #write_list_to_file $vars(launch_clock_path) kk.rpt
  set vars(launch_clock_inst) [collect_inst launch_clock_path]
  set vars(launch_clock_inst) [lreplace $vars(launch_clock_inst) end end]
# b1_list
  set vars(b1_inst) $vars(launch_clock_inst)
# capture_clock_inst
  set vars(capture_clock_inst) [collect_inst capture_clock_path]
  set vars(capture_clock_inst) [lreplace $vars(capture_clock_inst) end end]
# b2_list
  set vars(b2_inst) $vars(capture_clock_inst)
# capture_clock_edge
# Find common
  set vars(common_inst) [list]
  set count [llength $vars(launch_clock_inst)]
  if {[llength $vars(capture_clock_inst)] < $count} {
    set count [llength $vars(capture_clock_inst)]
  }
  for {set i 1} {$i <= $count} {incr i} {
    set inst_launch [lindex $vars(launch_clock_inst) $i]
    set inst_capture [lindex $vars(capture_clock_inst) $i]
    if {$inst_launch == $inst_capture} {
      lappend vars(common_inst) $inst_launch
      set vars(b1_inst) [lreplace $vars(b1_inst) 0 0]
      set vars(b2_inst) [lreplace $vars(b2_inst) 0 0]
    } else {
      break
    }
  }
  set vars(common_inst_count) [llength $vars(common_inst)]
  set vars(b1_inst_count) [llength $vars(b1_inst)]
  set vars(b2_inst_count) [llength $vars(b2_inst)]
# capture_clock_edge
  foreach line $vars(capture_clock_path) {
    if [regexp {\s+clock\D+(\d+)} $line whole matched] {
      set vars(capture_clock_edge) $matched
      break
    }
  }
# endpoint_pin
  foreach line [lreverse $vars(data_path)] {
    if [regexp $vars(endpoint) $line whole matched] {
      set vars(endpoint_pin) [get_column $line 0]
      break
    }
  }
  if ![info exist vars(endpoint_pin)] {set vars(endpoint_pin) $vars(endpoint)}

  set vars(skew) [expr $vars(capture,$vars(endpoint),incr_delay_in) - $vars(launch,$vars(startpoint),incr_delay_in) + $vars(cppr)]
  set vars(clock_launch_latency)  $vars(launch,$vars(startpoint),incr_delay_in)
  set vars(clock_capture_latency) $vars(capture,$vars(endpoint),incr_delay_in)
  set vars(pod)                   [lindex $vars(common_inst) end]
  if {$vars(pod) == ""} {
    set vars(b1_latency)            0
    set vars(b2_latency)            0
  } else {
    set vars(b1_latency)            [expr $vars(clock_launch_latency) - $vars(launch,$vars(pod),incr_delay_in)]
    set vars(b2_latency)            [expr $vars(clock_capture_latency) - $vars(capture,$vars(pod),incr_delay_in)]
  }
}
# }}}
#: save_total_nvp
# {{{
proc save_total_nvp {corner} {
  upvar 1 curs curs
  regexp {(\d\d\d)_} $corner whole name
  puts $name
  set fout [open "./nvp.db.tcl" w]
    puts $fout "set nvp($name) $curs(size)"
  close $fout
}
# }}}
# vim:fdm=marker
