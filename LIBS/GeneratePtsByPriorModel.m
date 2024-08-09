function transformed_model = GeneratePtsByPriorModel(PriorModel,ssmParam,varargin)
%%
dim = PriorModel.dim;
if isempty(dim) || dim == 0
    dim = max(size(PriorModel.latent));
end
MeanShape = PriorModel.MeanShape;
MeanVector = MeanShape(:);
COEFF = PriorModel.COEFF;

%%
s = COEFF(:,1:dim)*ssmParam' + MeanVector;
transformed_model = reshape(s,size(MeanShape));
if nargin == 3
    quatParam = varargin{1};
    transformed_model = transform_by_rigid3d(transformed_model, quatParam);
end

end