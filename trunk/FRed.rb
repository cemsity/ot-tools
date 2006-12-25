require 'Util'

Checked = []
def table_check(l)
  res = !Checked.map{|x|x-l}.index([])
  Checked << l if res
  res
end

# fuse(c1, c2, ...)
#  ci = E or W or L
#  returns the fusion of the ci's
def fuse(*els)
  els.max
end

# fuse_rows([r1, r2, ...])
#  ri is a rows of E, W, and L
#  returns the fusion of the rows
def fuse_rows(rows)
  rows.inject(rows[0]) do
    |r1, r2|
    r1.zip(r2).map{|x| fuse(*x)}
  end
end

def entails(r1, r2)
  r1.zip(r2).each do
    |x|
    return false if x[0]<x[2]
  end
  true
end

# Input is the output of RCD
def fred(input)
  header = input.shift  
  input.del_cols(*0..3)
  
  return fred_run(input)
end

def fred_run(input,layer=[])
  ret = []
  lbls = []
  n=input.size
  #0. Base step
  return [] if input==[]
  
  #1. Fuse all
  fa = fuse_rows(input)
  hold_fus = true
  
  #2. Identify lost information
  ilc = (0..n).select{|i| fa[i]==W}
  res = {}
  ilc.each do |i|
    res[i] = input.select{|r| r[i]==E}
  end
  (tr = ilc.inject([]){|ar1,i| ar1 + res[i]}).uniq!
  
  #3. Check entailment
  if fa.uniq==[W] then
    hold_fus = false
  elsif fa.uniq==[L] then
    $FAIL = input.copy_mat
    return
  elsif entails(fuse_rows(tr),fa)
    hold_fus = false
  end
  
  #4. Recurse
  if hold_fus then
    ret << fa
    lbls << layer
  end
  for k in ilc do
    l2 = layer|[k]
    next if table_check(l2)
    fnf,lbl_add = *fred_run(res[k], l2)
    return if $FAIL
    ret += fnf
    lbls += lbl_add
  end
  [ret,lbls]
end