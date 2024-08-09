function id_select = selectionExpandedNode(Nodes,TreeAdjMatrix)
assert(length(Nodes)==size(TreeAdjMatrix,1));

if Nodes(1).Expandable == 0 && Nodes(1).ExpandCurrent == 0
    id_select = -1;
    return;
end

if length(Nodes) == 1
    id_select = 1;
else
    id_now = 1;
    while 1
        
        if ~Nodes(id_now).Expandable
            id_select = id_now;
            break;
        else
            ids_c = find(TreeAdjMatrix(id_now,:)==1);
        
            Qs = [Nodes(ids_c).QUrgency];
               
            Expandables = [Nodes(ids_c).Expandable];
            ExpandCurrent = [Nodes(ids_c).ExpandCurrent];
            ExpandAll = Expandables | ExpandCurrent;
            try
                Qs = Qs.*ExpandAll;
            catch ME
                Qs
                ExpandAll
            end
                
            [~, I] = max(Qs);
            id_now = ids_c(I);
            
        end
    end
end

end