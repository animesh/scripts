function a = merge_alignment(a,input_type, multiple_align)
% Merges alignments from a nucmer output file.
% if two contigs are aligned twice
%
% Scenario 1: alignments overlap
%   Longest alignment is kept, the other one is discarded
% Scenario 2: Alignments do not overlap
%   Alignments are merged and data are updated
%
% 
% Multiple align is hash table with alignments that have multiple hits

% Check if aa coords or deltafile has to be merged
if isequal(input_type,'coords')
    
        
    % Merging alignments is not implemented for the deltafile yet, so will
    % not be used at the moment. The smallest alignment of double entries
    % is removed for the time being.
    %a = merge_coords(a);
    
    a = remove_doubles_coords(a);
    
elseif isequal(input_type,'delta')
    
    a = remove_doubles_delta(a);
    
else 
    error('No valid input_type specified (coords or delta)');
    
end

%-----%-----%-----%-----%-----%-----%-----%-----%-----%-----%-----%-----%

    function a = remove_doubles_delta(a)
        
        if isempty(a)
        	return;
        end
        
        % Remove double entries from a delta file. The longest alignment is
        % kept (based on length of the alignment on the reference contig)
        
        r1 = arrayfun(@(x) x.R, a, 'UniformOutput',false)'; %R names
        q1 = arrayfun(@(x) x.Q, a, 'UniformOutput',false)'; %Q names
        rq = cellstr([str2mat(r1) str2mat(q1)]);
        
        to_remove = zeros(length(rq),1);
        
        k = keys(multiple_align);
        
        
        for mi = 1:size(k,2)
            
            % values
            v = multiple_align(k{mi});            
            
            % sizes
            %s = zero(1,size(v,2));
            largestv = 0;
            largestvi = 0;
            
            
            % Compute sizes
            for vi = 1:size(v,2)
                s = sum(abs(a(v(vi)).S1 - a(v(vi)).E1));
                if s > largestv
                    largestvi = vi;
                    largestv  = s;
                end
            end
            
            v(largestvi) = [];
            to_remove(v) = 1;
            
        end
        
        a = a(~to_remove);
    end
                
        
        
        
%         % Walk through rq array in search for double entries
%         for rowi = 1:length(rq)-1
%             % If he not already marked for removal
%             if to_remove(rowi) == 0
%                 % If he appears more then once in the array
%                 if sum(ismember(rq,rq{rowi})) > 1
%                     for rowj = rowi+1:length(rq)
%                         
%                         % If a double is found
%                         if isequal(rq(rowi),rq(rowj))
%                             
%                             % Delete smallest alignment (based on R sequence)
%                             if sum(abs(a(rowi).S1 - a(rowi).E1)) > sum(abs(a(rowj).S1 - a(rowj).E1))
%                                 to_remove(rowj) = 1;
%                             else
%                                 to_remove(rowi) = 1;
%                             end
%                         end
%                         
%                     end
%                 end
%             end
%         end
%         
%         a = a(~to_remove);
%         
%     end

    function a = remove_doubles_coords(a)
        % Loop through all nucmer files
        for file_number = 1:size(a,1)
            ai = a(file_number,:);
            to_remove = zeros(size(ai{1},1),1);
            Rs = ai{12};
            Qs = ai{13};
            
%             size(ai{1},1)-1
%             
%             % Get pairs that are not unique
%             [~,I,J] = uniqueRowsCA([Rs Qs]);
%             nonuniquerows = setdiff(1:size(ai{1},1),I);
%             nonuniques    = uniqueRowsCA([Rs(nonuniquerows) Qs(nonuniquerows)]);
%             
%             % Get positions of multiple alignment hits
%             locs = cell(size(nonuniques,1),1);
%             for u = 1:size(nonuniques,1)
%                 fprintf('%d\n',u);
%                 ri      = find(ismember(Rs,nonuniques{u,1}));
%                 qi      = find(ismember(Qs,nonuniques{u,2}));
%                 locs{u} = intersect(ri,qi);
%             end
%             
%             for mi = 1:size(nonuniques,1)
% 
%                 loc = locs{mi};
%                 
%                 % values
%                 %v = multiple_align(k{mi});            
% 
%                 % sizes
%                 %s = zero(1,size(v,2));
%                 largestl  = 0;
%                 largestli = 0;
% 
% 
%                 % Compute sizes
%                 for li = 1:size(loc,2)
%                     s = ai{5}(loc{li});
%                     %s = sum(abs(a(v(vi)).S1 - a(v(vi)).E1));
%                     if s > largestl
%                         largestli = li;
%                         largestl  = s;
%                     end
%                 end
% 
%                 loc(largestli)   = [];
%                 to_remove(loc)   = 1;
%             
%             end
            
            
            
            % Loop trough all rows (alignments)
            for i = 1:size(ai{1},1)-1
                fprintf('%d\n',i);
                % And compare them to all ohter alignments
                last_row = size(ai{1},1);
                current_row = i+1;
                while current_row <= last_row
                    % If there are rows that contain alignments of the same contig
                    if isequal(Rs(i),Rs(current_row)) && isequal(Qs(i),Qs(current_row))
                        
                        if ai{5}(i) > ai{5}(current_row)
                            to_remove(current_row) = 1;
                        else
                            to_remove(i) = 1;
                        end           
                    end
                    
                    current_row = current_row+1;
                    

                end
            end
            
            % Remove the rows that are marked for removal
            to_remove_pos = find(to_remove);
            for remi = length(to_remove_pos):-1:1
                ai = remove_row(ai,to_remove_pos(remi));
            end
            
            a(file_number,:) = ai;
        
        end
        
    end

    function add_to_multiple_align(multiple_align,R,Q,loc)
        
        if isKey(multiple_align, [R Q])
            v = multiple_align([R Q]);
            v = [v loc];
            multiple_align([R Q]) = v;
        else
            multiple_align([R Q]) = loc;
        end
    end


    function a = merge_coords(a)
        % Loop through all nucmer files
        for file_number = 1:size(a,1)
            ai = a(file_number,:);
            Rs = ai{12};
            Qs = ai{13};
            % Loop trough all rows (alignments)
            for i = 1:size(ai{1},1)-1
                % And compare them to all ohter alignments
                last_row = size(ai{1},1);
                current_row = i+1;
                while current_row <= last_row
                    % If there are rows that contain alignments of the same contig
                    if isequal(Rs(i),Rs(current_row)) && isequal(Qs(i),Qs(current_row))
                        ai = merge_two_alignments(ai,i,current_row);
                        ai = remove_row(ai,current_row);
                        Rs = ai{12};
                        Qs = ai{13};
                        last_row = last_row-1;
                    else
                        current_row = current_row+1;
                    end

                end
            end

            a(file_number,:) = ai;

        end
    end



        function ai = merge_two_alignments(ai,i,j)

            % Check if alignments are in same orientations
            if (ai{4}(i) < ai{3}(i) && ai{4}(j) > ai{3}(j))...
             || ai{4}(i) > ai{3}(i) && ai{4}(j) < ai{3}(j)
                % return longest alignment
                if ai{6}(i) > ai{6}(j)
                    return
                else
                   ai = copy_row(ai,j,i);
                end
            else

                % S1, E1, S2 and E2 positions of both rows
                Ri = sort([ai{1}(i) ai{2}(i)]);
                Rj = sort([ai{1}(j) ai{2}(j)]);
                Qi = sort([ai{3}(i) ai{4}(i)]);
                Qj = sort([ai{3}(j) ai{4}(j)]);

                % if the alignments overlap -> return the largest
                if    (Ri(1) > Rj(1) && Ri(1) < Rj(2))... 
                   || (Ri(2) < Rj(2) && Ri(2) > Rj(1))...
                   || (Qi(1) > Qj(1) && Qi(1) < Qj(2))...
                   || (Qi(2) < Qj(2) && Qi(2) > Qj(1))

                    % return longest alignment
                    if ai{6}(i) > ai{6}(j)
                        return
                    else
                       ai = copy_row(ai,j,i);
                    end

                else
                    % Merge alignments

                    % if Qi.E2  >  Qi.S2 (if straight)
                    if ai{4}(i) > ai{3}(i)

                              % min  Rj.S1 - Ri.E1  ,  Ri.S1 - Rj.E1
                        gapR = max(ai{1}(j)-ai{2}(i),ai{1}(i)-ai{2}(j));
                        gapQ = max(ai{3}(j)-ai{4}(i),ai{3}(i)-ai{4}(j));
                        LEN1 = ai{5}(i)+ai{5}(j)+gapR;
                        LEN2 = ai{6}(i)+ai{6}(j)+gapQ; 

                                   % ident      *  LEN1    +    ident       * LEN2           ident      *  LEN1    +    ident       * LEN2       /     
                        ident = ((ai{7}(i)/100) * ai{5}(i) + (ai{7}(i)/100) * ai{6}(i) + (ai{7}(j)/100) * ai{5}(j) + (ai{7}(j)/100) * ai{6}(j))  /  ...
                            ...
                            ...  % LEN1   +  LEN2  +  LEN1  +  LEN2  + gap1 + gap2
                                 (ai{5}(i)+ai{6}(i)+ai{5}(j)+ai{6}(j)+ gapR + gapQ);

                        % Add new values to row i
                        ai{1}(i) = min(ai{1}(i),ai{1}(j));
                        ai{2}(i) = max(ai{2}(i),ai{2}(j));
                        ai{3}(i) = min(ai{3}(i),ai{3}(j));
                        ai{4}(i) = max(ai{4}(i),ai{4}(j));
                        ai{5}(i) = LEN1;
                        ai{6}(i) = LEN2;
                        ai{7}(i) = ident;
                        ai{10}(i) = (LEN1/ai{8}(i))*100;
                        ai{11}(i) = (LEN2/ai{9}(i))*100;

                    % if Qi.E2  >  Qi.S2 (if rev.comp.)    
                    elseif ai{4}(i) < ai{3}(i)

                              % min  Rj.S1 - Ri.E1  ,  Ri.S1 - Rj.E1
                        gapR = max(ai{1}(j)-ai{2}(i),ai{1}(i)-ai{2}(j));
                        gapQ = max(ai{4}(j)-ai{3}(i),ai{4}(i)-ai{3}(j));
                        LEN1 = ai{5}(i)+ai{5}(j)+gapR;
                        LEN2 = ai{6}(i)+ai{6}(j)+gapQ; 

                                   % ident      *  LEN1    +    ident       * LEN2           ident      *  LEN1    +    ident       * LEN2       /     
                        ident = ((ai{7}(i)/100) * ai{5}(i) + (ai{7}(i)/100) * ai{6}(i) + (ai{7}(j)/100) * ai{5}(j) + (ai{7}(j)/100) * ai{6}(j))  /  ...
                            ...
                            ...  % LEN1   +  LEN2  +  LEN1  +  LEN2  + gap1 + gap2
                                 (ai{5}(i)+ai{6}(i)+ai{5}(j)+ai{6}(j)+ gapR + gapQ);

                        % Add new values to row i
                        ai{1}(i) = min(ai{1}(i),ai{1}(j));
                        ai{2}(i) = max(ai{2}(i),ai{2}(j));
                        ai{3}(i) = max(ai{3}(i),ai{3}(j));
                        ai{4}(i) = min(ai{4}(i),ai{4}(j));
                        ai{5}(i) = LEN1;
                        ai{6}(i) = LEN2;
                        ai{7}(i) = ident;
                        ai{10}(i) = (LEN1/ai{8}(i))*100;
                        ai{11}(i) = (LEN2/ai{9}(i))*100;                    

                    end

                end
            end

        end

        function ai = remove_row(ai,row)
            ai{1}(row) = [];
            ai{2}(row) = [];
            ai{3}(row) = [];
            ai{4}(row) = [];
            ai{5}(row) = [];
            ai{6}(row) = [];
            ai{7}(row) = [];
            ai{8}(row) = [];
            ai{9}(row) = [];
            ai{10}(row) = [];
            ai{11}(row) = [];
            ai{12}(row) = [];
            ai{13}(row) = [];
        end

        function ai = copy_row(ai, from_row, to_row)
            ai{1}(to_row) = ai{1}(from_row);
            ai{2}(to_row) = ai{2}(from_row);
            ai{3}(to_row) = ai{3}(from_row);
            ai{4}(to_row) = ai{4}(from_row);
            ai{5}(to_row) = ai{5}(from_row);
            ai{6}(to_row) = ai{6}(from_row);
            ai{7}(to_row) = ai{7}(from_row);
            ai{8}(to_row) = ai{8}(from_row);
            ai{9}(to_row) = ai{9}(from_row);
            ai{10}(to_row) = ai{10}(from_row);
            ai{11}(to_row) = ai{11}(from_row);
            ai{12}(to_row) = ai{12}(from_row);
            ai{13}(to_row) = ai{13}(from_row);
        end

end





