#!/usr/bin/env bash
## Pacific Biosciences RSII Report Generation
## version 1.0
## Error Codes, 0-sucessfully created reports, 1-error, 2-report already exists, 3-cell exists, needed files do not
module --silent load R/local_libs

template_rpt="../markdown_reports/pacbio_RSII_report_template_v1.Rmd"
#cell_basedir="/share/dnat/rs2"
#cell_run="170606_488"
#cell_cell="E01_1"
cell_basedir="$1"
cell_run="$2"
cell_cell="$3"
#output_dir="."
output_dir="${cell_basedir}/${cell_run}/${cell_cell}"
output_basefilename="PacBioReport-${cell_run}-${cell_cell}"

if [ ! -d "${output_dir}" ]; then
  exit 1
fi

# Report already exists
if [ -f ${output_dir}/${output_basefilename}.pdf ]; then
  exit 2
fi

# Folder does not contain needed files
metadata=$(find ${output_dir} -maxdepth 1 -mindepth 1 -name '*.metadata.xml')
csv=$(find ${output_dir}/Analysis_Results -maxdepth 1 -mindepth 1 -name '*.sts.csv')
if [ ! -f $metadata | ! -f $csv ]; then
  exit 3
fi

# Folder does not contain needed files
metadata=$(find ${output_dir} -maxdepth 1 -mindepth 1 -name '*.metadata.xml')
csv=$(find ${output_dir}/Analysis_Results -maxdepth 1 -mindepth 1 -name '*.sts.csv')
if [ -f $metadata | -f $csv ]; then
   exit 3
fi

## render html report
call="library(rmarkdown); rmarkdown::render( \
        '${template_rpt}', \
        output_format='html_document', \
        output_dir='${output_dir}', \
        output_file='${output_basefilename}.html', \
        params=list(basedir='${cell_basedir}', run='${cell_run}', cell='${cell_cell}'))"
#echo ${call}
eval "Rscript -e \"${call}\"" 1> /dev/null

if [ $? -eq 0 ]
then
  echo "Successfully created html file for ${cell_run}-${cell_cell} "
else
  echo "Could not create html file for ${cell_run}-${cell_cell}"
  exit 1
fi

## render word document report
call="library(rmarkdown); rmarkdown::render( \
        '${template_rpt}', \
        output_format='word_document', \
        output_dir='${output_dir}', \
        output_file='${output_basefilename}.docx', \
        params=list(basedir='${cell_basedir}', run='${cell_run}', cell='${cell_cell}'))"
#echo ${call}
eval "Rscript -e \"${call}\"" 1> /dev/null

if [ $? -eq 0 ]
then
  echo "Successfully created word doc for ${cell_run}-${cell_cell} "
else
  echo "Could not create word doc for ${cell_run}-${cell_cell}"
  exit 1
fi

## render pdf document
call="library(rmarkdown); rmarkdown::render( \
        '${template_rpt}', \
        output_format='pdf_document', \
        output_dir='${output_dir}', \
        output_file='${output_basefilename}.pdf', \
        params=list(basedir='${cell_basedir}', run='${cell_run}', cell='${cell_cell}'))"
#echo ${call}
eval "Rscript -e \"${call}\"" 1> /dev/null

if [ $? -eq 0 ]
then
  echo "Successfully created pdf report for ${cell_run}-${cell_cell} "
else
  echo "Could not create pdf report for ${cell_run}-${cell_cell}"
  exit 1
fi

exit 0
