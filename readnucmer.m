function [a header] = readnucmer(nucmer_files) 
%READNUCMER Reads in a nucmer coords file
%
% INPUT: Location of the coords file
%
% OUTPUT: [data header]

nr_of_fnames = length(nucmer_files);

    
% Read filtered nucmer alignment files
a = [];
for i = 1:nr_of_fnames
    b = load_nucmer_filtered(nucmer_files{i});
    a = [a;b];
    
end

header = {'S1';'E1';'S2';'E2';'LEN 1';'LEN 2';'% IDY';'LEN R';'LEN Q';...
          'COV R';'COV Q';'Rname';'Qname'};


    function dat = load_nucmer_filtered(nucmer_file)
        fid = fopen(nucmer_file,'r');
        dat = textscan(fid, '%d %d | %d %d | %d %d | %f | %d %d | %f %f | %s %s','headerlines', 5);
        fclose(fid);
    end



end


