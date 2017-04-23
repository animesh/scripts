function [ams ass pns] = assemble_paths(assembly_paths, contig_direct, Assemblies, deltafiles,deltafiles_ref, Ref_chrom, overlap)

if isa(assembly_paths,'double')
    assembly_paths = {assembly_paths};
end


ams = cell(size(assembly_paths));
ass = cell(size(assembly_paths));
pns = cell(size(assembly_paths));

for li = 1:size(assembly_paths,1)
    % Make alignment matrix from path
    [ams{li} ass{li} pns{li}] = assemble_path(assembly_paths{li}, contig_direct, Assemblies, deltafiles,deltafiles_ref, Ref_chrom, overlap);
end
