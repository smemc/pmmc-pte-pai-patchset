#!/bin/bash

generate_patches() {
    DATA_DEST=$1
    PATCHES_DEST=$2/patches
    rm -rf $PATCHES_DEST
    mkdir $PATCHES_DEST

    echo "Generating patches for filename case/accents fix. This may take a long time."
    sleep 1

    count=0
    read_count=0

    for file_htm in $DATA_DEST/atividades/*/*.htm
    do
        read_count=$(( read_count + 1 ))
        SED_ARGS=""
        file_htm_strip=${file_htm#$DATA_DEST/}
        cp $file_htm ${file_htm}.old

        for file in $(find $(dirname $file_htm) -type f | grep -v $(basename $file_htm)) $(find $(dirname $file_htm)/../../scripts -type f)
        do
            lc_path=$(echo $file | sed -e "s@$(dirname $file_htm)/@@g")
            SED_ARGS="$SED_ARGS -e s@$lc_path@$lc_path@gi -e s@$(basename $lc_path)@$(basename $lc_path)@gi"
        done

        patch_case_file="$PATCHES_DEST/$(basename ${file_htm})_01_fix_case.patch"
        patch_accents_file="$PATCHES_DEST/$(basename ${file_htm})_02_fix_accents.patch"
        
        if [ "x$SED_ARGS" != "x" ]
        then
            sed $SED_ARGS $file_htm > ${file_htm}.new
        else
            cp $file_htm ${file_htm}.new
        fi

        sed -f accents.sed ${file_htm}.new > ${file_htm}.new2
 
        echo -n "$file_htm:"
                
        if ! diff $file_htm ${file_htm}.new > /dev/null
        then
            (cd $DATA_DEST && diff -u ${file_htm_strip} ${file_htm_strip}.new > $patch_case_file)
            echo -ne "\tcase\t"
            count=$(( count + 1 ))
        else
            echo -ne "\t\t"
        fi
        
        if ! diff ${file_htm}.new ${file_htm}.new2 > /dev/null
        then
            cp ${file_htm}.new $file_htm
            cp ${file_htm}.new2 ${file_htm}.new
            (cd $DATA_DEST && diff -u ${file_htm_strip} ${file_htm_strip}.new > $patch_accents_file)
            echo "accents"
            count=$(( count + 1 ))
        else
            echo ""
        fi

        mv ${file_htm}.old $file_htm
        rm -f ${file_htm}.*
    done

    for file_html in $DATA_DEST/index.html $DATA_DEST/ajuda.html $DATA_DEST/pai.html
    do
        read_count=$(( read_count + 1 ))
        SED_ARGS=""
        file_html_strip=${file_html#$DATA_DEST/}
        cp $file_html ${file_html}.old

        for bfile in $(find $DATA_DEST/templates -type f) $(find $DATA_DEST/scripts -type f) $(find $DATA_DEST/xml -type f)
        do
            SED_ARGS="$SED_ARGS -e s@$bfile@$bfile@gi -e s@$(basename $bfile)@$(basename $bfile)@gi"
        done

        patch_case_file="$PATCHES_DEST/$(basename ${file_html})_01_fix_case.patch"
        patch_accents_file="$PATCHES_DEST/$(basename ${file_html})_02_fix_accents.patch"

        if [ "x$SED_ARGS" != "x" ]
        then
            sed $SED_ARGS $file_html > ${file_html}.new
        else
            cp $file_html ${file_html}.new
        fi

        sed -f accents.sed ${file_html}.new > ${file_html}.new2
        
        echo -n "$file_html:"
        
        if ! diff $file_html ${file_html}.new > /dev/null
        then
            (cd $DATA_DEST && diff -u ${file_html_strip} ${file_html_strip}.new > $patch_case_file)
            echo -ne "\tcase\t"
            count=$(( count + 1 ))
        else
            echo -ne "\t\t"
        fi
        
        if ! diff ${file_html}.new ${file_html}.new2 > /dev/null
        then
            cp ${file_html}.new $file_html
            cp ${file_html}.new2 ${file_html}.new
            (cd $DATA_DEST && diff -u ${file_html_strip} ${file_html_strip}.new > $patch_accents_file)
            echo "accents"
            count=$(( count + 1 ))
        else
            echo ""
        fi
        
        mv ${file_html}.old $file_html
        rm -f ${file_html}.*
    done
    
    echo "TOTAL: $read_count files read; $count patches generated."
}

generate_patches $1 $2
