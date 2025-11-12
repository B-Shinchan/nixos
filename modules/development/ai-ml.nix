{ config, pkgs, lib, ... }:

{
  ################################################################################
  # AI, Machine Learning, and Data Science Tools
  # Python libraries, Jupyter, and related tools
  ################################################################################

  environment.systemPackages = with pkgs; [
    ############################################################################
    # Python Data Science Libraries
    ############################################################################
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pandas
    python3Packages.matplotlib
    python3Packages.seaborn
    python3Packages.plotly
    python3Packages.scikit-learn
    python3Packages.scikit-image
    python3Packages.opencv4
    
    ############################################################################
    # Machine Learning Frameworks
    ############################################################################
    python3Packages.tensorflow
    python3Packages.torch
    python3Packages.torchvision
    python3Packages.keras
    
    ############################################################################
    # Jupyter and Notebooks
    ############################################################################
    jupyter
    python3Packages.jupyterlab
    python3Packages.notebook
    python3Packages.ipython
    python3Packages.ipykernel
    
    ############################################################################
    # Data Processing
    ############################################################################
    python3Packages.polars
    python3Packages.pyarrow
    python3Packages.dask
    
    ############################################################################
    # NLP and Text Processing
    ############################################################################
    python3Packages.nltk
    python3Packages.spacy
    python3Packages.transformers
    
    ############################################################################
    # Visualization
    ############################################################################
    python3Packages.pillow
    python3Packages.imageio
    
    ############################################################################
    # Database Connectivity
    ############################################################################
    python3Packages.sqlalchemy
    python3Packages.psycopg2
    python3Packages.pymongo
    
    ############################################################################
    # Scientific Computing
    ############################################################################
    python3Packages.sympy
    python3Packages.statsmodels
    
    ############################################################################
    # Utilities
    ############################################################################
    python3Packages.requests
    python3Packages.beautifulsoup4
    python3Packages.selenium
    python3Packages.pytest
  ];
  
  # CUDA Support (for NVIDIA GPUs - will be activated when GPU is added)
  # nixpkgs.config.cudaSupport = true;
}