import os

def average_log(filename, foldername):
    # Open file for reading
    input_filename = './raw/' + foldername + '/' + filename
    print("FILENAME: ", input_filename)
    file = open(input_filename, 'r', encoding='utf-8', errors='ignore')


    # Pass data from file to log array
    log = []

    for line in file:
        parseLine = line.split(",")
        parseLine[3] = parseLine[3].replace('\n', '')
        intArr = [int(string) for string in parseLine]
        log.append(intArr)
    
    # Close file
    file.close()

    # Based On Highest Index
    highestCount = 0
    currCount = 1
    jobCount = 1

    for i in range(1, len(log)):
        prevLine = log[i-1]
        line = log[i]
        if (line[0] > prevLine[0]):
            currCount += 1
        else:
            highestCount = max(highestCount, currCount)
            currCount = 1
            jobCount += 1
    
    highestCount = max(highestCount, currCount)

    # Create New Log
    newLog = [[(i+1)*1000, 0] for i in range(highestCount)]

    # Create based on highest index
    for line in log:
        idx = int(line[0]/1000) - 1
        if (idx < highestCount):
            newLog[idx][1] += line[1]
    
    # Calculate average
    # print(jobCount)
    for line in newLog:
        line[1] = line[1]/jobCount

    # print(newLog)

    # Create folder if not exists
    folder_path = './combine/' + foldername
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    # Open file for writing
    output_filename = './combine/' + foldername + '/' + filename
    file = open(output_filename, 'w')

    # Write into new file
    for line in newLog:
        # print(line)
        outputLine = ', '.join(str(x) for x in line)
        outputLine += '\n'
        file.write(outputLine)