#!/usr/bin/env sh
set -e

if [ -z $DBENCH_MOUNTPOINT ]; then
    DBENCH_MOUNTPOINT=/tmp
fi

if [ -z $FIO_SIZE ]; then
    FIO_SIZE=2G
fi

if [ -z $FIO_OFFSET_INCREMENT ]; then
    FIO_OFFSET_INCREMENT=500M
fi

if [ -z $FIO_DIRECT ]; then
    FIO_DIRECT=1
fi

if [ -z $TASK_ROUND ]; then
    TASK_ROUND=5
fi

echo Working dir: $DBENCH_MOUNTPOINT
echo

READ_IOPS_VAL_SUM=0
WRITE_IOPS_VAL_SUM=0
READ_BW_VAL_SUM=0
WRITE_BW_VAL_SUM=0
READ_LATENCY_VAL_SUM=0
WRITE_LATENCY_VAL_SUM=0
READ_SEQ_VAL_SUM=0
WRITE_SEQ_VAL_SUM=0
RW_MIX_R_IOPS_SUM=0
RW_MIX_W_IOPS_SUM=0

fio_test() {
    echo
    echo ==================
    echo = Dbench Round $1 =
    echo ==================
    echo

    echo Testing Read IOPS...
    READ_IOPS=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_iops --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=64 --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=2s --runtime=15s)
    echo "$READ_IOPS"
    READ_IOPS_VAL=$(echo "$READ_IOPS"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write IOPS...
    WRITE_IOPS=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_iops --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=64 --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=2s --runtime=15s)
    echo "$WRITE_IOPS"
    WRITE_IOPS_VAL=$(echo "$WRITE_IOPS"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Read Bandwidth...
    READ_BW=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_bw --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=64 --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=2s --runtime=15s)
    echo "$READ_BW"
    READ_BW_VAL=$(echo "$READ_BW"|grep -E 'read ?:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write Bandwidth...
    WRITE_BW=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_bw --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=64 --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=2s --runtime=15s)
    echo "$WRITE_BW"
    WRITE_BW_VAL=$(echo "$WRITE_BW"|grep -E 'write:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    if [ "$DBENCH_QUICK" == "" ] || [ "$DBENCH_QUICK" == "no" ]; then
        echo Testing Read Latency...
        READ_LATENCY=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --name=read_latency --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=2s --runtime=15s)
        echo "$READ_LATENCY"
        READ_LATENCY_VAL=$(echo "$READ_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[0-9.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Write Latency...
        WRITE_LATENCY=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --name=write_latency --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=2s --runtime=15s)
        echo "$WRITE_LATENCY"
        WRITE_LATENCY_VAL=$(echo "$WRITE_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[0-9.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Read Sequential Speed...
        READ_SEQ=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_seq --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=16 --size=$FIO_SIZE --readwrite=read --time_based --ramp_time=2s --runtime=15s --thread --numjobs=4 --offset_increment=$FIO_OFFSET_INCREMENT)
        echo "$READ_SEQ"
        READ_SEQ_VAL=$(echo "$READ_SEQ"|grep -E 'READ:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Write Sequential Speed...
        WRITE_SEQ=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_seq --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=16 --size=$FIO_SIZE --readwrite=write --time_based --ramp_time=2s --runtime=15s --thread --numjobs=4 --offset_increment=$FIO_OFFSET_INCREMENT)
        echo "$WRITE_SEQ"
        WRITE_SEQ_VAL=$(echo "$WRITE_SEQ"|grep -E 'WRITE:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Read/Write Mixed...
        RW_MIX=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=rw_mix --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4k --iodepth=64 --size=$FIO_SIZE --readwrite=randrw --rwmixread=75 --time_based --ramp_time=2s --runtime=15s)
        echo "$RW_MIX"
        RW_MIX_R_IOPS=$(echo "$RW_MIX"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
        RW_MIX_W_IOPS=$(echo "$RW_MIX"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
        echo
        echo
    fi

    READ_IOPS_VAL_SUM=$(echo "$READ_IOPS_VAL_SUM + $READ_IOPS_VAL" | bc)
    WRITE_IOPS_VAL_SUM=$(echo "$WRITE_IOPS_VAL_SUM + $WRITE_IOPS_VAL" | bc)
    READ_BW_VAL_SUM=$(echo "$READ_BW_VAL_SUM + $READ_BW_VAL" | bc)
    WRITE_BW_VAL_SUM=$(echo "$WRITE_BW_VAL_SUM + $WRITE_BW_VAL" | bc)
    READ_LATENCY_VAL_SUM=$(echo "$READ_LATENCY_VAL_SUM + $READ_LATENCY_VAL" | bc)
    WRITE_LATENCY_VAL_SUM=$(echo "$WRITE_LATENCY_VAL_SUM + $WRITE_LATENCY_VAL" | bc)
    READ_SEQ_VAL_SUM=$(echo "$READ_SEQ_VAL_SUM + $READ_SEQ_VAL" | bc)
    WRITE_SEQ_VAL_SUM=$(echo "$WRITE_SEQ_VAL_SUM + $WRITE_SEQ_VAL" | bc)
    RW_MIX_R_IOPS_SUM=$(echo "$RW_MIX_R_IOPS_SUM + $RW_MIX_R_IOPS" | bc)
    RW_MIX_W_IOPS_SUM=$(echo "$RW_MIX_W_IOPS_SUM + $RW_MIX_W_IOPS" | bc)

    echo All tests complete.
    echo "Random Read/Write IOPS: $READ_IOPS_VAL/$WRITE_IOPS_VAL. BW: $READ_BW_VAL / $WRITE_BW_VAL"
    if [ -z $DBENCH_QUICK ] || [ "$DBENCH_QUICK" == "no" ]; then
        echo "Average Latency (usec) Read/Write: $READ_LATENCY_VAL/$WRITE_LATENCY_VAL"
        echo "Sequential Read/Write: $READ_SEQ_VAL / $WRITE_SEQ_VAL"
        echo "Mixed Random Read/Write IOPS: $RW_MIX_R_IOPS/$RW_MIX_W_IOPS"
    fi

    rm $DBENCH_MOUNTPOINT/fiotest
}

if [ "$1" = 'fio' ]; then
    i=1

    until [ ! $i -le $TASK_ROUND ]
    do
        fio_test $i
        i=`expr $i + 1`
    done

    READ_IOPS_VAL=$(echo "$READ_IOPS_VAL_SUM / $TASK_ROUND" | bc)
    WRITE_IOPS_VAL=$(echo "$WRITE_IOPS_VAL_SUM / $TASK_ROUND" | bc)
    READ_BW_VAL=$(echo "$READ_BW_VAL_SUM / $TASK_ROUND" | bc)
    WRITE_BW_VAL=$(echo "$WRITE_BW_VAL_SUM / $TASK_ROUND" | bc)
    READ_LATENCY_VAL=$(echo "$READ_LATENCY_VAL_SUM / $TASK_ROUND" | bc)
    WRITE_LATENCY_VAL=$(echo "$WRITE_LATENCY_VAL_SUM / $TASK_ROUND" | bc)
    READ_SEQ_VAL=$(echo "$READ_SEQ_VAL_SUM / $TASK_ROUND" | bc)
    WRITE_SEQ_VAL=$(echo "$WRITE_SEQ_VAL_SUM / $TASK_ROUND" | bc)
    RW_MIX_R_IOPS=$(echo "$RW_MIX_R_IOPS_SUM / $TASK_ROUND" | bc)
    RW_MIX_W_IOPS=$(echo "$RW_MIX_W_IOPS_SUM / $TASK_ROUND" | bc)

    echo
    echo All iterations complete.
    echo ==================
    echo = Dbench Summary =
    echo ==================
    if [ "$OUTPUT_FORMAT" = 'csv' ]; then
        # TODO : csv output format
        echo "Random Read IOPS,Random Write IOPS,Mixed Random Read IOPS,Mixed Random Write IOPS,Random Read BW,Random Write BW,Seq Read BW,Seq Write BW,Read Lantency,Write Lantency"
        echo "$READ_IOPS_VAL,$WRITE_IOPS_VAL,$RW_MIX_R_IOPS,$RW_MIX_W_IOPS,$READ_BW_VAL,$WRITE_BW_VAL,$READ_SEQ_VAL,$WRITE_SEQ_VAL,$READ_LATENCY_VAL,$WRITE_LATENCY_VAL"
    else
        echo "Random Read/Write IOPS: $READ_IOPS_VAL/$WRITE_IOPS_VAL. BW: $READ_BW_VAL / $WRITE_BW_VAL"
        if [ -z $DBENCH_QUICK ] || [ "$DBENCH_QUICK" == "no" ]; then
            echo "Average Latency (usec) Read/Write: $READ_LATENCY_VAL/$WRITE_LATENCY_VAL"
            echo "Sequential Read/Write: $READ_SEQ_VAL / $WRITE_SEQ_VAL"
            echo "Mixed Random Read/Write IOPS: $RW_MIX_R_IOPS/$RW_MIX_W_IOPS"
        fi
    fi

    exit 0
fi

exec "$@"
