#!/bin/zsh

LINK=qa-use4-sbe-s002-tmp/bt/count/final/1705591002
WORKDIR=qa/sbe-s002
SDU=$(echo $WORKDIR | cut -d'/' -f2)

# First we download list from the Google Storage Bucket in source folder
#echo "Downloading files"
#mkdir -p $WORKDIR/source
#gsutil -m cp -r "gs://$LINK" $WORKDIR/source/.

# Running pods example
# WORKDIR=qa/sbe-s002 && SDU=$(echo $WORKDIR | cut -d'/' -f2)
# kubectl get sbedata -n sbe-s001 | cut -d " " -f1 | cut -d "-" -f2 > qa/sbe-s002/running.txt


rm -rf ./$WORKDIR/processed
mkdir $WORKDIR/processed

# List all tenants from each CSV file from Dataflow count
for f in $(find $WORKDIR/source -name \*.csv);do; cat $f | cut -d',' -f1 >> $WORKDIR/processed/created.txt;done
# Filter negative (Bug?) and sort (deduplicate) tenantID
cat $WORKDIR/processed/created.txt | sort -u | grep -v '-' > $WORKDIR/processed/sorted.txt
# Remove running Tenants
grep -v -x -f $WORKDIR/running.txt $WORKDIR/processed/sorted.txt > $WORKDIR/processed/with_tlm.txt
# Remove TLM reserved Tenants
grep -v -x -f $WORKDIR/../tlm_tenants.csv $WORKDIR/processed/with_tlm.txt > $WORKDIR/processed/to_delete.txt

# Prepare ids for tenant IDs list
for t in $(cat $WORKDIR/processed/to_delete.txt); do echo "    - id: \"$t\""; done > $WORKDIR/processed/ids.txt