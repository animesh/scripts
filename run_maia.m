% MAIA demo with a small part of chromosome 9 for S. cerevisiae CENPK
 

% 1. Define location of your data

	% Reference chromosome
	Ref_chrom = './data/ref_genome/chr9_s288c.fa';
	Startnode = 'chr9_contig_783';
	Endnode = 'chr9_contig_785';
	
	% Fasta files with contigs
	Assemblies = ...
		{'s288c' ,'./data/assemblies/s288c_comparative.fa',2; ...
		 'celera' ,'./data/assemblies/celera_denovo.fa',2; ...
		 'rm11-1a' ,'./data/assemblies/rm11-1a_comparative.fa',2; ...
		 'abyss' ,'./data/assemblies/abyss_denovo.fa',3};
	
	% Location of the individual contigs of the assemblies
	contig_locs = ...
		{'./data/assemblies/contigs/'; ...
		 './data/assemblies/contigs/'; ...
		 './data/assemblies/contigs/'; ...
		 './data/assemblies/contigs/'};


% 2. Set some parameters

	% Which assembly do you want to align to the reference to connect pseudonodes
	Assemblies_for_refnodes = [1];

	% Define weights, which are used for z-score combination
	% The following weights have to be defined:
	% z_weights(1) = Contig length
	% z_weights(2) = Alignment length
	% z_weights(3) = Non aligned overlap
	% z_weights(4) = Assembly quality
	z_weights = [.35 .25 .15 .25];
	
	% Define a clipping threshold. Alignments that have overhang of more then
	% this threshold are not considered
	clipping_thrs = 10;
	
	% Specifify the z-score distance that edges towards a 'reference node' will
	% get
	ref_distance = -10;

	% Specify an 'assembly quality' score for the reference nodes
	ref_quality = 1E-5;
	
	% Specify a maximum distance (in number of nt's) of two alignments allowed 
	% to connect two contigs with a reference node, or 'opt' to let MAIA optimize this distance
	max_chromosome_dist = 'opt';


% 3. Run MAIA
	[adj_direct contig_direct overlap names assembly_path weigth_direct deltafiles deltafiles_ref] = assembly_driver(Assemblies,Ref_chrom,Startnode, Endnode, 'ref_node_assemblies',Assemblies_for_refnodes,'max_chromosome_dist',max_chromosome_dist);


% 4. Visualize graph results (red line is highest scoring path)
	% Your overlap graph is now done, and a highest scoring path is found with a Tabu search
	% You can inspect your graph with for example Cytoscape by exporting it to .xgmml
	numlabs = 1:size(adj_direct,1);                % Give the nodes a numerical label
	numlabs = cellstr(num2str(numlabs'));          % in the order they appear in the adjency matrix
	[nodes, edges] = maia2cytoscape(adj_direct,names,contig_direct,numlabs,assembly_path(1),adj_direct,assembly_path);
	export_xgmml('maia_example.xgmml','maia_example',nodes,edges)

 
% 5. Greedy extend highest scoring path on both sides (Not applicable in this small example)
    assembly_path = extend_path(adj_direct,contig_direct,overlap,assembly_path,[],'forward');
    assembly_path = extend_path(adj_direct,contig_direct,overlap,assembly_path,[],'backward');

% 6. Split out too large pseudo nodes (Not applicable in this small example)
    
    max_ref_node_size = 250;  % maximum size of a reference node to have in your assembly
    min_alen          = 400;  % Min alignment length for extension
    min_ident         = 99;   % Min alignment identity for extension
    % Split the assembly at thos refnodes, backtrack to a split position and extend
    ap_splitted = split_and_extend(adj_direct, assembly_path, contig_direct,overlap, max_ref_node_size,min_alen, min_ident);


% 7. Generate alignment matrix
    [ams ass] = assemble_paths(ap_splitted, contig_direct, Assemblies, deltafiles,deltafiles_ref, contig_locs, Ref_chrom, overlap);


% 8. Call consensus  
	[s, f] = call_consensuses(ams,ass, Assemblies);


% 9. Write the assembly to disk
	pos = 0;
    for si = 1:size(s,1)
        pos = pos+1;
           
        assembly(pos).Header   = ['Maia_contig_' num2str(si)];
        assembly(pos).Sequence = s{si};
    end
    
    filename = 'maia_assembly.fa';
    if isempty(dir(filename))
		fastawrite(filename,assembly);
	else
		error(['File ' filename ' already exists, please remove or choose other name']);
	end
		


