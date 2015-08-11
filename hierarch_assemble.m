function [chromosome stats] = hierarch_assemble(G, contig, overlap, names, layout_path)


    % variable to store the final assembly
    assembly = struct('contig_name',[], 'startpos' ,[], 'len',[],'index',[]);

    pcontig = contig(layout_path);
    co = struct2cell(pcontig);
    co = co(1,:,:);

    % Convert overlap struct to cell array (only names for lookup)
    ov = struct2cell(overlap);
    ov = squeeze(ov(1:2,:,:));
    
    % get only overlap with contigs from path
    ov = ov(:,sum(ismember(ov,co))>0);
    
    rest_contigs = [];
    while ~isempty(rest_contigs)
        % Get the best set of contigs from the list and add them to the assembly
        [best_contigs rest_contigs best_index rest_index] = get_best_and_rest(pcontigs);

        % Add to the assembly
        assembly = contigs_to_assembly(assembly, best_contigs, ov, layout_path, best_index);
    end
    


    function [best_contigs rest_contigs best_path rest_path] = get_best_and_rest(pcontigs, layout_path)
        % Get contig qualities
        q = arrayfun(@(x) x.assembly_quality, pcontigs);

        % Best contigs from list are going to be added to the assembly
        maxq = max(q);
        qpos = maxq == q;

        % best contigs
        best_contigs = pcontigs(qpos);
        best_path = layout_path(qpos);

        % Rest of the contigs
        rest_contigs = pcontigs(~qpos);
        rest_path = layout_path(~qpos);
    end
    
    function assembly = contigs_to_assembly(assembly, best_contigs, ov, layout_path, best_index)
        
        % Add contigs to assembly
        if isempty(assembly);
            for i = 1:length(best_contigs)
                add_to_assembly(i, best_contigs(i).name, 1, best_contigs(i).size, best_index(i));
            end
            
        else
            
            for i = 1:length(best_contigs)
                assembly_names = struct2cell(assembly);
                assembly_names = assembly_names(1,:,:);
                % Find overlapping contigs already in assembly
                ova = find_index_in_overlap(best_contigs(i).name,assembly_names,ov);
                
                if isempty(ova)
                    % Maar waar moet ik deze toevoegen???
                    % layout_path array doorlopen op zoek naar contig dat
                    % al in de assembly zit die er vlak voor komt.
                    pos = find_array_pos(best_contigs(i),assembly,layout_path);
                        
                    assembly = add_to_assembly('????',best_contigs(i).name,1,best_contigs(i).size); 
                
                else
                    % Merge alignment
                
                end
            end
        end
        
    end

    function assembly = add_to_assembly(arraypos, name, startpos, size, index)
        % TODO array should be spliced to insrt a new contig, instead of
        % overwite
        assembly(arraypos).contig_name = name;
        assembly(arraypos).startpos = startpos;
        assembly(arraypos).startpos = size;
        assembly(arraypos).index = index;
    end

    function find_array_pos(best_contig,assembly,layout_path)
        
    end
    

end