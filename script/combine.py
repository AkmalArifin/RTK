import os
import sys
from combineLog import combine_log

# Get the input arguments from the command line
arg1 = sys.argv[1] # Input Folder Name

folder_path = './raw/' + arg1

for filename in os.listdir(folder_path):
    combine_log(filename, arg1)