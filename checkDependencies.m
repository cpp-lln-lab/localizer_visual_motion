function checkDependencies()

    pth = fileparts(mfilename('fullpath'));
    addpath(fullfile(pth, 'lib', 'CPP_BIDS'));
    addpath(fullfile(pth, 'lib', 'CPP_PTB'));
    addpath(fullfile(pth, 'subfun'));

end
