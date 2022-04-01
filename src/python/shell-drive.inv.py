#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
re-created on Fri Mar 25 11:20:19 2022

@author: chris
"""

# read in shell.drives, append each row as a list item

import os
drives=[]

shelldrives = open("/home/chris/Documents/shell.scratch/shell.drives", "r")

for thing in shelldrives.readlines():
 	drives.append(thing)

dirs_to_ignore = ["System Volume Information","_drive","$RECYCLE.BIN"]

for i in drives:

    drive = i.replace("\n","")
    outfile = "/home/chris/projects/dc/shell.data.rescue/drive.invs/shell."+drive
    f = open(outfile,"a")

    in_dir = "/mnt/shell/"+drive
    print("Starting to inventory "+in_dir)
   

    for (dirpath, dirnames, filenames) in os.walk(in_dir):
        for dirname in dirnames:
            if dirname in dirs_to_ignore: 
                pass
            else:
                for g in filenames:
                    f.write(str(os.path.join(dirpath,g))+'\n')
                for d in dirnames:
                    f.write(str(os.path.join(dirpath,d))+'\n')