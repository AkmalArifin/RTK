#!/bin/bash
# Author: Huaicheng <huaicheng@cs.uchicago.edu>
#
# Generate a template gnuplot file
#

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$TOPDIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )/.."
RAWDIR=$TOPDIR/raw
DATDIR=$TOPDIR/dat
SCRIPTDIR=$TOPDIR/script
PLOTDIR=$TOPDIR/plot
EPSDIR=$TOPDIR/eps
STATDIR=$TOPDIR/stat

################################################################################

if [[ $# != 2 ]]; then
	echo "Usage: bash genplot.sh TARGET TYPE, make sure all .dat files are under dat/TARGET/"
	exit 1
fi

GNUPLOT=$(which gnuplot)
if [[ ! -x "$GNUPLOT" ]]; then
	echo "You need gnuplot installed to generate graphs"
	exit 1
fi

[[ ! -d $PLOTDIR ]] && mkdir -p $PLOTDIR

[[ ! -d $EPSDIR ]] && mkdir -p $EPSDIR

TARGET="$1"
TYPE="$2"

XRANGE=
YRANGE=
XLABEL=
YLABEL=
YGRID=
OUTPUT=
KEY=

case $TYPE in
    "lat-cdf")
        TITLE="set title \"Latency CDF\""
        XRANGE="set xrange [0:]"
        YRANGE="set yrange [0:]"
        XLABEL="set xlabel \"Latency\""
        KEY="set key right bottom"
        #X="(\$1/1000)"      # latency us -> ms, show in millionseconds
        X=1
        Y=2
        ;;
    "lat-time")
        TITLE="set title \"Latency vs Time\""
        XRANGE="set xrange [0:]"
        YRANGE="set yrange [0:]"
        XLABEL="set xlabel \"Time (s)\\n\""
        YLABEL="set ylabel \"Latency (ms)\""
        YGRID="set grid ytics lt 2 lc rgb \"gray\" lw 1"
        KEY="set key bmargin center horizontal"
        X=1      # timestamp ms -> s, show in seconds
        Y=2      # latency us -> ms, show in millionseconds
        ;;
    "iops-time")
        TITLE="set title \"IOPS vs Time\""
        XRANGE="set xrange [0:]"
        YRANGE="set yrange [0:]"
        XLABEL="set xlabel \"Time (s)\\n\""
        YLABEL="set ylabel \" KIOPS\""
        KEY="set key bmargin center horizontal"
        X=1      # timestamp ms -> s, show in seconds
        Y=2      # IOPS shown as xx KIOPS
        ;;
        "bw-time")
        TITLE="set title \"Bandwidth vs Time\""
        XRANGE="set xrange [0:]"
        YRANGE="set yrange [0:]"
        XLABEL="set xlabel \"Time (s)\\n\""
        YLABEL="set ylabel \"Bandwidth (MB/s)\""
        KEY="set key bmargin center horizontal"
        # X=1
        # Y=2
        X="(\$1/1000)"      # timestamp ms -> s, show in seconds
        Y="(\$2*0.001024)"  # bandwidth KiB/s -> MB/s, show in megabyte per second
        ;;
    *)
        echo "Unknown Type: $TYPE, exiting .."
        exit
        ;;
esac

TERM="set term postscript eps enhanced color 20"
OUTPUT="set output \"eps/${TARGET}.eps\""
# SIZE="set size 1,.7"
SIZE="set size 2,1.5"
PLOT="plot \\"

declare -a rgbcolors=(\"gray\" \"green\" \"blue\" \"magenta\" \"orange\"
                    \"cyan\" \"yellow\" \"purple\" \"pink\" \"red\")

nbcolors=${#rgbcolors[@]}

# given dat file, get [color index] for one plot
# $1: CI_Identifier_LineTitle-TestNumber_Type.log, e.g., 5_3tos_sla20ms-1_lat.log
function getCI()
{
    local datfname=$1
    echo $(basename $datfname | gawk -F"_" '{print $1}')
}

# given raw log file name, get line title for GNUPLOT
function getLT()
{
    local rawfname=$1
    echo $(basename $rawfname | gawk -F"_" '{print $3}')
}

# given filename and linetitle, get the plot command
# $1: dat file name
# $2: line title, from getLT()
# $3: color index, [0..nbcolors]
# $4: total # of dat files, make sure color red is used for the last file
function plotone()
{
    local datfname=$1
    local LT=$2
    local CI=$3
    local nbdatfiles=$4
    local MAXCI=$(($nbdatfiles - 1))
    if [[ $CI == $MAXCI ]]; then
        CI=$(($nbcolors-1))                 # use red
    elif [[ $CI -gt $nbcolors ]]; then      # temporary hack
        CI=$(($CI % $nbcolors + 1))
    fi
    echo "'$datfname' u $X:$Y t \"$LT\" w l lc rgb ${rgbcolors[$CI]} lw 5, \\"
}

# the main function to generate gnuplot file
function genplot()
{
    # we are picky about colors, so be careful about the ordering
    if [[ -e $PLOTDIR/${TARGET}.plot ]]; then
        echo "Found existing plot file: ${TARGET}.plot"
        #exit
    fi

    nbfiles=$(ls -l dat/$TARGET/*.dat | wc -l)

    # write plot file
    {
        echo "${TERM}"
        echo "${TITLE}"
        echo "${OUTPUT}"
        echo "${SIZE}"
        echo "${KEY}"
        echo "${XRANGE}"
        echo "${YRANGE}"
        echo "${XLABEL}"
        echo "${YLABEL}"
        echo "${YGRID}"

        # settings should come before this line
        echo "${PLOT}"

        cnt=0
        for i in dat/$TARGET/*.dat; do
            LT=$(getLT $i)
            plotone $i $LT $cnt $nbfiles
            ((cnt += 1))
        done
    } > $PLOTDIR/${TARGET}.plot
}

genplot

echo "==== genplot done ===="

