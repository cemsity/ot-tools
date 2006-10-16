require 'tk'
require 'RCD.rb'

root = TkRoot.new {title 'OT Tools'}
#root.bind('Key') {|ev| p ev}

in_entry = TkEntry.new(root)
in_var = TkVariable.new("Input/input.csv")
in_entry.textvariable(in_var)
in_entry.grid#("columnspan"=>6)

out_entry = TkEntry.new(root)
out_var = TkVariable.new("Output")
out_entry.textvariable(out_var)
out_entry.grid("row"=>1)#,"columnspan"=>10)

inp_button = TkButton.new(root) {
  text 'Edit'
  command {`open #{in_var.value}`}
}
#root.bind("Control-Key-e") {p 0;inp_button.event_generate("ButtonRelease")}
inp_button.grid("row"=>0,"column"=>1)

calc_button = TkButton.new(root) {
  text 'RCD'
  command {rcd_main(in_var.value, out_var.value)}
}
#root.bind("Control-Key-r") {p 1;calc_button.event_generate("ButtonRelease")}
calc_button.grid("row"=>1,"column"=>1)

Tk.mainloop