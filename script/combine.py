import os
import sys
import re
from combineLog import combine_log

# Get the input arguments from the command line
arg1 = sys.argv[1] # Input Folder Name

folder_path = './raw/' + arg1
pattern = r"\.log$"

for filename in os.listdir(folder_path):
    # print(filename)
    result = re.search(pattern, filename)
    if (result):
        combine_log(filename, arg1)