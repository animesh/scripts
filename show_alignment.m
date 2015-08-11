function [a,b] = show_alignment(delta_file, refname, queryname)
    [a,b] = unix(['show-aligns ' delta_file ' ' refname ' ' queryname]);
end