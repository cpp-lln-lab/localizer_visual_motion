function test_suite = test_exDesign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_checkCfgDefault()
    
    initEnv();
    
    %         cfg.design.motionType = 'translation';
    cfg.design.motionType = 'translation';
    cfg.design.names = {'static'; 'motion'};
    cfg.design.nbRepetitions = 10;
    cfg.design.nbEventsPerBlock = 12;
    cfg.dot.speedPixPerFrame = 4;
    cfg.target.maxNbPerBlock = 1;
    displayFigs = 1;
    
    [cfg] = expDesign(cfg, displayFigs)
    
    
end