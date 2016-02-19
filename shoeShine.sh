#!/bin/bash

#A script to clean up the /boot directory when it gets clogged with multiple
#old versions of files, ie initrd.img-4.2.0-19-generic and initrd.img-4.2.0-23-generic

path=/boot

function deleteOldVersions {
    #Load all files to be considered for deletion into an array
    declare -a ARRAY
    let count=0
    for f in $( ls -p $path | grep -v / ); do
        #Make sure f matches the sought pattern
        subLength=`expr match "$f" '[a-zA-Z.]*\-[0-9]\.[0-9]\.[0-9]\-'`

        #If it does, put it in the array
        if [ $subLength -gt 0 ] ; then
            ARRAY[$count]=$f
            ((count++))
        fi

    done

    echo Number of elements: ${#ARRAY[@]}
    #echo ${ARRAY[@]}

    ELEMENTS=${#ARRAY[@]}

    #For each element in the array, compare it to the previous element.
    #If they have the same prefix name, delete the one with the older
    #version number
    if [ $ELEMENTS -gt 1 ]; then
        
        for (( i=1; i<$ELEMENTS; i++)); do
            current=${ARRAY[${i}]}
            p=$i
            (( p-- ))
            prev=${ARRAY[${p}]}

            #Extract substring using {string:position:length}
            #where length is calculated with expr "$string" : 'substring'

            #Find length of substring that matches the pattern text-#.#.#-
            currLength=`expr match "$current" '[a-zA-Z.]*\-[0-9]\.[0-9]\.[0-9]\-'`
            prevLength=`expr match "$prev" '[a-zA-Z.]*\-[0-9]\.[0-9]\.[0-9]\-'`
            
            
            #if [ $currLength -eq $prevLength ]; then

            currPrefix=${current:0:currLength}
            prevPrefix=${prev:0:prevLength}

            if [ $currPrefix = $prevPrefix ]; then
                
                #Compare their version numbers to see which should be deleted
                currVal=${current:currLength:2}
                prevVal=${prev:prevLength:2}

                if [ $currVal -gt $prevVal ]; then
                    #echo "CurrVal $currVal greater than $prevVal"
                    filename=$path/${prev}
                    rm $filename
                    #echo `ls -a $filename`
                fi
                
            fi

        done
    fi
}

#Run it twice so all elements of vmlinuz are covered

deleteOldVersions
deleteOldVersions
