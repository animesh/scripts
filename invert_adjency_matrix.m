function inverted_G = invert_adjency_matrix(G)
    %Invert sparse adjency matrix
    
    
    if issparse(G)
        Gones = G;
        [x,y] = find(G);

        for xi = 1:length(x)
            Gones(x(xi),y(xi)) = 1;
        end

        inverted_G = max(max(G)).*Gones - G;

        for xi = 1:length(x)
            inverted_G(x(xi),y(xi)) = inverted_G(x(xi),y(xi)) + 1;
        end
    else     
        % Below works on non-sparse matrix
        inverted_G = max(max(G)).*ones(size(G)) - G + 1;
        inverted_G(G==0) = 0;
    end
end