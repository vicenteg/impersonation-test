#!/bin/bash 

function assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99


  if [ ! $1 ] 
  then
    echo "Assertion failed:  \"$1\""
    return $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
} 
