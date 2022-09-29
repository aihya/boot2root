#!/bin/bash

# Rename every file with the name in the line of its content.
for f in $@
do
    new_name=$(tail -n 1 $f | cut -c3-)
    echo "Renaming $f to $new_name.c"
    mv $f "$new_name.c"
done

# Merge all files in the main.c
i=1
while [ $i -lt 751 ]
do
    sed '$d' "file$i.c" >> main.c && echo -n >> main.c
    i=$(( $i + 1))
done

# Compile the main.c
gcc main.c

# Execute './a.out': "MY PASSWORD IS: Iheartpwnage"
