function [max_contig number_of_contigs number_of_contigs_200 total_contig_size total_contig_size_200 n50_contigs] = ...
            assembly_stats(contigs_file)
% Genererate some statistics on an assembly
% INPUT: file name of a multi-fasta set with contigs
        
        
    F = fopen(contigs_file);

    % F = fopen('C:\Documents and Settings\Jurgen Nijkamp\Mijn documenten\Promotie\assembly\abyss-cenpk-contigs.fa')

    % Number of contigs: 
    % Number of contigs >200: 
    % Largest contig: 
    % N50: 
    % Total contig size: 
    % Total contig size >200: 

    contig_sizes = [];

    max_contig = 0;
    number_of_contigs = 0;
    number_of_contigs_200 = 0;
    total_contig_size = 0;
    total_contig_size_200 = 0;
    n50_contigs = 0;

    header = fgetl(F);
    seq = fgetl(F);
    while ~isequal(header, -1) && ~isequal(seq,-1)

        contig_sizes = [contig_sizes length(seq)];

        if contig_sizes(end) > max_contig
            max_contig = contig_sizes(end);
        end

        number_of_contigs = number_of_contigs + 1;
        total_contig_size = total_contig_size + contig_sizes(end);

        if contig_sizes(end) > 200
            number_of_contigs_200 = number_of_contigs_200 + 1;
            total_contig_size_200 = total_contig_size_200 + contig_sizes(end); 
        end

        header = fgetl(F);
        seq = fgetl(F);
    end
    n50_contigs = n50(contig_sizes);

    fclose(F);

end
        
    