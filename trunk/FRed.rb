Tables_checked = []

def table_checked?(table)
  Tables_checked.map{|x| x-table}.index([])
end

def fuse(*els)
  return L if els.index(L)
  return W if els.index(W)
  return E if els.index(E)
end

def fuse_rows(rows)
  rows.inject(rows[0]) do
    |r1, r2|
    r1.zip(r2).map{|x| fuse(*x)}
  end
end

# Input is the output of RCD
def fred(input)
  comment = input.shift
  (header = input.shift).delete_indices(0..3)
  
  input.delete_indices(0..3)
  
  condition = fred_run(input,[])
end

def fred_run(input,layer,cols=(0...input[0].size).to_a)
  input=input.copy_mat
  fusion = fuse_rows(input)
  ilr = fusion.find_all(W)
  accumulator = []
  ilr.each do
    |rule|
    subtable = input.select {
      |row|
      row[rule]==E
    }
    subtable.del_cols(rule)
    layer2 = layer + cols[rule]
    
    accumulator += fred_run(subtable,layer2,cols-[rule])
  end
  
end