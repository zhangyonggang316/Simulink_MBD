% 添加自定义通用库至simulink库中
function blkStruct = slblocks
    
    Browser(1).Library = 'HY_General_Library';
    Browser(1).Name = 'HY_Library';
    Browser(1).IsFlat=0;
    blkStruct.Browser = Browser;
    clear Browser;

end
    
  

