function outputParam = BoundingSSMParameter(PriorModel,inputParam)
nPara = max(size(inputParam));
latent = PriorModel.latent;
outputParam = zeros(size(inputParam));
for i = 1:nPara
    boundval = sqrt(latent(i))*5;
    if inputParam(i) > boundval
        outputParam(i) = boundval;
    elseif inputParam(i) < -boundval
        outputParam(i) = -boundval;
    else
        outputParam(i) = inputParam(i);
    end 
end

end