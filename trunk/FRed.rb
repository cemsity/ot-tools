require 'Util'

Checked = []
def table_check(l)
  res = Checked.map{|x|(x-l)|(l-x)}.index([])
  Checked << l unless res
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
  end.to_a
end

def entails(r1, r2)
  return false if r1.size<r2.size
  r1.zip(r2).each do
    |x|
    return false if x[0]<x[1]
  end
  true
end

# Input is the output of RCD
# Output is [success, lbls, mib, skb]
def fred(input)
  Comps[0..2] = [E,W,L]
  header = input.shift  
  input.del_cols(*0..3)
  
  arg = [[],[],[]]
  [fred_run(input,[],*arg),*arg]
end

def fred_run(input, layer, lbls, mib, skb)
  n=input.size
  #0. Base step
  return true if input==[]
  
  #1. Fuse all
  fa = fuse_rows(input)
  hold_fus = true
  
  #2. Identify lost information
  ilc = (0..n).select{|i| fa[i]==W}
  res = {}
  ilc.each do |i|
    res[i] = input.select{|r| r[i]==E}
  end
  ftr = fuse_rows(ilc.inject([]){|ar1,i| ar1 + res[i]})
  ilc.reject!{|x| res[x]==[]}
  
  #3. Check entailment
  if fa.uniq==[W] then
    hold_fus = false
  elsif fa.uniq==[L] then
    $fail = input.copy_mat
    return false
  elsif ftr==fa
    hold_fus = false
  end
  
  #4. Recurse
  if hold_fus then
    mib << fa
    skb << fa.zip(ftr).map{|ar| ar[1]==L ? E : ar[0]}
    lbls << layer
  end
  for k in ilc do
    l2 = layer|[k]
    next if table_check(l2)
    return false unless fred_run(res[k], l2, lbls, mib, skb)
  end
  true
end