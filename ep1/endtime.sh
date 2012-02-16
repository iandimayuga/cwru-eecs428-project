#!/bin/sh

tac ep1.tr | cut -d ' ' -f "2 8" | grep -m 1 ' 21'
tac ep1.tr | cut -d ' ' -f "2 8" | grep -m 1 ' 62'
tac ep1.tr | cut -d ' ' -f "2 8" | grep -m 1 ' 103'
