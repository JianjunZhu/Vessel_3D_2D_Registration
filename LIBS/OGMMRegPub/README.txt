2D/3D and Oriented Point Set Registration Using Mixture of Gaussians
Copyright (c) 2013, Nora Baka and Theo van Walsum

Contact: 
Nora Baka: work.nora.baka@gmail.com
Theo van Walsum: t.vanwalsum@erasmusmc.nl

Website: 
www.bigr.nl/OGMMReg

Terms:
Please see the LICENSE file for details.
THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. 
COPYRIGHT HOLDERS ARE NOT LIABLE TO YOU FOR DAMAGES CAUSED BY THE PROGRAM.

Description:
The files in this folder contain the Matlab implementation of the 2D/3D and Oriented rigid point set registration method published in 
N. Baka, C.T. Metz, C.J. Schultz, R.-J. van Geuns, W. J. Niessen and T. van Walsum, Oriented Gaussian mixture models for non-rigid 2D/3D coronary artery registration
See the demos of 2D/3D registration, and Oriented GMM registration in the 2D/2D, 2D/3D and 3D/3D setting for a quick start.
Orientation is calculated in this implementation from the two neighboring points. Therefore, point sets have to be ordered for using the OGMM approach.

Files in this folder are organized as follows:
current folder:
    Contains the demo files, license and readme files 

data/
    contains the 2D fish datasets used in the demoOrient2D/2D.m file

MATLAB/  
    registration/
        Contains the core function GMMReg.m, the cost functions and transformation files.
        
	GaussTransform/
	    MEX-files for implementing the GaussTransform

	auxiliary/
	    Some supporting and conveniance functions.
		
To run the demos, change the Matlab current folder to the GMMRegPub folder, and add all subfolders to the Matlab search path.
Matlab and optimization toolbox licenses are required for running the code. The code was tested on Matlab R2011b with optimization toolbox version 6.1.

You are free to use and modify the code. If you found the code helpful, please cite the following paper:
N. Baka, C.T. Metz, C.J. Schultz, R.-J. van Geuns, W. J. Niessen and T. van Walsum, Oriented Gaussian mixture models for non-rigid 2D/3D coronary artery registration

With any questions please contact Nora Baka (work.nora.baka@gmail.com)

Acknowledgements:
This work was financially supported by ITEA project 09039, Mediate.

This code is an adaptation and extension of a previously published GMM based point set registration method by Bing Jian and Baba Vemuri. You find their original copyright notice below the delimiter line.

%-----------------------------------%---------------------------------------%---------------------------------------%---------------------------------------%-------------------
Robust Point Set Registration Using Mixture of Gaussians
Bing Jian and Baba C. Vemuri


Contact:
Bing Jian   bing.jian@gmail.com
Baba C. Vemuri:   vemuri@cise.ufl.edu

Website:
For the latest version, please visit
http://code.google.com/p/gmmreg/

Terms:
Please see the LICENSE file for details.

Description:
This website hosts implementations of the robust point set registration 
algorithm discribed in the following ICCV'05 paper:
 A Robust Algorithm for Point Set Registration Using Mixture of Gaussians, 
 Bing Jian and Baba C. Vemuri,
 10th IEEE International Conference on Computer Vision (ICCV 2005),
 17-20 October 2005, Beijing, China, pp. 1246-1251.

Currently we provide the implementations in C++, MATLAB, and Python, with full 
source code. You can download the source code for free, use and change it as 
you like, but please refer to this webpage and cite our paper.

A bibtex entry for this paper is given below:
@INPROCEEDINGS{Jian&Vemuri_iccv05,
    author = {Bing Jian and Baba C. Vemuri},
    title = {A Robust Algorithm for Point Set Registration Using Mixture of Gaussians.},
    booktitle = {10th IEEE International Conference on Computer Vision (ICCV 2005), 17-20 October 2005, Beijing, China},
    year = {2005},
    pages = {1246-1251},
}


Acknowledgment:
 [1] This research was in part supported by the National Institutes of Health (NIH RO1 NS046812 and NS42075). 
     The matrix/vector computation and optimization algorithm are implemented using the VXL/VNL software package. 

 [2] This work has benefited a lot from the code and datasets used in several past related work including:

    Haili Chui, Anand Rangarajan: A New Algorithm for Non-Rigid Point Matching. CVPR 2000: 2044-2051
    http://www.cis.ufl.edu/~anand/students/chui/research.html

    Andrew Fitzgibbon, Robust Registration of 2D and 3D Point Sets.  BMVC 2001
    http://research.microsoft.com/~awf/lmicp/

    Yanghai Tsin, Takeo Kanade: A Correlation-Based Approach to Robust Point Set Registration. ECCV (3) 2004: 558-569
    http://www.cs.cmu.edu/~ytsin/KCReg/

    Andriy Myronenko, Xubo B. Song, Miguel A. Carreira-Perpinan: Non-rigid point set registration: Coherent Point Drift. NIPS 2006: 1009-1016
    http://www.csee.ogi.edu/~myron/matlab/cpd/

 [3] This program was also tested on some other datasets provided by Adrian Peter, Tibério S. Caetano, Michal Sofka. 

    Adrian Peter and Anand Rangarajan, 
    "A New Closed-Form Information Metric for Shape Analysis," 
    Medical Image Computing and Computer-Assisted Intervention (MICCAI), 2006. 

    Tibério S. Caetano, Terry Caelli, Dale Schuurmans, Dante Augusto Couto Barone: 
    Graphical Models and Point Pattern Matching. 
    IEEE Trans. Pattern Anal. Mach. Intell. 28(10): 1646-1663 (2006) 

    Michal Sofka, Gehua Yang, Charles V. Stewart:
    Simultaneous Covariance Driven Correspondence (CDC) and Transformation Estimation in the Expectation Maximization Framework.
    IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2007

 [4] Many thanks go to Santhosh Kodipaka, Ting Chen and Andriy Myronenk for testing this program and providing helpful suggestions.

Related Links:

 [1] http://www.cise.ufl.edu/research/cvgmi/Software.php#gmmreg  

 [2] http://www.cis.ufl.edu/~anand/students/chui/research.html

 [3] http://research.microsoft.com/~awf/lmicp/

 [4] http://www.cs.cmu.edu/~ytsin/KCReg/

 [5] http://www.csee.ogi.edu/~myron/matlab/cpd/

 [6] http://www2.cs.man.ac.uk/~hous1/#downloads


Readme:
  Please refer to the file "readme.txt" in each subdirectory. 


Last modified:
June 28, 2008
