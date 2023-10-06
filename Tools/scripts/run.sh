#!/bin/bash

# Copyright 2023 Arm Limited and/or its affiliates
# <open-source-office@arm.com>
# SPDX-License-Identifier: MIT

HERE="$(dirname "$0")"
ROOT="$(realpath $HERE/..)"
EXAMPLE=""
BUILD_PATH="build"
TARGET="corstone300"
FVP_BIN=""

function show_usage {
    cat <<EOF
Usage: $0 [options] example

Run an example.

Options:
    -h,--help   Show this help
    -p,--path   Build path
    -t,--target Target to run

Examples:
    blinky, aws-iot-example
EOF
}

SHORT=t:,h
LONG=target:,help
OPTS=$(getopt -n run --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

while :
do
  case "$1" in
    -h | --help )
      show_usage
      exit 0
      ;;
    -t | --target )
      TARGET=$2
      shift 2
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      show_usage
      exit 2
      ;;
  esac
done

case "$TARGET" in
    corstone300 )
      FVP_BIN="VHT_Corstone_SSE-300_Ethos-U55"
      ;;
    corstone310 )
      FVP_BIN="VHT_Corstone_SSE-310"
      ;;
    *)
      echo "Invalid target <Corstone300|corstone310>"
      show_usage
      exit 2
      ;;
esac

case "$1" in
    blinky)
        EXAMPLE="$1"
        MERGED_IMAGE_PATH="$BUILD_PATH/Projects/$EXAMPLE/blinky_merged.elf"
        ;;
    aws-iot-example)
        EXAMPLE="$1"
        MERGED_IMAGE_PATH="$BUILD_PATH/Projects/$EXAMPLE/aws-iot-example_merged.elf"
        ;;
    *)
        echo "Usage: $0 <blinky,aws-iot-example>" >&2
        exit 1
        ;;
esac

OPTIONS="-C mps3_board.visualisation.disable-visualisation=1 -C mps3_board.smsc_91c111.enabled=1 -C mps3_board.hostbridge.userNetworking=1 -C mps3_board.telnetterminal0.start_telnet=0 -C mps3_board.uart0.out_file="-"  -C mps3_board.uart0.unbuffered_output=1 --stat  -C mps3_board.DISABLE_GATING=1"

# Start the FVP
$FVP_BIN $OPTIONS -a $MERGED_IMAGE_PATH
