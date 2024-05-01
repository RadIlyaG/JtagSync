console show
package require registry
package require RLAutoSync

set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]
set jav [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment" CurrentVersion]
set gaSet(javaLocation) [file normalize [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment\\$jav" JavaHome]/bin]

set ::RadAppsPath c:/RadApps

set gaSet(radNet) 0
foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
  if {[string match {*192.115.243.*} $ip] || [string match {*172.18.9*} $ip] || [string match {*172.17.9*} $ip]} {
    set gaSet(radNet) 1
  }  
}

set s1 [file normalize //prod-svm1/jtag/Temporary/Team1(Ronen)/Regular]
set s1 [file normalize //prod-svm1/jtag/Temporary/sph]
set s1 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ETX-2i-10G/AT-ETX-2i-10G]

set d1 [file normalize C:/Work4/Test/1]
set sdL [list $s1 $d1]
set emailL  {{ilya_g@rad.com} {} {} }



set ret [RLAutoSync::AutoSync $sdL -jarLocation $::RadAppsPath \
        -javaLocation $gaSet(javaLocation) -emailL $emailL -putsCmd 1 -radNet $gaSet(radNet)]
    #console show
puts "ret:<$ret>"
set gsm $gMessage
set rt $ret
foreach gmess $gMessage {
  puts "$gmess"
}
update


if {$ret=="-1"} {
  if [string match *Exception* $gMessage] {
    set txt "Network connection problem"
    set res [tk_messageBox -icon error -type ok -title "AutoSync Network problem"\
      -message "Network connection problem"]
  } else {
    set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
      -message "The AutoSync process did not perform successfully.\n\n\
      Do you want to continue? "]
    if {$res=="no"} {      
      exit
    } else {
      set ret 0
    }
  }
} else {
  tk_messageBox -icon info -type ok -title "JTAG sync"\
      -message "JTAG synchronized successfully"
}
