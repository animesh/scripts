#!/bin/sh
tex testfont < testfont.input
rm testfont.log
rm bthhsm.tfm
rm bthhsm.600pk
rm /home/corff/mls/mls-font/fonts/source/mls/tfm/bithe/*
rm /usr/local/tex.local/fonts/tfm/mls/bithe/*
rm /usr/local/tex.local/fonts/pk/ljfive/mls/bithe/*
xdvi testfont
rm testfont.dvi
