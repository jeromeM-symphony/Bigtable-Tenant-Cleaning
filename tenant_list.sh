#!/bin/zsh
ENV=$1
SDU=$2
LINK=${ENV}-use4-sbe-$SDU-tmp/bt/count/final/$3
rm -rf ./processed
mkdir processed

WORKDIR=processed/

# First we download list from the Google Storage Bucket in source folder
#echo "Downloading files"
mkdir -p $WORKDIR/source
mkdir -p $WORKDIR/computed
gsutil -m cp -r "gs://$LINK" $WORKDIR/source/.

# Running pods example
kubectl get sbedata -n sbe-$SDU | cut -d " " -f1 | cut -d "-" -f2 > ${WORKDIR}/running.txt



# List all tenants from each CSV file from Dataflow count
for f in $(find $WORKDIR/source -name \*.csv);do; cat $f | cut -d',' -f1 >> $WORKDIR/computed/in_bt.txt;done
# Filter negative (Bug?) and sort (deduplicate) tenantID
cat $WORKDIR/computed/in_bt.txt | sort -u | grep -v '-' > $WORKDIR/computed/in_bt_sorted.txt
# Remove running Tenants
grep -v -x -f $WORKDIR/running.txt $WORKDIR/computed/in_bt_sorted.txt > $WORKDIR/computed/to_delete.txt

# Prepare ids for tenant IDs list
for t in $(cat $WORKDIR/computed/to_delete.txt); do echo "    - id: \"$t\""; done > $WORKDIR/computed/ids.txt


# cat output
cat $WORKDIR/computed/ids.txt
