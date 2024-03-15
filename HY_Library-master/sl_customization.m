% 用于修改模型自定义库排列顺序
function sl_customization(cm)
    LibInfoStruct = slblocks;
    cm = sl_customization_manager;
    cm.LibraryBrowserCustomizer.applyOrder({'Simulink',-2,LibInfoStruct.Browser.Name,-1});  %将自定义库放在simulink后
end