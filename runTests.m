function runTests()
    %
    % (C) Copyright 2022 CPP_BIDS developers

    % Elapsed time is ??? seconds.

    tic;

    cd(fileparts(mfilename('fullpath')));

    cfg.verbose = 0;
    checkCppBidsDependencies(cfg);

    if bids.internal.is_github_ci
        fprintf(1, '\nThis is github CI\n');
    else
        fprintf(1, '\nThis is not github CI\n');
    end

    fprintf('\nHome is %s\n', getenv('HOME'));

    warning('OFF');

    folderToCover = fullfile(pwd, 'src');
    testFolder = fullfile(pwd, 'tests');

    addpath(fullfile(testFolder, 'utils'));

    success = moxunit_runtests(testFolder, ...
                               '-verbose', '-recursive', '-with_coverage', ...
                               '-cover', folderToCover, ...
                               '-cover_xml_file', 'coverage.xml', ...
                               '-cover_html_dir', fullfile(pwd, 'coverage_html'));

    if success
        system('echo 0 > test_report.log');
    else
        system('echo 1 > test_report.log');
    end

    toc;

end
