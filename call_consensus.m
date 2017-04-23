function [seq freq source] = call_consensus(am, as, assemblies)
%CALL_CONSENSUS Calls consensus from an alignment matrix
%
%   The consensus is called over the alignment matrix per column
%   Each row has to have a quality score attached to it given by 'qual'
%
% INPUT
% AM              Alignment matrix
% AS              Name of the assembly per row of 'AM'
% assemblies      Cell array with {assembly name, location on disk, qual}


    % Remove dots (gaps) in alignment matrix with no surrounding sequence
    am = RemoveGapsNotInSequence(am);

    % Get quality values for each row in the alignment matrix
    qual = zeros(1,size(am,1));
    for i = 1:length(qual)
        if isequal(as{i},'reference')
            qual(i) = -1000000000;
        else
            qual(i) = assemblies{ismember(assemblies(:,1),as(i)),3};
        end
    end

    last_column  = max(find(sum((logical(am(:,:) ~= char(0)) .* logical(am(:,:) ~= ' ')),1)));

    seq      = char(zeros(1,last_column));
    source   = zeros(1,last_column); % instead of base, a number inicating the source assembly
    base_pos = 1;
    
    % Count number of time a certain row is chosen
    freq        = zeros(1,size(am,1));
    row_numbers = 1:size(am,1);

    for i = 1:last_column

        % Get bases to choose from
        nonzeros = logical((am(:,i) ~= ' ') .* (am(:,i) ~= 0));

        % Get corresponding values and qualities
        bases      = am(nonzeros,i);
        qbases     = qual(nonzeros);
        row_number = row_numbers(nonzeros);

        % Choose base with highest score
        [~, im] = max(qbases);
        
        
        % Add base to consensus sequence
        if bases(im) ~= '.'
            
            % Count assembly usage
            freq(row_number(im)) = freq(row_number(im)) + 1;
            
            % Check if base is member of 4-letter DNA alphabet
            bases = upper(bases);
            if (bases(im) == 'T' || bases(im) == 'A' || bases(im) == 'G' || bases(im) == 'C')
                seq(base_pos)    = bases(im);
                source(base_pos) = row_number(im);
                base_pos         = base_pos + 1;
                
            % If highest quality base is not in 4 letter alphabet, but
            % there is one in another column than take this one
            elseif is_4letter_base_or_dot_in_column(bases)
                while 1
                    qbases(im) = -inf;
                    
                    % Select the highest scoring base
                    [~, im2] = max(qbases);
                    if (bases(im2) == 'T' || bases(im2) == 'A' || bases(im2) == 'G' || bases(im2) == 'C' || bases(im2) == '.')
                        if bases(im2) == '.'
                            break;
                        else
                            seq(base_pos)    = bases(im2);
                            source(base_pos) = row_number(im2);
                            base_pos         = base_pos + 1;
                            break;
                        end
                    else
                        % Eliminate for next round
                        qbases(im2) = -inf;
                    end
                end
                
            % If no better option, just take the extended alphabet letter
            else
                seq(base_pos)    = bases(im);
                source(base_pos) = row_number(im);
                base_pos         = base_pos + 1;
            end
                
                
        end

    end

    % Clip
    seq    = seq(1:base_pos-1);
    source = source(1:base_pos-1);
    
    function goodbase = is_4letter_base_or_dot_in_column(bases)
        % Check is there is a base from the 4 letter alphabet in this
        % column
        
        goodbase = false;
        
        for i = 1:length(bases)
            if (bases(i) == 'T' || bases(i) == 'A' || bases(i) == 'G' || bases(i) == 'C' || bases(i) == '.')
                goodbase = true;
                break;
            end
        end
    end

end

