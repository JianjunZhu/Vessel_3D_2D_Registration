function [ixu,iyu] = uniqueCorr(ix,iy,ptsx,ptsy)
%% 已ix作为参考去除其重复, 根据距离筛选一对多的匹配

idxs = [];
id = 0;
tab = tabulate(ix);
for i = 1:size(tab,1)
    x_i = tab(i,1);
    c_i = tab(i,2);
    
    if i == 1 || i == size(tab,1)
        if i == 1
            id = 1;
            idxs = [idxs id];
            id = c_i;
        else
            id = id + c_i;
            idxs = [idxs id];
        end
    else 
        if c_i == 1
            id = id + 1;
            idxs = [idxs id];
        else
            idstemp = id+1:id+c_i;
            idstemp_x = ix(idstemp);
            idstemp_y = iy(idstemp);
            
            [~,imin] = min(sum(abs(ptsx(idstemp_x,:)-ptsy(idstemp_y,:)),2));
%             id = id + imin;
            idxs = [idxs id+imin];
            id = id + c_i;
        end
    end
    
end
ixu = ix(idxs);
iyu = iy(idxs);


% n = size(ix,1);
% idxs = [];
% idlast = 1;
% for i = 2:n
%     idnow = i;
%     if (ix(idlast)==ix(idnow)) || (iy(idlast)==iy(idnow))
%         dis1 = norm(ptsx(ix(idlast),:)-ptsy(iy(idlast),:));
%         dis2 = norm(ptsx(ix(idnow),:)-ptsy(iy(idnow),:));
% 
%         if dis1 < dis2
% 
%         else
%             idlast = idnow;
%         end
%     else
%         idxs = [idxs;idlast];
%         idlast = idnow;
%     end
% end
% ixu = ix(idxs);
% iyu = iy(idxs);

end