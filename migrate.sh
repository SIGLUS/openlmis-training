#!/usr/bin/env bash

[ -f ./dumpForTraining.sql ] && psql -U openlmis -d open_lmis < dumpForTraining.sql