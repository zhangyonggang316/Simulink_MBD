% �����޸�ģ���Զ��������˳��
function sl_customization(cm)
    LibInfoStruct = slblocks;
    cm = sl_customization_manager;
    cm.LibraryBrowserCustomizer.applyOrder({'Simulink',-2,LibInfoStruct.Browser.Name,-1});  %���Զ�������simulink��
end