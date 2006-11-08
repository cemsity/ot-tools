Tables_checked = []

def fuse(x,y)
  return y if x==E
  return x if y==E
  return y if x==W
  return L
end

def fuse_rows(rows)
  rows.inject(rows[0]) do
    |r1, r2|
    r1.zip(r2).map{|x| fuse(*x)}
  end
end

# Input is the output of RCD
def fred(input)
  Fred_accumulator.clear
  comment = input.shift
  (header = input.shift)[0..3]=[]
  
  input.map {|row| row[4..-1]}
  
  accumulator=[]
  fred_run(input,accumulator)
end

def fred_run(input,accumulator,layer=[])
  fusion = fuse_rows(input)
  
  ilr = fusion.indices(W)