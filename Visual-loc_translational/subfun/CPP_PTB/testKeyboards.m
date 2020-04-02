function testKeyboards(cfg)

% Computer keyboard to quit if it is necessary
% cfg.keyboard
fprintf('\n This is a test: press any key to on the experimenter keyboard\n');
KbPressWait(cfg.keyboard);

% For key presses for the subject
% cfg.responseBox
fprintf('\n This is a test: press any key to on the participant response box\n');
KbPressWait(cfg.responseBox);


end