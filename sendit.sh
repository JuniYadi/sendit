#!/bin/bash
# @Description: sendit.cloud file download script
# @Author: Juni Yadi
# @URL: https://github.com/JuniYadi/sendit
# @Version: 201811270042
# @Date: 2018-11-27
# @Usage: ./sendit.sh url

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one sendit.cloud url per line"
    exit
fi

function senditdownload()
{
    prefix="$( echo -n "${url}" | cut -d'/' -f4 )"
    cookiefile="/tmp/${prefix}-cookie.tmp"
    infofile="/tmp/${prefix}-info.tmp"
    header="/tmp/${prefix}-header.tmp"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        curl -s -c "${cookiefile}" -o "${infofile}" -L "${url}"

        filename=$( cat "${infofile}" | grep 'addthis_inline_share_toolbox_l5cc' | cut -d'"' -f6 | sed -e 's/^[ \t]*//' | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed 's/ //g' | tr -d '\r')
    done

    if [ "${retry}" -ge 10 ]; then
        echo "could not download file"
        exit 1
    fi

    if [ -f "${infofile}" ]; then

        forma=$( cat "${infofile}" | grep 'name="id"' | cut -d'"' -f6)
        formb=$( cat "${infofile}" | grep 'name="rand"' | cut -d'"' -f6)

        curl -sS -D "${header}" -b "${cookiefile}" -d "op=download2&id=${forma}&rand=${formb}&referer=http%3A%2F%2Fsendit.cloud&method_free=&method_premium=" "${url}"

        getdl=$( cat "${header}" | grep "Location:" | cut -d" " -f2)

        if [ "$getdl" ]; then
            dl="${getdl}"
        else
            dl=$( cat "${header}" | grep "location:" | cut -d" " -f2)
        fi

        if [ ! "$dl" ]; then
            echo "url file not found"
            exit 1
        fi

    else
        echo "can't find info file for ${prefix}"
        exit 1
    fi

    # Set browser agent
    agent="Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

    if [ -f "$filename" ]; then
        echo "[ERROR] File  Exist : $filename"
    else
        echo "[INFO] Download File : $filename"

        # Start download file
        wget -c -O "${filename}" "${dl}" \
        -q --show-progress \
        --user-agent="${agent}"
    fi

    rm -f "${cookiefile}" 2> /dev/null
    rm -f "${infofile}" 2> /dev/null 
    rm -f "${infoverifyfile}" 2> /dev/null
    rm -f "${infodlfile}" 2> /dev/null
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep -i 'sendit.cloud' )
    do
        senditdownload "${url}"
    done
else
    url="${1}"
    senditdownload "${url}"
fi