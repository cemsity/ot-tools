require 'tk'
require 'RCD.rb'

root = TkRoot.new {title 'OT Tools'}

in_entry = TkEntry.new(root)
in_var = TkVariable.new("Input/input.csv")
in_entry.textvariable(in_var)

out_entry = TkEntry.new(root)
out_var = TkVariable.new("Output")
out_entry.textvariable(out_var)

inp_button = TkButton.new(root) {
  text 'Edit input file'
  command {`open #{in_var.value}`}
}

calc_button = TkButton.new(root) {
  text 'Run RCD'
  command {rcd_main(in_var.value, out_var.value)}
}

TkGrid.grid in_entry , inp_button
TkGrid.grid out_entry
TkGrid.grid calc_button

Tk.mainloop