function K = normalizeK(Ki)
    maxVal = max(Ki(:));
    K = exp(-Ki/maxVal);
end