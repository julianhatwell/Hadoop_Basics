# Use the file name mbox-short.txt as the file name
fname = 'buy-clicks.csv'
fh = open(fname)
foutname = 'user-buy.txt'
fout = open(foutname, 'w')
header = 0
for line in fh:
    if header == 0:
        header = 1
        continue
    line = line.strip()  #strip is a method, ie function, associated
                         #  with string variable, it will strip
                         #   the carriage return (by default)
    buys = line.split(',')  #   split line at ,
                         #   and return a list of keys

    key = buys[4]
    value = int(float(buys[6]))

    fout.write(str(key + '\t' + str(value) + '\n'))
fout.close()
