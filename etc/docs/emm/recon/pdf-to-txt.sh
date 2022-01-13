#!/usr/bin/env bash
for pdffile in ./ledger-balance-summary-2017042[45678].pdf; do

  echo ${pdffile}
  txtfile=${pdffile%.pdf}.txt
  echo ${txtfile}
  pdf2txt ${pdffile} > ${txtfile}
done