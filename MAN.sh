#!/bin/bash

menu() {
    echo "What do you want to do?"
    echo "1) Remove duplicates"
    echo "2) Remove all blank lines"
    echo "3) Remove words less than 8 characters"
    echo "4) Merge two wordlists"
    echo "5) Count lines in a file"
    echo "q) Quit"
}

remove_duplicates() {
    read -p "Enter path to file: " f_path
    awk '!(count[$0]++)' "$f_path" > "${f_path}-new"
    if [ $? -eq 0 ]; then
        echo "Duplicates have been removed, view new file at ${f_path}-new"
    else
        echo "Error: Failed to remove duplicates."
    fi
}

remove_blank_lines() {
    read -p "Enter path to file: " f_path
    egrep -v "^[[:space:]]*$" "$f_path" > "${f_path}-new"
    if [ $? -eq 0 ]; then
        echo "File has been removed of all blank lines at ${f_path}-new"
    else
        echo "Error: Failed to remove blank lines."
    fi
}

remove_short_words() {
    read -p "Enter path to file: " f_path
    awk '{ for (i=1; i<=NF; i++) if (length($i) >= 8) printf "%s ", $i; print "" }' "$f_path" > "${f_path}-new"
    if [ $? -eq 0 ]; then
        echo "Words less than 8 characters have been removed, view new file at ${f_path}-new"
    else
        echo "Error: Failed to remove short words."
    fi
}

merge_wordlists() {
    read -p "Enter path to first file: " f_path1
    read -p "Enter path to second file: " f_path2
    cat "$f_path1" "$f_path2" > "${f_path1}-merged"
    if [ $? -eq 0 ]; then
        echo "Wordlists have been merged, view new file at ${f_path1}-merged"
    else
        echo "Error: Failed to merge wordlists."
    fi
}

count_lines() {
    read -p "Enter path to file: " f_path
    if [ -f "$f_path" ]; then
        line_count=$(wc -l < "$f_path")
        echo "The file contains $line_count lines."
    else
        echo "Error: File not found or inaccessible."
    fi
}

while true; do
    menu
    read -p "> " choice
    case $choice in
        1) remove_duplicates ;;
        2) remove_blank_lines ;;
        3) remove_short_words ;;
        4) merge_wordlists ;;
        5) count_lines ;;
        q) echo "Exiting..."; exit ;;
        *) echo "Invalid option. Please choose again." ;;
    esac
done
