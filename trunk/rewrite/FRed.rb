require 'util'

Checked = []
# table_check([i,j,k,...])
#  returns true if Aijk... has been checked
#  returns false and registers Aijk... as checked otherwise
def table_check(l)
  res = (Checked.include?(l))
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
def do_fred(input, strata, n=4)
  top = [input.shift,['Fus']+(rules=input.shift[4..-1])]
  left = input.every[0..0]
  strata = strata.flatten.every+1
  Comps[0..2] = [E,W,L]
  input.every[0...n]=[]
  
  success = fred_run(input,[],(lbl=[]),(mib=[]),(skb=[]),(ver=[top[0]]), left, rules, strata)
  lbl.map!{|row| 'A'+row.map{|num| strata[num]}.join}
  ver[1] << 'STATUS'
  
  Comps[0..-1] = [W,L,E]
  form = proc do
    |tbl|
    top + tbl.zip(lbl).sort.map{|row| [row[-1]]+row[0]}
  end
  [success, form[mib], form[skb], ver]
end

def fred_run(input, layer, lbls, mib, skb, ver, left, rules, strata)
  n=input.size
  #0. Base step
  return true if input==[]
  
  #1. Fuse all
  fa = fuse_rows(input)
  hold_fus = true
  
  #2. Identify lost information
  ilc = (0..n).select{|i| fa[i]==W}
  res = {}; lft={}
  ilc.each do |i|
    new_res = []
    new_lft = []
    input.each_index do
      |j|
      next if input[j][i] != E
      new_res << input[j]
      new_lft << left[j]
    end
    next if res.values.map{|res_o| new_res - res_o}.include?([])
    res[i] = new_res
    lft[i] = new_lft
    #res[i] = input.select{|r| r[i]==E}
  end
  ilc.reject!{|x| res[x]==[]}
  ftr = fuse_rows(ilc.inject([]){|ar1,i| ar1 + res[i]})
  
  #3. Check entailment
  fail = false
  if !fa.include?(L) then
    hold_fus = false
  elsif !fa.include?(W) then
    fail = true
  elsif ftr==fa
    hold_fus = false
  end
  
  #3.5 Verbose
  ver << [s="A#{strata.values_at(*layer)}"]+rules
  ver.insert(-1, *(left.zip(input).every.sum))
  ver << (['f'+s]+fa)
  ver[-1] << (hold_fus ? 'KEEP' : 'ENT')
  ver.insert(-1,[''],[''])
  
  #4. Recurse
  if hold_fus then
    mib << fa
    skb << fa.zip(ftr).map{|ar| ar[1]==L ? E : ar[0]}
    lbls << layer
  end
  for k in ilc do
    l2 = layer|[k]
    next if table_check(l2.sort)
    return false unless fred_run(res[k], l2, lbls, mib, skb, ver, lft[k], rules, strata)
  end
  !fail
end