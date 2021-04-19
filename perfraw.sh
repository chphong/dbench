#!/usr/bin/env sh
set -e

if [ -z $DBENCH_MOUNTPOINT ]; then
  DBENCH_MOUNTPOINT=/fiovol
fi

if [ -z $FIO_SIZE ]; then
  FIO_SIZE=250G
fi

if [ -z $FIO_OFFSET_INCREMENT ]; then
  FIO_OFFSET_INCREMENT=500M
fi

if [ -z $FIO_DIRECT ]; then
  FIO_DIRECT=1
fi

if [ -z $FIO_SYNC ]; then
  FIO_SYNC=0
fi

echo Working dir: $DBENCH_MOUNTPOINT
echo

echo Testing Read IOPS...
READ_IOPS=$(fio --output-format=json --name=read_iops --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
echo "$READ_IOPS"
echo

echo Testing Write IOPS...
WRITE_IOPS=$(fio --output-format=json --name=write_iops --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
echo "$WRITE_IOPS"
echo

echo Testing Read Bandwidth...
READ_BW=$(fio --output-format=json --name=read_bw --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
echo "$READ_BW"
echo

echo Testing Write Bandwidth...
WRITE_BW=$(fio --output-format=json --name=write_bw --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
echo "$WRITE_BW"
echo

if [ "$DBENCH_QUICK" == "" ] || [ "$DBENCH_QUICK" == "no" ]; then
  echo Testing Read Latency...
  READ_LATENCY=$(fio --output-format=json --name=read_latency --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
  echo "$READ_LATENCY"
  echo

  echo Testing Write Latency...
  WRITE_LATENCY=$(fio --output-format=json --name=write_latency --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
  echo "$WRITE_LATENCY"
  echo

  echo Testing Read Sequential Speed...
  READ_SEQ=$(fio --output-format=json --name=read_seq --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=read --time_based --ramp_time=10s --runtime=30s --thread --numjobs=4 --offset_increment=$FIO_OFFSET_INCREMENT)
  echo "$READ_SEQ"
  echo

  echo Testing Write Sequential Speed...
  WRITE_SEQ=$(fio --output-format=json --name=write_seq --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=write --time_based --ramp_time=10s --runtime=30s --thread --numjobs=4 --offset_increment=$FIO_OFFSET_INCREMENT)
  echo "$WRITE_SEQ"
  echo

  echo Testing Read/Write Mixed...
  RW_MIX=$(fio --output-format=json --name=rw_mix --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4k --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randrw --rwmixread=75 --time_based --ramp_time=10s --runtime=30s)
  echo "$RW_MIX"
  echo
fi

echo All tests complete.

rm $DBENCH_MOUNTPOINT/fiotest
exit 0
