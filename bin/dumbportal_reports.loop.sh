#!/usr/bin/env bash

cd /share/dnat/rs2
cd -
# generate input lists
find /share/dnat/rs2 -maxdepth 2 -mindepth 2 -type d -printf '%P\n' | awk -F '/' '{print "/share/dnat/rs2 " $1 " " $2 " /home/msettles/dumbportal/reports"}' > dumbportal_reports_input.txt

# count the lines for the array task
lines=`wc -l dumbportal_reports_input.txt | cut -d ' ' -f 1`


while read input; do
  echo $input
  ./run_pacbio_rs2_report.sh ${input}
  exitcode=$?
  echo "./run_pacbio_rs2_report.sh $input exited with status $exitcode" >> loop_results.out
done <dumbportal_reports_input.txt

