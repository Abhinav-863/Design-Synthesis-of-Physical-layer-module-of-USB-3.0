read_hdl /home/vlsi/V8/usb_aasd.v
read_libs /home/install/FOUNDRY/digital/90nm/dig/lib/slow.lib
elaborate usb_aasd
syn_gen
syn_map
read_sdc usb_aasd.sdc
syn_opt
gui_show
# gui_hide
check_design
check_timing_intent
report_qor > usb_aasd_qor.rep
report_timing -unconstrained > usb_aasd_timing.rep 
report_power > usb_aasd_power.rep
report_area > usb_aasd_cell.rep
report_gates > usb_aasd_gates.rep
gui_show
