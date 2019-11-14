#!/bin/bash

# MIT License
# 
# Copyright (c) 2019 Pierre Lefebvre
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


#######################################
# Globals variables
#######################################

# Configuration file for files associations
config_file="config.liips"

# Temporary directory to build GIF
tmp_dir="tmp__anim"

# Associative array [letter]->file
declare -A lips


#######################################
# Help function
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
usage()
{
    echo "Usage: liips <speech file>"
    exit 1
}


#######################################
# Read configuration file without
# comments
# Globals:
#   config_file
# Arguments:
#   None
# Returns:
#   configuration (without comments)
#######################################
read_config()
{
    if [[ ! -f $config_file ]]
    then
	echo "Missing configuration file: $config_file"
	exit 1
    else
	config=`cat $config_file | grep -v '^#'`
	echo $config
    fi
}


#######################################
# Create associations between letters
# and image files
# Globals:
#   lips
# Arguments:
#   None
# Returns:
#   associative array
#######################################
create_lips_table()
{
    config=$(read_config)

    echo -n "[+] Reading configuration file..."
    for e in $config
    do
	letter=`echo $e | cut -d: -f1`
	file=`echo $e | cut -d: -f2`
	lips[$letter]="$file"
    done
    echo "OK"
}


#######################################
# Retrieve letters from user input
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
get_letters()
{
    read -p "Speech: " word
    echo $word | grep -o .
}

#######################################
# Create GIF file
# Globals:
#   lips
# Arguments:
#   letter array to be pronounced
# Returns:
#   None
#######################################
create_sequence()
{
    local letters=$@
    local counter=0

    # Remove tmp dir if it already exists
    if [ -d "$tmp_dir" ]
    then
	rm -rf $tmp_dir
    fi
    
    mkdir $tmp_dir
    
    # First frame is a 'mute'
    cp ${lips['mute']} "$tmp_dir/$counter.png"
    ((counter++))

    # For each letters add the corresponding frame
    # if it exists, or the 'default' frame otherwise 
    for l in $letters
    do
	if [ -z ${lips[$l]} ]
	then
	    cp ${lips['default']} "$tmp_dir/$counter.png"
	else
	    cp ${lips[$l]} "$tmp_dir/$counter.png"
	fi
	((counter++))
    done

    # Close the speech with the 'mute' frame
    cp ${lips["mute"]} "$tmp_dir/$counter.png"    
}


#######################################
# Create GIF file
# Globals:
#   lips
# Arguments:
#   letter array to be pronounced
# Returns:
#   None
#######################################
create_gif_animation()
{
    local gif_file="anim.gif"

    cd $tmp_dir
    
    # Concatenate all PNG files into a GIF file
    echo "[+] Creating GIF sequence..."
    png_files=`ls . | sort -g`
    convert -delay 15 -loop 1 -dispose 2 $png_files $gif_file

    echo "[+] Moving final file into $gif_file"
    mv $gif_file ..
    cd ..

    echo "[+] Removing $tmp_dir directory..."
    rm -rf $tmp_dir

    echo "[+] Done"
}

# Initialise table from configuration
create_lips_table

# Read user input to get letters
l=$(get_letters)

# Create all frames (PNG files)
create_sequence $l

# Create final animation (GIF file)
create_gif_animation
