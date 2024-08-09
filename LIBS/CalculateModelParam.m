function ssmParam = CalculateModelParam(PriorModel,VesselPoints,varargin)
COEFF = PriorModel.COEFF;
MeanVector = PriorModel.MeanShape(:);
dim = PriorModel.dim;

if isempty(dim) || dim == 0
    dim = max(size(PriorModel.latent));
end

if nargin == 2
    vec = VesselPoints(:);
    ssmParam = COEFF(:,1:dim)\(vec - MeanVector); 
    ssmParam = ssmParam';
else
    quatParam = varargin{1};
%     r = quaternion2rotation(quatParam(1:4));
    result = transformPtsReverse(VesselPoints,quatParam);
    
    vec = result(:);
    ssmParam = COEFF(:,1:dim)\(vec - MeanVector); 
    ssmParam = ssmParam';
end

ssmParam = BoundingSSMParameter(PriorModel,ssmParam);

