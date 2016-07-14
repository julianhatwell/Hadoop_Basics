fname = 'user-buy.txt'
fh = open(fname)

last_key      = None              #initialize these variables
running_total = 0

# -----------------------------------
# Loop thru file
#  --------------------------------
for input_line in fh:
    input_line = input_line.strip()

    # --------------------------------
    # Get Next Word    # --------------------------------
    this_key, value = input_line.split('\t', 1)  #the Hadoop default is tab separates key value
                          #the split command returns a list of strings, in this case into 2 variables

    # ---------------------------------
    # Key Check part
    #    if this current key is same
    #          as the last one Consolidate
    #    otherwise  Emit
    # ---------------------------------
    value = int(float(value))

    running_total += value   # add value to running total
print(running_total)
