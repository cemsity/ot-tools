require 'Util'

Checked = []
# table_check([i,j,k,...])
#  returns true if Aijk... has been checked
#  returns false and registers Aijk... as checked otherwise
def table_check(l)
  res = Checked.map{|x|(x-l)|(l-x)}.index([]) ###
  Checked << l unless res
  res
end

# fuse_rows([r1, r2, ...])
#  ri is a row containing E, W, and L
#  returns the fusion of the rows
# Comps must be [E,W,L]
def fuse_rows(rows)
  rows.inject(rows[0]) do
    |r1, r2|
    r1.zip(r2).every.max
  end.to_a
end

# fred(ct, strata, n=4)
#  the first row of ct should be the rule names, and the first n columns are ignored
#  output - [success, mib_sheet, skb_sheet]
#  success is a boolean that is true iff the data were satisfiable
#  mib_sheet and skb_sheet are complete with proper labels
def fred(input, strata, n=4)
  strata = strata.flatten.every+1
  Comps[0..2] = [E,W,L]
  header = input.shift  
  input.every[0...n]=[]
  
  success = fred_run(input,[],(lbl=[]),(mib=[]),(skb=[]))
  
  Comps[0..-1] = [W,L,E]
  form = proc do
    |tbl|
    tbl.zip(lbl.map{|row| 'A'+row.map{|num| strata[num]}.join}).sort.map{|row| [row[-1]]+row[0]}
  end
  mib = form[mib]
  skb = form[skb]
  mib_sheet = [['Fus']+header[4..-1]] + mib
  skb_sheet = [['Fus']+header[4..-1]] + skb
  
  [success, mib_sheet, skb_sheet]
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
  ilc.reject!{|x| res[x]==[]}
  ftr = fuse_rows(ilc.inject([]){|ar1,i| ar1 + res[i]})
  
  #3. Check entailment
  if !fa.index(L) then
    hold_fus = false
  elsif !fa.index(W) then
    $fail = input
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