require 'tk'
require 'RCD'

root = TkRoot.new {title 'OT Tools'}

in_entry = TkEntry.new(root)
in_var = TkVariable.new("Input/input.csv")
in_entry.textvariable(in_var)
in_entry.grid

out_entry = TkEntry.new(root)
out_var = TkVariable.new("Output")
out_entry.textvariable(out_var)
out_entry.grid("row"=>1)

inp_button = TkButton.new(root) {
  text 'Edit'
  command {`open #{in_var.value}`}
}
root.bind("Control-Key-e") {`open #{in_var.value}`}
inp_button.grid("row"=>0,"column"=>1)

calc_button = TkButton.new(root) {
  text 'RCD'
  command {rcd_main(in_var.value, out_var.value)}
}
root.bind("Control-Key-r") {rcd_main(in_var.value, out_var.value)}
calc_button.grid("row"=>1,"column"=>1)

#Tk.mainloop