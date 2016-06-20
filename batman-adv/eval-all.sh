#/bin/bash

echo "<Name>: <Average> <Median> <Standard Deviation> <Standard Error> <# of Test Rounds>"
echo

for i in logs/*; do
	echo "## $i:"
	
	for j in $i/*; do
		echo -n "  $j: "
		./eval.sh $j
	done
done
