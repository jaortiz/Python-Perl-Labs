#!/bin/sh

grep "F$" | cut -d'|' -f2 | sort | uniq
