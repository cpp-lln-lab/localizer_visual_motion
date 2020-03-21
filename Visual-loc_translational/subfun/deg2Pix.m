function structure = deg2Pix(fieldName, structure, Cfg)

deg = getfield( structure, fieldName);

structure = setfield( structure, [fieldName 'Ppd'], ...
    floor(Cfg.ppd * deg) ) ;

end