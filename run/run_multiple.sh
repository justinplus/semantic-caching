#! /bin/bash

LIB_PATH='../lib:../../lib:../../../lib'

# run isolated bss 1MB case
ruby -I $LIB_PATH run_multiple.rb isolated bss 1
