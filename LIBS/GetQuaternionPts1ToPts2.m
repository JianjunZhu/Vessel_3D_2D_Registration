function quaternionPara = GetQuaternionPts1ToPts2(Pts1,Pts2)
[r,t] = CalculateTransformation(Pts1,Pts2);
quaternionPara = Transformation2quaternion([r,t]);