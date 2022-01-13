#!/usr/bin/env bash

clear; rake clear_dynamic_data
#
if [ "$HOSTNAME" = balmoral ]; then
  clear; rake seed_positions[/home/gallivan/ruby-projects/alice/etc/data/emm/OpenPos-2016-12-30.txt]
  clear; rake seed_balances_eoy[/home/gallivan/ruby-projects/alice/etc/data/emm/Moneyline-2016-12-30.txt]
else
  clear; rake seed_positions[/home/alice/www/alice/current/etc/data/emm/OpenPos-2016-12-30.txt]
  clear; rake seed_balances_eoy[/home/alice/www/alice/current/etc/data/emm/Moneyline-2016-12-30.txt]
fi

clear; rake eoy['20170101']

rake eod:set_holiday_marks[CBT,20170102]
rake eod:set_holiday_marks[CME,20170102]

clear; rake eod:run['20170102']
clear; rake eod:run['20170103']
#clear; rake eod:run['20170104']
#clear; rake add_adjustments_20170105
#clear; rake eod:run['20170105']
#clear; rake eod:run['20170106']
#
#clear; rake eod:run['20170109']
#clear; rake add_adjustments_20170110
#clear; rake eod:run['20170110']
#clear; rake eod:run['20170111']
#clear; rake eod:run['20170112']
#clear; rake eod:run['20170113']
#
#rake eod:set_holiday_marks[CBT,20170116]
#rake eod:set_holiday_marks[CME,20170116]
#clear; rake eod:run['20170116']
#clear; rake eod:run['20170117']
#clear; rake eod:run['20170118']
#clear; rake eod:run['20170119']
#clear; rake eod:run['20170120']
#
#clear; rake eod:run['20170123']
#clear; rake eod:run['20170124']
#clear; rake eod:run['20170125']
#clear; rake eod:run['20170126']
#clear; rake eod:run['20170127']
#
#clear; rake eod:run['20170130']
#clear; rake eod:run['20170131']
#clear; rake eod:run['20170201']
#clear; rake eod:run['20170202']
#clear; rake eod:run['20170203']
