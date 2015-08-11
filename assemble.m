function [assembly] = assemble(contig, overlap, names, layout_path)
    
    
    % variable to store the final assembly
    assembly = struct('contig_name',[], 'startpos' ,[], 'endpos',[],'index',[]);
    
    pcontig = contig(layout_path);
    co = struct2cell(pcontig);
    co = co(1,:,:);
    
    % Convert overlap struct to cell array (only names for lookup)
    ov = struct2cell(overlap);
    ov = squeeze(ov(1:2,:,:));
    
    % get only overlap with contigs from path
%    ov = ov(:,sum(ismember(ov,co))>0);
    
    assembly_pos = 1;
    offset = 0;
    
    
    for i = 1:length(layout_path)-1
        
        ova = find_index_in_overlap(names(layout_path(i)),names(layout_path(i+1)),ov);
        
        % Determine which sequence will cover the assembly for the
        % positions in the alignments
        if contig(layout_path(i+1)).assembly_quality > contig(layout_path(i)).assembly_quality
            alignment_winner = layout_path(i+1);
            alignment_loser  = layout_path(i);
            winner_type      = 'N'; % Next contig
        else
            alignment_winner = layout_path(i);
            alignment_loser  = layout_path(i+1);
            winner_type      = 'C'; % Current contig
        end
        
        % Determine if it's the R or Q contig
        if isequal(overlap(ova).R, names{alignment_winner})
            overlap_winner = 'R';
        else
            overlap_winner = 'Q';
        end

       
        % Get the NON ALIGNED part of a contig and put it in the assembly
        [assembly clip_alignment] = get_non_aligned_part(contig, overlap, layout_path, assembly, assembly_pos, winner_type, offset, names);
        assembly_pos = assembly_pos+1;

        
        % Get the ALIGNED part of a contig and put it in the assembly
        assembly = get_aligned_part(contig, overlap, assembly, assembly_pos,alignment_winner,overlap_winner,clip_alignment, alignment_loser);         
        assembly_pos = assembly_pos+1;
        
        % TODO hier nog iets toevoegen waarbij het unaligned stuk van het
        % laatste contig toegevoegd wordt.
        
        
    end
    

    function [assembly clip_alignment] = get_non_aligned_part(contig, overlap, layout_path, assembly, assembly_pos, winner_type, offset, names)
        % 
        
            if assembly_pos > 1

                % Determine name
                assembly(assembly_pos).contig_name = assembly(assembly_pos-1).contig_name;

                % Determine startpos
                if winner_type == 'C'
                    assembly(assembly_pos).startpos = offset;
                elseif winner_type == 'N'
                    if contig().orient == 53
                        assembly(assembly_pos).startpos = assembly(assembly_pos-1).endpos + 1;
                    else
                        assembly(assembly_pos).startpos = assembly(assembly_pos-1).endpos - 1;
                    end
                else
                    error('winner_type not recognized');
                end
            
            else
                assembly(assembly_pos).contig_name = names{layout_path(1)};
                assembly(assembly_pos).startpos    = 1;
            end
                
            
            % if in the next alignment contig i == contig R
            % R contigs are only aligned in normal orientation, nucmer
            % tries to align only Q contigs in reverse complement
            if isequal(overlap(ova).R, names{layout_path(i)})
                
                % if orientation is 5' - 3'
                if contig(layout_path(i)).orient == 53
                    
                    % If there is a non aligned part between the two alignments
                    if assembly(assembly_pos).startpos < overlap(ova).S1
                        assembly(assembly_pos).endpos = overlap(ova).S1 - 1;
                    else
                        assembly(assembly_pos).endpos = -1;
                        clip_alignment = assembly(assembly_pos).startpos - overlap(ova).S1;
                    end

                % if orientation is 3' - 5'    
                elseif contig(layout_path(i)).orient == 35

                    % If there is a non aligned part between the two alignments
                    if assembly(assembly_pos).startpos > overlap(ova).E1
                        assembly(assembly_pos).endpos = overlap(ova).E1 + 1;
                    else
                        assembly(assembly_pos).endpos = -1;
                        clip_alignment = overlap(ova).E1 - assembly(assembly_pos).startpos;
                    end
                    
                else
                    error('Orientation not found')
                end
                
                
            % if the first contig was the Q contig  
            % Q contigs can also be aligned in reverse complement
            % orientations, so we'll have to account for that.
            elseif isequal(overlap(ova).Q, names{layout_path(i)})
                
                % if orientation is 5' - 3'
                if contig(layout_path(i)).orient == 53               

                    % if the contig is used in normal orientation
                    if overlap(ova).S1 < overlap(ova).E1
                        % If there is a non aligned part between the two alignments
                        if assembly(assembly_pos).startpos < overlap(ova).S2
                            assembly(assembly_pos).endpos = overlap(ova).S2 - 1;
                        else
                            assembly(assembly_pos).endpos = -1;
                            clip_alignment = assembly(assembly_pos).startpos - overlap(ova).S2;
                        end
                    % Else the reverse complement is used
                    else
                        % If there is a non aligned part between the two alignments
                        if assembly(assembly_pos).startpos < overlap(ova).E2
                            assembly(assembly_pos).endpos = overlap(ova).E2 - 1;
                        else
                            assembly(assembly_pos).endpos = -1;
                            clip_alignment = assembly(assembly_pos).startpos - overlap(ova).E2;
                        end
                    end
                    
                elseif contig(layout_path(i)).orient == 35
                    % if the contig is used in normal orientation
                    if overlap(ova).S1 < overlap(ova).E1
                        % If there is a non aligned part between the two alignments
                        if assembly(assembly_pos).startpos > overlap(ova).E2
                            assembly(assembly_pos).endpos = overlap(ova).E2 + 1;
                        else
                            assembly(assembly_pos).endpos = -1;
                            clip_alignment = overlap(ova).E2 - assembly(assembly_pos).startpos;
                        end
                    % Else the reverse complement is used
                    else
                        % If there is a non aligned part between the two alignments
                        if assembly(assembly_pos).startpos > overlap(ova).S2
                            assembly(assembly_pos).endpos = overlap(ova).S2 + 1;
                        else
                            assembly(assembly_pos).endpos = -1;
                            clip_alignment = overlap(ova).S2 - assembly(assembly_pos).startpos;
                        end
                    end
                else
                    error('Orientation not found');                    
                end
                
                
            else
                error('Contig was not found in overlap entry');
            end
    end
    

    function [assembly offset] = get_aligned_part(contig, overlap, assembly, assembly_pos,alignment_winner,overlap_winner,clip_alignment, alignment_loser)
                                                
        
        % START AND END POSTITION OF ALIGNMENT
        % If the first contig was the R contig
        if overlap_winner == 'R'
            if contig(alignment_winner).orient == 53
                assembly(assembly_pos).startpos = overlap(ova).S1;
                assembly(assembly_pos).endpos   = overlap(ova).E1;
                
                % Determine offset for next contig
                if contig(alignment_loser).orient == 53
                    offset = overlap(ova).E2 + 1;
                else
                    offset = overlap(ova).E2 - 1;
                end                           
                
            elseif contig(name_hash(overlap(ova).R)).orient == 35
                assembly(assembly_pos).startpos = overlap(ova).E1;
                assembly(assembly_pos).endpos   = overlap(ova).S1;
                
                % Determine offset for next contig
                if contig(alignment_loser).orient == 53
                    offset = overlap(ova).S2 + 1;
                else
                    offset = overlap(ova).S2 - 1;
                end
                
            else
                error('Orientation not found'); 
            end
                            

        % if the first contig was the Q contig
        elseif overlap_winner == 'Q'
            if contig(alignment_winner).orient == 53
                % if contig is in normal orientation
                if overlap(ova).S2 < overlap(ova).E2
                    assembly(assembly_pos).startpos = overlap(ova).S2;
                    assembly(assembly_pos).endpos   = overlap(ova).E2;
                else
                    assembly(assembly_pos).startpos = overlap(ova).E2;
                    assembly(assembly_pos).endpos   = overlap(ova).S2;
                end
                    
            elseif contig(alignment_winner).orient == 35
                % if contig is in normal orientation
                if overlap(ova).S2 < overlap(ova).E2
                    assembly(assembly_pos).startpos = overlap(ova).S2;
                    assembly(assembly_pos).endpos   = overlap(ova).E2;        
                else
                    assembly(assembly_pos).startpos = overlap(ova).E2;
                    assembly(assembly_pos).endpos   = overlap(ova).S2;
                end
            else
                error('Orientation not found'); 
            end
            
            % Determine offset for next contig
            if contig(alignment_loser).orient == 53
                offset = overlap(ova).E1 + 1;
            else
                offset = overlap(ova).S1 - 1;
            end
            
  
        end

        % If the overlap overlap the previous overlap, a greedy
        % method is implemented where the overlap that is more to
        % the 3' end of the chromosome is clipped
        % TODO make overlapping overlap hadling more optimal 
        if assembly(assembly_pos-1).endpos == -1
            old_startpos = assembly(assembly_pos).startpos;
            if assembly(assembly_pos).startpos < assembly(assembly_pos).endpos
                assembly(assembly_pos).startpos = assembly(assembly_pos).startpos + clip_alignment;
            else
                assembly(assembly_pos).startpos = assembly(assembly_pos).startpos - clip_alignment;
            end
            warning(['Startpos: ' old_startpos ' is changed to ' assembly(assembly_pos).startpos ...
                     ' while endpos is: ' assembly(assembly_pos).endpos ...
                     '\nClipping overlapping overlaps is a suboptimal solution']);
        end
            
        
    end
    
end
        