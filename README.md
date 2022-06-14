# Ungroup designators in a BOM

Example use:

```
./ungroup-all.pl BLN-0002C-01A_BOM-Customer.csv > BLN-0002C-01A_BOM-Customer-ungrouped.csv
./ungroup-first.pl balenaFin_v1_x_x.csv > balenaFin_v1_x_x-ungrouped.csv
./group-references.pl BLN-0002C-03A_BOM-Customer.csv | ./ungroup-first.pl - > BLN-0002C-03A_BOM-Customer-ungrouped.csv
```
