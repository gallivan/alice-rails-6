#!/usr/bin/env bash

# checking return values
# 0 is okay
# not 0 is fail

echo 'rescue exception: fail'
rake play:rescue_exception
if (($? == 0)); then
  echo 'okay'
else
  echo 'fail'
fi

echo 'do not rescue exception: fail'
rake play:exception
if (($? == 0)); then
  echo 'okay'
else
  echo 'fail'
fi

echo 'normal execution: okay'
rake play:normal
if (($? == 0)); then
  echo 'okay'
else
  echo 'fail'
fi