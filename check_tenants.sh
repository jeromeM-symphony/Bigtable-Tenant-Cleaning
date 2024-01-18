#!/bin/zsh

WORKDIR=qa/sbe-s002
TLM_URL=https://tlm-api.gke-use4-001.qa.symphony.com/

echo "Start checking tenants at `date`" > $WORKDIR/processed/tlmCheck.txt

for tenant in $(cat $WORKDIR/processed/to_delete.txt); do
    STATUS=$(curl --head --location --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null $TLM_URL/v1/tenants/${tenant}/status)

    if [[ $STATUS != 405 ]]; then
        echo "ERROR : Tenant $tenant is not DEAD"
        echo "ERROR : Tenant $tenant is not DEAD" >> $WORKDIR/processed/tlmCheck.txt
    else
        echo "Tenant $tenant to delete" >> $WORKDIR/processed/tlmCheck.txt
    fi
done