#!/bin/bash
# Huaicheng <huaicheng@cs.uchicago.edu>
# Process raw experimental data and plot the graph in one shot

# resolve the correct absolute path
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$TOPDIR/$SOURCE"
done

TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
RAWDIR=$TOPDIR/raw
DATDIR=$TOPDIR/dat
SCRIPTDIR=$TOPDIR/script
PLOTDIR=$TOPDIR/plot
EPSDIR=$TOPDIR/eps
STATDIR=$TOPDIR/stat

# TODO: set the following params
#-------------------------------------------------------------------------------
# Set TARGET to the expriment folder (the subfolder under raw/)
TARGET="lat6-bw"

# Supported TYPE:
# lat-cdf: Latency CDF graph
# lat-time: Latency (Y-axis) vs Time (X-axis)
# iops-time: IOPS (Y-axis) vs Time (X-axis)
# bw-time: Bandwidth (Y-axis) vs Time (X-axis)
TYPE="bw-time"
#-------------------------------------------------------------------------------

# combine log
if [ "$TYPE" = "bw-time" ] || [ "$TYPE" = "iops-time" ];
then
    python $SCRIPTDIR/combine.py $TARGET
    # echo "COMBINE"
else
    python $SCRIPTDIR/average.py $TARGET
    # echo "AVERAGE"
fi

# only needed when generating dat files
$SCRIPTDIR/raw2dat.sh $TYPE $TARGET 0 1 0.0001

# generate plot file first
$SCRIPTDIR/genplot.sh $TARGET $TYPE

# get statistics
$SCRIPTDIR/getstat.sh $TARGET

# plot the graph
gnuplot $PLOTDIR/$TARGET.plot

# open the graph
pdfreader $EPSDIR/$TARGET.eps
