#!/bin/sh

ROUNDS=6
ROUNDZ_START=1
ROUNDZ_END=5
#LOGDIR=/mnt/dev/logs/kmalloc-01
#LOGDIR=/mnt/dev/logs/kmem-cache-aligned-01
LOGDIR=/mnt/dev/logs/kmem-cache-unaligned-01

for j in `seq -w $ROUNDZ_START $ROUNDZ_END`; do
	echo "Starting test: nowifi-notg-nofdb"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -W -T -F -n -l $LOGDIR/nowifi-notg-nofdb/$j
		sleep 45
	done


	echo "Starting test: nowifi-nofdb"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -W -F -n -l $LOGDIR/nowifi-nofdb/$j
		sleep 45
	done

	echo "Starting test: nowifi-notg"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -W -T -n -l $LOGDIR/nowifi-notg/$j
		sleep 45
	done

	echo "Starting test: notg-nofdb"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -T -F -n -l $LOGDIR/notg-nofdb/$j
		sleep 45
	done


	echo "Starting test: nowifi"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -W -n -l $LOGDIR/nowifi/$j
		sleep 45
	done

	echo "Starting test: notg"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -T -n -l $LOGDIR/notg/$j
		sleep 45
	done

	echo "Starting test: nofdb"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -F -n -l $LOGDIR/nofdb/$j
		sleep 45
	done


	echo "Starting test: -"
	for i in `seq -w 1 $ROUNDS`; do
		./test-run.sh -n -l $LOGDIR/_/$j
		sleep 45
	done
done
