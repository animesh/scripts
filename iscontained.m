function [ref query] = iscontained(overlap,clipping_thrs)

    if length(overlap) > 1
        error('only one overlap can be analyzed by this function');
    end

    S1    = overlap.S1;
    E1    = overlap.E1;
    S2    = overlap.S2;
    E2    = overlap.E2;
    LENQ  = overlap.LENQ;
    LENR  = overlap.LENR;

    % Reference
    ref = logical(((S1 - clipping_thrs < 0) .* (LENR - E1 - clipping_thrs < 0)) + ((E1 - clipping_thrs < 0) .* (LENR - S1 - clipping_thrs < 0)));

    % Query
    query = logical(((S2 - clipping_thrs < 0) .* (LENQ - E2 - clipping_thrs < 0)) + ((E2 - clipping_thrs < 0) .* (LENQ - S2 - clipping_thrs < 0)));

end