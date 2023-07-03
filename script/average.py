import os
import sys
from averageLog import average_log

# Get the input arguments from the command line
arg1 = sys.argv[1] # Input folder name

folder_path = './raw/' + arg1

for filename in os.listdir(folder_path):
    average_log(filename, arg1)