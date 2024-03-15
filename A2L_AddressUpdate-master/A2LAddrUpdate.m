%--------------------------------------------------------------------------
%   文 件 名：A2LAddrUpdate.m
%   文件描述：A2L地址更新
%   版    本：V2.0.1
%   修改日期：
%           2021/09/27  许鸿江   新建文件，a2l变量地址更新代码
%           2022/01/14  许鸿江   修复原中断INCA生成时，未改文件名问题，
%                                修改直接生成_CANape、_INCA文件，不再生成_BK，
%                                修改文件选择提示框界面标题，完成后直接打开文件夹
%           2022/05/06  许鸿江   修复中文字符显示异常问题
%           2022/05/07  许鸿江   将原选择ID操作改为弹窗形式
%           2022/11/23  许鸿江   1、修改为UI界面操作，增加ID定义更新接口
%                                2、修复INCA文件中100ms事件定义误写问题
%           2022/12/28  许鸿江   1、修复生成结束后的A2L文件被matlab意外占用，
%                                   INCA无法读取问题
%--------------------------------------------------------------------------
function A2LAddrUpdate()
    warning off
    clear
    VersionStr = 'V2.0.1';
    global GUI_A2LTool
    global GUI_DataTemp;
    GUI_DataTemp = {};
    global GUI_IDData;
    
    try 
        close( GUI_A2LTool.FigHndl )    % 避免句柄残留
    catch 
    end 
    
    datafile = which('ECUID.mat');
    
    if ~isempty(datafile)
        load(datafile);
    else
        Answer = questdlg('未找到ID定义数据文件ECUID.mat，请选择是否导入定义文件并继续?', 'ID定义导入', '是','否','否');
        switch Answer
            case '是'
                Load_Callback;
            case '否'
                return;    
        end
    end
    
    StrTemp = 'a2l地址更新工具';
    GUI_A2LTool.FigHndl = figure( 'units', 'pixels',  ...
                                'Position', [ 340, 100, 850, 650 ],  ...
                                'menubar', 'none',  ...
                                'name', StrTemp,  ...
                                'numbertitle', 'off',  ...
                                'resize', 'off' );
                                    
    set( GUI_A2LTool.FigHndl, 'CloseRequestFcn', @CloseGuiFcn )
                                 
    GUI_A2LTool.TitleTxt = uicontrol( 'Parent', GUI_A2LTool.FigHndl,  ...
                                        'Style', 'text',  ...
                                        'Position', [ 180, 600, 440, 40 ],  ...
                                        'FontSize',16,...
                                        'String', '皓耘科技整机控制开发部A2L工具');

    GUI_A2LTool.VersionTxt = uicontrol('Parent', GUI_A2LTool.FigHndl,...
                                        'Style', 'text',...
                                        'Position', [ 730, 600, 80, 36 ],  ...
                                        'FontSize',14,...
                                        'String', VersionStr);
                                    
    GUI_A2LTool.LoadBtn = uicontrol('Parent', GUI_A2LTool.FigHndl,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 10, 610, 30, 30 ],  ...
                                       'FontSize',10,...
                                       'HorizontalAlignment','center',...
                                       'String', '',  ...
                                       'Callback', @Load_Callback,...
                                       'CData',GUI_IDData.Reload,...
                                       'BackgroundColor',[0 0 0],...
                                       'Tooltip','导入保存ID定义');
                                    
    % 设计panel                                
    GUI_A2LTool.FuncFig = uipanel( 'Parent', GUI_A2LTool.FigHndl, 'units', 'pixels',  ...
                                   'Title', char( [  ] ), 'Position', [ 0, 0, 850, 600 ], 'Visible', 'on' );
    
    % 设计Tab                               
    TabId = uitabgroup( GUI_A2LTool.FuncFig, 'Position', [ 0, 0, 1, 1 ] );
    StrTemp = 'AddrUpdate';
    UpdateTab = uitab( TabId, 'Title', StrTemp );
    StrTemp = 'CANape2INCA';
    Ape2IncaTab = uitab( TabId, 'Title', StrTemp );
    
    % Tab xls2dbc
    GUI_A2LTool.PathTxt = uicontrol('Parent', UpdateTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 505, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', 'A2L路径：');
    
    GUI_A2LTool.A2LPath = uicontrol('Parent', UpdateTab,...
                                    'Style', 'edit',...
                                    'Position', [ 100, 500, 630, 50 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '',...
                                    'Max',2,...
                                    'Enable','off');
                                
    GUI_A2LTool.A2LSelBtn = uicontrol('Parent', UpdateTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 750, 505, 80, 45 ],  ...
                                       'FontSize',10,...
                                       'HorizontalAlignment','center',...
                                       'String', '选择空A2L',  ...
                                       'Callback', @SelA2L_Callback);
                                   
   GUI_A2LTool.ELFTxt = uicontrol('Parent', UpdateTab, 'Style', 'text',...
                                        'Position', [ 10, 445, 90, 40 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', 'ELF路径：');
                                    
    GUI_A2LTool.ELFPath = uicontrol('Parent', UpdateTab,...
                                    'Style', 'edit',...
                                    'Position', [ 100, 440, 630, 50 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '',...
                                    'Max',2,...
                                    'Enable','off');
                                   
    GUI_A2LTool.ELFSelBtn = uicontrol('Parent', UpdateTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 750, 440, 80, 45 ],  ...
                                       'FontSize',10,...
                                       'HorizontalAlignment','center',...
                                       'String', '选择ELF',  ...
                                       'Callback', @SelELF_Callback);
                                   
    GUI_A2LTool.A2LNameTxt = uicontrol('Parent', UpdateTab, 'Style', 'text',...
                                        'Position', [ 10, 400, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', 'A2L名称：');
    GUI_A2LTool.A2LNameStr = uicontrol('Parent', UpdateTab,...
                                       'Style', 'edit',...
                                       'Position', [ 100, 400, 630, 30 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','left',...
                                       'String', '');
    
    GUI_A2LTool.TypeTxt = uicontrol('Parent', UpdateTab, 'Style', 'text',...
                                    'Position', [ 10, 355, 90, 30 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '农机类型：');
    GUI_A2LTool.MechType = uicontrol('Parent', UpdateTab,...
                                     'Style', 'popup',...
                                     'Position', [ 100, 340, 140, 50 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', GUI_IDData.MechType',...
                                     'Callback', @MechTypeSel_callback);
    GUI_A2LTool.IDTxt = uicontrol('Parent', UpdateTab, 'Style', 'text',...
                                    'Position', [ 250, 355, 90, 30 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', 'ECU ID：');
    GUI_A2LTool.ECUID = uicontrol('Parent', UpdateTab,...
                                     'Style', 'popup',...
                                     'Position', [ 325, 340, 300, 50 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', { '空(0x0000)' });
    
    GUI_A2LTool.GenFileTxt = uicontrol('Parent', UpdateTab, 'Style', 'text',...
                                        'Position', [ 10, 315, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', '生成文件：');
    GUI_A2LTool.GenFileSel = uicontrol('Parent', UpdateTab,...
                                        'Style', 'popup',...
                                         'Position', [ 100, 290, 140, 50 ],  ...
                                         'FontSize',12,...
                                         'HorizontalAlignment','left',...
                                         'String', { 'CANape&INCA';'CANape';'INCA' });
                                     
    GUI_A2LTool.ClearListBtn = uicontrol('Parent', UpdateTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 325, 310, 140, 40 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '清空提示列表',  ...
                                       'Callback', @ClearList_Callback);
                                   
   GUI_A2LTool.GenDbcBtn = uicontrol('Parent', UpdateTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 670, 320, 140, 70 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '生成A2L',  ...
                                       'Callback', @GenDBC_Callback);
                                   
    GUI_A2LTool.InfoTxt = uicontrol('Parent', UpdateTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 250, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '信息提示：');

    GUI_A2LTool.InfoList = uicontrol('Parent', UpdateTab,...
                                     'Style', 'listbox',...
                                     'Position', [ 100, 20, 720, 260 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', GUI_DataTemp,...
                                     'Max',max(1,size(GUI_DataTemp,1)),...
                                     'Value',max(1,size(GUI_DataTemp,1)));

    % Tab dbc2file
    GUI_A2LTool.WarningTxt = uicontrol('Parent', Ape2IncaTab,...
                                    'Style', 'text',...
                                    'Position', [ 200, 100, 400, 200 ],  ...
                                    'FontSize',24,...
                                    'HorizontalAlignment','left',...
                                    'String', '功能开发中！！！');
    
%     fJFrame = get( GUI_A2LTool.FigHndl, 'JavaFrame');
%     pause(0.01);
%     fJFrame.fHG2Client.getWindow.setAlwaysOnTop( true );
end

function CloseGuiFcn( ~, ~ )
    global GUI_A2LTool
    try 
        close( GUI_A2LTool.FigHndl )
    catch
        closereq;
    end 
    
end

function Load_Callback(~,~)
    global GUI_A2LTool
    global GUI_IDData
    [Name,Path] = uigetfile({'*.xls;*.xlsx'},'请选择一个数据文件');
    
    if ~isequal(Name,0)
        FileName = [Path,Name];
        if contains(FileName,{'.xls','.xlsx'})  %读取xls定义
            if strcmpi(FileName(end-3:end),'.xls') || strcmpi(FileName(end-4:end),'.xlsx')
                [~,SheetNames] = xlsfinfo([Path,Name]);     % 获取工作表名
                GUI_IDData.MechType{1} = '空';
                for idx=1:1:size(SheetNames,2)
                    if strcmp(SheetNames{1,idx},'拖拉机')
                        if ~ismember(SheetNames{1,idx},GUI_IDData.MechType)
                            GUI_IDData.MechType{numel(GUI_IDData.MechType)+1} = SheetNames{1,idx};
                        end
                        [~,~,TractorIDText] = xlsread(FileName,SheetNames{1,idx});
                        if contains(cell2mat(TractorIDText(1,1)), {'项目名称'})... 
                            && contains(cell2mat(TractorIDText(1,2)), {'ECU ID(hex)'})
                            DefineTxt = TractorIDText(2:end,1:2);
                            TractorIDTemp = {};
                            for j=1:1:size(DefineTxt,1)
                                NameStr = cell2mat(DefineTxt(j,1));
                                IDStr = cell2mat(DefineTxt(j,2));
                                if contains(cell2mat(DefineTxt(j,2)), {'0x','0X'})
                                    TractorIDTemp{j} = [NameStr,'(',IDStr,')'];
                                else
                                    TractorIDTemp{j} = [NameStr,'(0x',IDStr,')'];
                                end
                            end
                            GUI_IDData.TractorID = TractorIDTemp;
                        end
                    elseif strcmp(SheetNames{1,idx},'收获机')
                        if ~ismember(SheetNames{1,idx},GUI_IDData.MechType)
                            GUI_IDData.MechType{numel(GUI_IDData.MechType)+1} = SheetNames{1,idx};
                        end
                        [~,~,HarvesterIDText] = xlsread(FileName,SheetNames{1,idx});
                        if contains(cell2mat(HarvesterIDText(1,1)), {'项目名称'})... 
                            && contains(cell2mat(HarvesterIDText(1,2)), {'ECU ID(hex)'})
                            DefineTxt = HarvesterIDText(2:end,1:2);
                            HarvesterIDTemp = {};
                            for j=1:1:size(DefineTxt,1)
                                NameStr = cell2mat(DefineTxt(j,1));
                                IDStr = cell2mat(DefineTxt(j,2));
                                if contains(cell2mat(DefineTxt(j,2)), {'0x','0X'})
                                    HarvesterIDTemp{j} = [NameStr,'(',IDStr,')'];
                                else
                                    HarvesterIDTemp{j} = [NameStr,'(0x',IDStr,')'];
                                end
                            end
                            GUI_IDData.HarvesterID = HarvesterIDTemp;
                        end
                    elseif strcmp(SheetNames{1,idx},'农机具')
                        if ~ismember(SheetNames{1,idx},GUI_IDData.MechType)
                            GUI_IDData.MechType{numel(GUI_IDData.MechType)+1} = SheetNames{1,idx};
                        end
                        [~,~,ACUIDText] = xlsread(FileName,SheetNames{1,idx});
                        if contains(cell2mat(ACUIDText(1,1)), {'项目名称'})... 
                            && contains(cell2mat(ACUIDText(1,2)), {'ECU ID(hex)'})
                            DefineTxt = ACUIDText(2:end,1:2);
                            ACUIDTemp = {};
                            for j=1:1:size(DefineTxt,1)
                                NameStr = cell2mat(DefineTxt(j,1));
                                IDStr = cell2mat(DefineTxt(j,2));
                                if contains(cell2mat(DefineTxt(j,2)), {'0x','0X'})
                                    ACUIDTemp{j} = [NameStr,'(',IDStr,')'];
                                else
                                    ACUIDTemp{j} = [NameStr,'(0x',IDStr,')'];
                                end
                            end
                            GUI_IDData.ACUID = ACUIDTemp;
                        end
                    end
                end
                if ishandle(GUI_A2LTool.MechType)
                    set(GUI_A2LTool.MechType,'Value', 1);
                end
                
                if ishandle(GUI_A2LTool.ECUID)
                    set(GUI_A2LTool.ECUID,'String', {'空(0x0000)'});
                    set(GUI_A2LTool.ECUID,'Value', 1);
                end
                UpdateInfoList('ID定义更新完成！！！');
                Answer = questdlg('ID定义更新完成，请选择是否保存更新的后ECU ID数据?', '数据保存', '是','否','否');
                switch Answer
                    case '是'
                        save('ECUID.mat','GUI_IDData');
                        UpdateInfoList('ID定义已保存至 ECUID.mat ！！！');
                    case '否'
                        UpdateInfoList('您已选择不保存更新的ECU ID！！！');    
                end
            end
        else
            UpdateInfoList('未选择任何excel文件，ID定义更新退出');
        end
    else
        UpdateInfoList('未选择任何文件，ID定义更新退出');
    end
end



function SelA2L_Callback(~,~)
    global GUI_A2LTool
    [A2L_Name,A2L_Path] = uigetfile('*.a2l','请选择一个空地址的a2l文件');
    if ~isequal(A2L_Name,0)
        if contains(A2L_Name,{'.a2l'})
            try
                set(GUI_A2LTool.A2LPath, 'String', [A2L_Path,A2L_Name]);
                set(GUI_A2LTool.A2LPath, 'Value', 2);
                set(GUI_A2LTool.A2LNameStr, 'String', A2L_Name);
            catch
                % 暂不做任何事情
            end
        else
            set(GUI_A2LTool.A2LPath, 'String', '');
            set(GUI_A2LTool.A2LPath, 'Value', 1);
            set(GUI_A2LTool.A2LNameStr, 'String', '');
            UpdateInfoList('选中文件非A2L文件，请重新选择！！！');
            msgbox('选中文件非A2L文件，请重新选择！！！');
        end
    else
        UpdateInfoList('未选择任何文件');
    end
end

function SelELF_Callback(~,~)
    global GUI_A2LTool
    [ELF_Name,ELF_Path] = uigetfile('*.elf','请选择集成代码编译生成的elf文件');
    if ~isequal(ELF_Name,0)
        if contains(ELF_Name,{'.elf'})
            try
                set(GUI_A2LTool.ELFPath, 'String', [ELF_Path,ELF_Name]);
                set(GUI_A2LTool.ELFPath, 'Value', 2);
            catch
                % 暂不做任何事情
            end
        else
            set(GUI_A2LTool.ELFPath, 'String', '');
            set(GUI_A2LTool.ELFPath, 'Value', 1);
            UpdateInfoList('选中文件非ELF文件，请重新选择！！！');
            msgbox('选中文件非ELF文件，请重新选择！！！');
        end
    else
        UpdateInfoList('未选择任何文件');
    end
end

function UpdateInfoList(InfoStr)
    global GUI_A2LTool
    global GUI_DataTemp
    
    if isempty(GUI_DataTemp)
        GUI_DataTemp = {InfoStr};
    else
        GUI_DataTemp = [GUI_DataTemp;InfoStr];
    end
    if ishandle(GUI_A2LTool.InfoList)
        set(GUI_A2LTool.InfoList, 'String', GUI_DataTemp);
        set(GUI_A2LTool.InfoList, 'Max', size(GUI_DataTemp,1));
        set(GUI_A2LTool.InfoList, 'Value',get(GUI_A2LTool.InfoList, 'Max'));
        pause(0.001);
        if get(GUI_A2LTool.InfoList, 'Max') > 1
            set(GUI_A2LTool.InfoList, 'Value',[]);
        end
    end
end

function ClearList_Callback(~, ~)
    global GUI_A2LTool
    global GUI_DataTemp
    GUI_DataTemp = {};
    if ishandle(GUI_A2LTool.InfoList)
        set(GUI_A2LTool.InfoList, 'String', GUI_DataTemp,'Value',1);
    end
end

function MechTypeSel_callback(~, ~)
    % ECU ID定义
    global GUI_A2LTool
    global GUI_IDData

    % 农机类型选择
    idx = get(GUI_A2LTool.MechType,'Value');
    popup_items = get(GUI_A2LTool.MechType,'String');
    Type = char( popup_items( idx, : ) );

    %根据不同农机类型，更新ID选择下拉列表内容，同时需要将索引值设置回到最顶（1），避免超界
    if strcmp(Type,'拖拉机')
        set(GUI_A2LTool.ECUID,'Value', 1);
        set(GUI_A2LTool.ECUID,'String', GUI_IDData.TractorID);
    elseif strcmp(Type,'收获机')
        set(GUI_A2LTool.ECUID,'Value', 1);
        set(GUI_A2LTool.ECUID,'String', GUI_IDData.HarvesterID);
    elseif strcmp(Type,'农机具')
        set(GUI_A2LTool.ECUID,'Value', 1);
        set(GUI_A2LTool.ECUID,'String', GUI_IDData.ACUID);
    else
        set(GUI_A2LTool.ECUID,'Value', 1);
        set(GUI_A2LTool.ECUID,'String', {'空(0x0000)'});
    end

end

function GenDBC_Callback(~,~)
    global GUI_A2LTool
    
    GenCANapeFlg = 0;
    GenINCAFlg = 0;
    
    A2LFile = get(GUI_A2LTool.A2LPath,'String');
    ELFFile = get(GUI_A2LTool.ELFPath,'String');
    GenA2LName = get(GUI_A2LTool.A2LNameStr,'String');
    ECUID = get(GUI_A2LTool.ECUID,'String');
    ECUIDStr = cell2mat(ECUID(get(GUI_A2LTool.ECUID,'Value')));
    A2LType = get(GUI_A2LTool.GenFileSel,'String');
    A2LTypeStr = cell2mat(A2LType(get(GUI_A2LTool.GenFileSel,'Value')));
    
    if (isempty(A2LFile) && isempty(ELFFile)) ...
        || (~strcmpi(A2LFile(end-3:end),'.a2l') && ~strcmpi(ELFFile(end-3:end),'.elf'))
        UpdateInfoList('未选择A2L文件与ELF文件！！！');
        return;
    elseif isempty(A2LFile) || ~strcmpi(A2LFile(end-3:end),'.a2l')
        UpdateInfoList('未选择A2L文件！！！');
        return;
    elseif isempty(ELFFile) || ~strcmpi(ELFFile(end-3:end),'.elf')
        UpdateInfoList('未选择ELF文件！！！');
        return;
    elseif isempty(GenA2LName)
        UpdateInfoList('未定义生成的A2L文件名！！！');
        return;
    else
        ECUIDNumLetter = regexp(ECUIDStr,'0[xX][0-9a-zA-Z]+','match','once');  %匹配0x????的字符串，后为16进制
        ECUIDOKAll = regexp(ECUIDStr,'0[xX][0-9a-fA-F]+','match','once');  %匹配0x????的字符串，后为16进制
        ECUIDWtire = regexp(ECUIDStr,'0[xX][0-9a-fA-F]{4}','match','once');  %匹配0x????的字符串，后为16进制
        
        try
            esa = rtw.esa.ESA(ELFFile);
        catch ME1
            if strcmp( ME1.identifier, 'RTW:asap2:FileNotELF' )
                DAStudio.error( 'RTW:asap2:FileNotELF', ELFFile );
            else 
                DAStudio.error( 'RTW:asap2:UnableAnalyzeFile', ELFFile );
            end 
        end 

        try 
            symtab = esa.getSymbolTable;
        catch ME2
            DAStudio.error( 'RTW:asap2:UnableAnalyzeFile', ELFFile );
        end

        backslash = find(A2LFile == '\', 1, 'last' );
        if isempty(backslash)
            UpdateInfoList('A2L文件目录异常，生成进程已终止！！！');
            return;
        else
            A2L_Path = A2LFile(1:backslash);
        end
        
        if strcmpi(A2LTypeStr,'CANape')
            GenCANapeFlg = 1;
            GenINCAFlg = 0;
        elseif strcmpi(A2LTypeStr,'INCA')
            GenCANapeFlg = 0;
            
            if isempty(ECUIDWtire)
                UpdateInfoList('ECU ID非标准16位格式，将取消生成INCA可用A2L文件！！！');
            else
                if ~strcmp(ECUIDNumLetter,ECUIDOKAll)
                    UpdateInfoList('ECU ID包含非十六进制字母，将取消生成INCA可用A2L文件！！！');
                elseif ~strcmp(ECUIDWtire,ECUIDOKAll)
                    UpdateInfoList('ECU ID非标准16位格式，将取消生成INCA可用A2L文件！！！');
                else
                    GenINCAFlg = 1;
                end
            end
        else
            GenCANapeFlg = 1;
            if isempty(ECUIDWtire)
                UpdateInfoList('ECU ID非标准16位格式，将取消生成INCA可用A2L文件！！！');
            else
                if ~strcmp(ECUIDNumLetter,ECUIDOKAll)
                    UpdateInfoList('ECU ID包含非十六进制字母，将取消生成INCA可用A2L文件！！！');
                elseif ~strcmp(ECUIDWtire,ECUIDOKAll)
                    UpdateInfoList('ECU ID非标准16位格式，将取消生成INCA可用A2L文件！！！');
                else
                    GenINCAFlg = 1;
                end
            end
        end
        
        if numel(GenA2LName) > 4
            if strcmpi('.a2l',GenA2LName(end-3:end))
                GenA2LName = GenA2LName(1:end-4);       
            end
        end
        
        addrPrefix = '0x0000 \/\* @ECU_Address@';
        addrSuffix = '@ \*\/';

        a2lText = fileread(A2LFile);
        
        if GenCANapeFlg == 1
            repfun = @( name )loc_getSymbolValForName( name );
            newA2LText = regexprep( a2lText, [ addrPrefix, '(\w+)', addrSuffix ],'0x${repfun($1)}' );
            CANapeFileName = [GenA2LName,'_CANape.a2l'];
            CANapefid = fopen([A2L_Path,CANapeFileName], 'w+','n','GB2312');
            fprintf( CANapefid, '%s',newA2LText );
            fclose('all');
            
            UpdateInfoList(['=======CANape可用A2L文件',CANapeFileName,'生成成功！！！','=======']);
        end

        if GenINCAFlg == 1
            CalFlash = @( name )CalFlash_getSymbolValForName( name );
            CalFlashA2LText = regexprep( a2lText, [ addrPrefix, '(\w+)', addrSuffix ],'0x${CalFlash($1)}' );
            INCAFileName = [GenA2LName,'_INCA.a2l'];
            INCAfid = fopen([A2L_Path,INCAFileName], 'w+','n','GB2312');
            fprintf( INCAfid, '%s',CalFlashA2LText );
            fclose('all');
            
            ASAP2_Standardize(A2L_Path,INCAFileName,ECUIDWtire);
            UpdateInfoList(['=======INCA可用A2L文件',INCAFileName,'生成成功！！！','=======']);
        end
        winopen(A2L_Path);       %打开文件路径

        
    end
    
    function hexaddr = loc_getSymbolValForName( name )
        try 
            hexaddr = rtw.esa.ESA.getSymbolValForName( symtab, name );
            hexaddr = [ hexaddr,' /* @ECU_Address@', name, '@ */' ];
        catch 
            hexaddr = [ '0000 /* @ECU_Address@', name, '@ */' ];
            warning( 'RTW:asap2:NoSymbolInTable', name );
        end 
    end

    function hexaddr = CalFlash_getSymbolValForName( name )
        try 
            hexaddr = rtw.esa.ESA.getSymbolValForName( symtab, name );
            pairs = regexp(hexaddr, '4005[A-Fa-F0-9]{4}','match');
            if ~isempty(pairs)
                hexAddr = pairs{1,1};
                RamAddrStart = '40050000';
                FlashAddrStart = '808000';
                AddrChg = dec2hex(hex2dec(hexAddr)+hex2dec(FlashAddrStart)-hex2dec(RamAddrStart));
                hexaddr = AddrChg;
            end
            hexaddr = [ hexaddr,' /* @ECU_Address@', name, '@ */' ];
        catch
            hexaddr = [ '0000 /* @ECU_Address@', name, '@ */' ];
            warning( 'RTW:asap2:NoSymbolInTable', name );
        end 
    end 
end

function ASAP2_Standardize(A2LPath,A2LName,ECUIDContent)
    
    OriginalFileId = fopen([A2LPath,A2LName], 'r');
    %文件打开失败时提示并退出脚本
    if OriginalFileId == -1
        warndlg(sprintf('a2l文件打开失败，INCA A2L文件生成已退出！！！'),'提示');
        fclose('all');
        return;
    else

     % 读取原a2l文件中所有信息
        FileContent = fread(OriginalFileId, '*char');
        FileContent = FileContent';   

        % 获取文件头
        Header_exp = '.*/end *HEADER';
        Header = regexp(FileContent, Header_exp, 'match');
        %获取变量信息相关内容
        Useful_exp = '/begin *RECORD_LAYOUT.+?[\r\n]+(.*)/end *PROJECT';
        UsefulContent = regexp(FileContent, Useful_exp, 'match');

        if isempty(Header)||isempty(UsefulContent)
            fclose('all');
            warndlg(sprintf('原a2l文件信息缺失，未执行a2l文件生成操作！！！'),'提示');
            return;
        else
            %标准协议中必须的相关信息
            eol = '\r\n';
            A2ML_content = [sprintf('    /begin A2ML') eol];
            A2ML_content = [A2ML_content eol];
            A2ML_content = [A2ML_content sprintf('      block "IF_DATA" taggedunion if_data {') eol];
            A2ML_content = [A2ML_content eol];
            A2ML_content = [A2ML_content sprintf('        "CANAPE_EXT" struct {') eol];
            A2ML_content = [A2ML_content sprintf('          int;             /* version number */') eol];
            A2ML_content = [A2ML_content sprintf('          taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('            "LINK_MAP" struct {') eol];
            A2ML_content = [A2ML_content sprintf('              char[256];   /* segment name */') eol];
            A2ML_content = [A2ML_content sprintf('              long;        /* base address of the segment */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* address extension of the segment */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* flag: address is relative to DS */') eol];
            A2ML_content = [A2ML_content sprintf('              long;        /* offset of the segment address */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* datatypValid */') eol]; 
            A2ML_content = [A2ML_content sprintf('              uint;        /* enum datatyp */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* bit offset of the segment */') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('            "DISPLAY" struct {') eol];
            A2ML_content = [A2ML_content sprintf('              long;        /* display color */') eol];
            A2ML_content = [A2ML_content sprintf('              double;      /* minimal display value (phys)*/') eol];
            A2ML_content = [A2ML_content sprintf('              double;      /* maximal display value (phys)*/') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('            "VIRTUAL_CONVERSION" struct {') eol];
            A2ML_content = [A2ML_content sprintf('              char[256];   /* name of the conversion formula */') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          };') eol];
            A2ML_content = [A2ML_content sprintf('        };') eol];
            A2ML_content = [A2ML_content sprintf('        "CANAPE_MODULE" struct {') eol];
            A2ML_content = [A2ML_content sprintf('          taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('            ("RECORD_LAYOUT_STEPSIZE" struct {') eol];
            A2ML_content = [A2ML_content sprintf('              char[256];   /* name of record layout*/') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for FNC_VALUES */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for AXIS_PTS_X */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for AXIS_PTS_Y */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for AXIS_PTS_Z */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for AXIS_PTS_4 */') eol];
            A2ML_content = [A2ML_content sprintf('              uint;        /* stepsize for AXIS_PTS_5 */') eol];
            A2ML_content = [A2ML_content sprintf('            })*;') eol];
            A2ML_content = [A2ML_content sprintf('          };') eol];
            A2ML_content = [A2ML_content sprintf('        };') eol];
            A2ML_content = [A2ML_content sprintf('        "CANAPE_GROUP" taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('          block "STRUCTURE_LIST" (char[1024])*;') eol];
            A2ML_content = [A2ML_content sprintf('        };') eol];
            A2ML_content = [A2ML_content eol];
            A2ML_content = [A2ML_content sprintf('        "ASAP1B_CCP" taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('          (block "SOURCE" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            struct {') eol];
            A2ML_content = [A2ML_content sprintf('              char[101];  /* Name of the DAQ-List (data acquisition list), measurement source*/') eol];
            A2ML_content = [A2ML_content sprintf('              int;  /* Period definition : Basic scaling unit in CSE*/') eol];
            A2ML_content = [A2ML_content sprintf('              long;  /* Period definition : Rate in Scaling Units*/') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('            taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('              "DISPLAY_IDENTIFIER" char[32];') eol];
            A2ML_content = [A2ML_content sprintf('              block "QP_BLOB" struct {') eol];
            A2ML_content = [A2ML_content sprintf('                uint;  /* Number of the DAQ-List 0..n*/') eol];
            A2ML_content = [A2ML_content sprintf('                taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('                  "LENGTH" uint;  /* Length of the DAQ-Liste, maximum number of the useable ODTs*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "CAN_ID_VARIABLE" ;  /* CAN-Message-ID is variable*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "CAN_ID_FIXED" ulong;  /* CAN-Message-ID of the DTOs if fixed*/') eol];
            A2ML_content = [A2ML_content sprintf('                  ("RASTER" uchar)*;  /* Supported CCP Event Channel Names of this DAQ List*/') eol];
            A2ML_content = [A2ML_content sprintf('                  ("EXCLUSIVE" int)*;  /* Exclusion of other DAQ-Lists*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "REDUCTION_ALLOWED" ;  /* Data reduction possible*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "FIRST_PID" uchar;  /* First Packet ID (PID) of the DAQ List*/') eol];
            A2ML_content = [A2ML_content sprintf('                };') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          })*;') eol];
            A2ML_content = [A2ML_content sprintf('          (block "RASTER" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            char[101];  /* CCP Event Channel Name*/') eol];
            A2ML_content = [A2ML_content sprintf('            char[9];  /* Short Display Name of the Event Channel Name*/') eol];
            A2ML_content = [A2ML_content sprintf('            uchar;  /* Event Channel No., used for CCP START_STOP)*/') eol];
            A2ML_content = [A2ML_content sprintf('            int;  /* Period definition :  basic scaling unit in CSE as defined in ASAP1b*/') eol];
            A2ML_content = [A2ML_content sprintf('            long;  /* ECU sample rate of the event channel*/') eol];
            A2ML_content = [A2ML_content sprintf('            taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('              ("EXCLUSIVE" uchar)*;  /* Exclusion of other CCP Event Channels*/') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          })*;') eol];
            A2ML_content = [A2ML_content sprintf('          (block "EVENT_GROUP" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            char[101];  /* Event group name*/') eol];
            A2ML_content = [A2ML_content sprintf('            char[9];  /* Short name for the event group*/') eol];
            A2ML_content = [A2ML_content sprintf('            taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('              ("RASTER" uchar)*;') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          })*;') eol];
            A2ML_content = [A2ML_content sprintf('          block "SEED_KEY" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            char[256];  /* Name of the Seed&Key DLL for CAL Priviledge, including file-Extension without path*/') eol];
            A2ML_content = [A2ML_content sprintf('            char[256];  /* Name of the Seed&Key DLL for DAQ Priviledge, including file-Extension without path*/') eol];
            A2ML_content = [A2ML_content sprintf('            char[256];  /* Name of the Seed&Key DLL for PGM Priviledge, including file-Extension without path*/') eol];
            A2ML_content = [A2ML_content sprintf('          };') eol];
            A2ML_content = [A2ML_content sprintf('          block "CHECKSUM" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            char[256];  /* Name of the Checksum DLL representing the ECU Algorithm, including file-Extension without path*/') eol];
            A2ML_content = [A2ML_content sprintf('          };') eol];
            A2ML_content = [A2ML_content sprintf('          block "TP_BLOB" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* CCP Version, High Byte: Version, Low Byte : subversion (dec.)*/') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* Blob-Version, High Byte: Version, Low Byte : subversion (dec.)*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* CAN-Message ID for ''Transmitting to ECU (CRM)''*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* CAN-Message ID for ''Receiving from ECU (DTM)''*/') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* Logical CCP-Address of the (station address)*/') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* Byte order of Multiple-byte-items 1 = high Byte first, 2 = low byte first*/') eol];
            A2ML_content = [A2ML_content sprintf('            taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('              block "CAN_PARAM" struct {') eol];
            A2ML_content = [A2ML_content sprintf('                uint;  /* Quartz freq. of the elec. control unit */') eol];
            A2ML_content = [A2ML_content sprintf('                uchar;  /* BTR0*/') eol];
            A2ML_content = [A2ML_content sprintf('                uchar;  /* BTR1*/') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              "BAUDRATE" ulong;  /* Baud rate in Hz.*/') eol];
            A2ML_content = [A2ML_content sprintf('              "SAMPLE_POINT" uchar;  /* sampling point of time in percent*/') eol];
            A2ML_content = [A2ML_content sprintf('              "SAMPLE_RATE" uchar;  /* number of samples per Bit (1 oder 3)*/') eol];
            A2ML_content = [A2ML_content sprintf('              "BTL_CYCLES" uchar;  /* number of BTL-cycles*/') eol];
            A2ML_content = [A2ML_content sprintf('              "SJW" uchar;  /* SJW-parameter in BTL-cycles*/') eol];
            A2ML_content = [A2ML_content sprintf('              "SYNC_EDGE" enum {') eol];
            A2ML_content = [A2ML_content sprintf('                "SINGLE" = 0,') eol];
            A2ML_content = [A2ML_content sprintf('                "DUAL" = 1') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              "DAQ_MODE" enum {') eol];
            A2ML_content = [A2ML_content sprintf('                "ALTERNATING" = 0,') eol];
            A2ML_content = [A2ML_content sprintf('                "BURST" = 1') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              "BYTES_ONLY" ;  /* ECU supports max. elements of one Byte size otherwise ECU supports different dataTypes*/') eol];
            A2ML_content = [A2ML_content sprintf('              "RESUME_SUPPORTED" ;  /* ECU supports the Resume function*/') eol];
            A2ML_content = [A2ML_content sprintf('              "STORE_SUPPORTED" ;  /* ECU supports the Store function*/') eol];
            A2ML_content = [A2ML_content sprintf('              "CONSISTENCY" enum {') eol];
            A2ML_content = [A2ML_content sprintf('                "DAQ" = 0,') eol];
            A2ML_content = [A2ML_content sprintf('                "ODT" = 1') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              "ADDRESS_EXTENSION" enum {') eol];
            A2ML_content = [A2ML_content sprintf('                "DAQ" = 0,') eol];
            A2ML_content = [A2ML_content sprintf('                "ODT" = 1') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              block "CHECKSUM_PARAM" struct {') eol];
            A2ML_content = [A2ML_content sprintf('                uint;  /* checksum calculation procedure standard types not yet defined, if greater of equal 1000 : manufacturer specific */') eol];
            A2ML_content = [A2ML_content sprintf('                ulong;  /* Maximum block length used by an ASAP1a-CCP command, for checksum calculation procedure */') eol];
            A2ML_content = [A2ML_content sprintf('                taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('                  "CHECKSUM_CALCULATION" enum {') eol];
            A2ML_content = [A2ML_content sprintf('                    "ACTIVE_PAGE" = 0,') eol];
            A2ML_content = [A2ML_content sprintf('                    "BIT_OR_WITH_OPT_PAGE" = 1') eol];
            A2ML_content = [A2ML_content sprintf('                  };') eol];
            A2ML_content = [A2ML_content sprintf('                };') eol];
            A2ML_content = [A2ML_content sprintf('              };') eol];
            A2ML_content = [A2ML_content sprintf('              (block "DEFINED_PAGES" struct {') eol];
            A2ML_content = [A2ML_content sprintf('                struct {') eol];
            A2ML_content = [A2ML_content sprintf('                  uint;  /* Logical No. of the memory page (1,2,..)*/') eol];
            A2ML_content = [A2ML_content sprintf('                  char[101];  /* Name of the memory page*/') eol];
            A2ML_content = [A2ML_content sprintf('                  uint;  /* Adress-Extension of the memory page (only Low Byte significant)*/') eol];
            A2ML_content = [A2ML_content sprintf('                  ulong;  /* Base address of the memory page*/') eol];
            A2ML_content = [A2ML_content sprintf('                  ulong;  /* Length of the memory page in Bytes*/') eol];
            A2ML_content = [A2ML_content sprintf('                };') eol];
            A2ML_content = [A2ML_content sprintf('                taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('                  "RAM" ;  /* memory page in RAM*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "ROM" ;  /* memory page in ROM*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "FLASH" ;  /* memory page in FLASH*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "EEPROM" ;  /* memory page in EEPROM*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "RAM_INIT_BY_ECU" ;  /* memory page is initialised by ECU start-up*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "RAM_INIT_BY_TOOL" ;  /* RAM- memory page is initialised by the MCS*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "AUTO_FLASH_BACK" ;  /* RAM memory page is automatically flashed back*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "FLASH_BACK" ;  /* feature available to flash back the RAM memory page*/') eol];
            A2ML_content = [A2ML_content sprintf('                  "DEFAULT" ;  /* memory page is standard (fallback mode)*/') eol];
            A2ML_content = [A2ML_content sprintf('                };') eol];
            A2ML_content = [A2ML_content sprintf('              })*;') eol];
            A2ML_content = [A2ML_content sprintf('              ("OPTIONAL_CMD" uint)*;  /* CCP-Code of the optional command available*/') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          };') eol];
            A2ML_content = [A2ML_content sprintf('          ("ADDR_MAPPING" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* from*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* to*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* length*/') eol];
            A2ML_content = [A2ML_content sprintf('          })*;') eol];
            A2ML_content = [A2ML_content sprintf('          "DP_BLOB" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* Address extension of the calibration data (only Low Byte significant)*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* Base address of the calibration data*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* Number of Bytes belonging to the calibration data */') eol];
            A2ML_content = [A2ML_content sprintf('          };  /* for CHARACTERISTIC and AXIS_PTS and MEMORY_LAYOUT*/') eol];
            A2ML_content = [A2ML_content sprintf('          "KP_BLOB" struct {') eol];
            A2ML_content = [A2ML_content sprintf('            uint;  /* Address extension of the online data (only Low Byte significant)*/') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* Base address of the online data  */') eol];
            A2ML_content = [A2ML_content sprintf('            ulong;  /* Number of Bytes belonging to the online data (1,2 or 4)*/') eol];
            A2ML_content = [A2ML_content sprintf('            taggedstruct {') eol];
            A2ML_content = [A2ML_content sprintf('              ("RASTER" uchar)*;  /* Array of event channel initialization values*/') eol];
            A2ML_content = [A2ML_content sprintf('            };') eol];
            A2ML_content = [A2ML_content sprintf('          };  /* for MEASUREMENT*/') eol];
            A2ML_content = [A2ML_content sprintf('        };') eol];
            A2ML_content = [A2ML_content sprintf('      };') eol];
            A2ML_content = [A2ML_content sprintf('    /end A2ML') eol];
            
            MOD_COMMON_content = [sprintf('    /begin MOD_COMMON "Mod Common Comment Here"') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      BYTE_ORDER MSB_FIRST') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_BYTE 1') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_WORD 2') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_LONG 4') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_INT64 4') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_FLOAT32_IEEE 4') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('      ALIGNMENT_FLOAT64_IEEE 4') eol];
            MOD_COMMON_content = [MOD_COMMON_content sprintf('    /end MOD_COMMON') eol];
            
            % 10ms CH2
            EventCh_content = [sprintf('        /begin SOURCE') eol];
            EventCh_content = [EventCh_content sprintf('            "10ms"                              /* Name of the DAQ list */') eol];
            EventCh_content = [EventCh_content sprintf('            3                                   /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            10                                  /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('            DISPLAY_IDENTIFIER "10ms"           /* Display identifier */') eol];
            EventCh_content = [EventCh_content sprintf('            /begin QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('                2                               /* Number of the DAQ-List 0..n */') eol];
            EventCh_content = [EventCh_content sprintf('                LENGTH              30          /* Length of the DAQ-List, maximum number of the useable ODTs */') eol];
            EventCh_content = [EventCh_content sprintf('                CAN_ID_FIXED        0x80000101  /* CAN-Message-ID of the DTOs is fixed,Default DTO.Bit31 0: standard ID 1: extended ID */') eol];
            EventCh_content = [EventCh_content sprintf('                RASTER              2           /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('                REDUCTION_ALLOWED               /* Data reduction possible */') eol];
            EventCh_content = [EventCh_content sprintf('                FIRST_PID           60          /* First Packet ID (PID) of the DAQ List */') eol];
            EventCh_content = [EventCh_content sprintf('            /end QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('        /end SOURCE') eol];
            EventCh_content = [EventCh_content eol];
			
            % 20ms CH3
            EventCh_content = [EventCh_content sprintf('        /begin SOURCE') eol];
			EventCh_content = [EventCh_content sprintf('            "20ms"                              /* Name of the DAQ list */') eol];
            EventCh_content = [EventCh_content sprintf('            3                                   /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            20                                  /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('            DISPLAY_IDENTIFIER "20ms"           /* Display identifier */') eol];
            EventCh_content = [EventCh_content sprintf('            /begin QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('                3                               /* Number of the DAQ-List 0..n */') eol];
            EventCh_content = [EventCh_content sprintf('                LENGTH              30          /* Length of the DAQ-List, maximum number of the useable ODTs */') eol];
            EventCh_content = [EventCh_content sprintf('                CAN_ID_FIXED        0x80000101  /* CAN-Message-ID of the DTOs is fixed,Default DTO.Bit31 0: standard ID 1: extended ID */') eol];
            EventCh_content = [EventCh_content sprintf('                RASTER              3           /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('                REDUCTION_ALLOWED               /* Data reduction possible */') eol];
            EventCh_content = [EventCh_content sprintf('                FIRST_PID           90          /* First Packet ID (PID) of the DAQ List */') eol];
            EventCh_content = [EventCh_content sprintf('            /end QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('        /end SOURCE') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 100ms CH4
			EventCh_content = [EventCh_content sprintf('        /begin SOURCE') eol];
			EventCh_content = [EventCh_content sprintf('            "100ms"                             /* Name of the DAQ list */') eol];
            EventCh_content = [EventCh_content sprintf('            3                                   /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            100                                 /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('            DISPLAY_IDENTIFIER "100ms"          /* Display identifier */') eol];
            EventCh_content = [EventCh_content sprintf('            /begin QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('                4                               /* Number of the DAQ-List 0..n */') eol];
            EventCh_content = [EventCh_content sprintf('                LENGTH              30          /* Length of the DAQ-List, maximum number of the useable ODTs */') eol];
            EventCh_content = [EventCh_content sprintf('                CAN_ID_FIXED        0x80000101  /* CAN-Message-ID of the DTOs is fixed,Default DTO.Bit31 0: standard ID 1: extended ID */') eol];
            EventCh_content = [EventCh_content sprintf('                RASTER              4           /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('                REDUCTION_ALLOWED               /* Data reduction possible */') eol];
            EventCh_content = [EventCh_content sprintf('                FIRST_PID           120         /* First Packet ID (PID) of the DAQ List */') eol];
            EventCh_content = [EventCh_content sprintf('            /end QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('        /end SOURCE') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 1000ms CH5
			EventCh_content = [EventCh_content sprintf('        /begin SOURCE') eol];
			EventCh_content = [EventCh_content sprintf('            "1000ms"                            /* Name of the DAQ list */') eol];
            EventCh_content = [EventCh_content sprintf('            3                                   /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            1000                                /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('            DISPLAY_IDENTIFIER "1000ms"         /* Display identifier */') eol];
            EventCh_content = [EventCh_content sprintf('            /begin QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('                5                               /* Number of the DAQ-List 0..n */') eol];
            EventCh_content = [EventCh_content sprintf('                LENGTH              30          /* Length of the DAQ-List, maximum number of the useable ODTs */') eol];
            EventCh_content = [EventCh_content sprintf('                CAN_ID_FIXED        0x80000101  /* CAN-Message-ID of the DTOs is fixed,Default DTO.Bit31 0: standard ID 1: extended ID */') eol];
            EventCh_content = [EventCh_content sprintf('                RASTER              5           /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('                REDUCTION_ALLOWED               /* Data reduction possible */') eol];
            EventCh_content = [EventCh_content sprintf('                FIRST_PID           150         /* First Packet ID (PID) of the DAQ List */') eol];
            EventCh_content = [EventCh_content sprintf('            /end QP_BLOB') eol];
            EventCh_content = [EventCh_content sprintf('        /end SOURCE') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 10ms RASTER
			EventCh_content = [EventCh_content sprintf('        /begin RASTER') eol];
            EventCh_content = [EventCh_content sprintf('            "10ms"     	    /* Name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            "10ms"          /* Short display name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            2               /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            3               /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            10              /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('        /end RASTER') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 20ms RASTER
			EventCh_content = [EventCh_content sprintf('        /begin RASTER') eol];
            EventCh_content = [EventCh_content sprintf('            "20ms"     	    /* Name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            "20ms"          /* Short display name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            3               /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            3               /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            20              /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('        /end RASTER') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 100ms RASTER
			EventCh_content = [EventCh_content sprintf('        /begin RASTER') eol];
            EventCh_content = [EventCh_content sprintf('            "100ms"    	    /* Name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            "100ms"         /* Short display name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            4               /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            3               /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            100             /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('        /end RASTER') eol];
            
            EventCh_content = [EventCh_content eol];
            
            % 100ms RASTER
			EventCh_content = [EventCh_content sprintf('        /begin RASTER') eol];
            EventCh_content = [EventCh_content sprintf('            "1000ms"   	    /* Name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            "1000ms"        /* Short display name of the ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            5               /* Number of ECU-event channel */') eol];
            EventCh_content = [EventCh_content sprintf('            3               /* Basic scaling unit. 0:1us 1:10us 2:100us 3:1ms 4:10ms 5:100ms 6:1s */') eol];
            EventCh_content = [EventCh_content sprintf('            1000            /* Sample rate of the ECU-event channel,base on the scaling unit */') eol];
            EventCh_content = [EventCh_content sprintf('        /end RASTER') eol];
		
            % SEED_KEY_Content
            SEED_KEY_content = [sprintf('        /begin SEED_KEY') eol];
            SEED_KEY_content = [SEED_KEY_content sprintf('            /* seed&key dll for CAL */ ""') eol];
            SEED_KEY_content = [SEED_KEY_content sprintf('            /* seed&key dll for DAQ */ ""') eol];
            SEED_KEY_content = [SEED_KEY_content sprintf('            /* seed&key dll for PGM */ ""') eol];
            SEED_KEY_content = [SEED_KEY_content sprintf('            /end SEED_KEY') eol];
            
            % TP_BLOB_content
            TP_BLOB_content = [sprintf('        /begin TP_BLOB') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            0x201                   /* CCP version */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            0x204                   /* Blob version */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            0x80000100              /* CAN message ID,Transmitting to ECU,Bit31 0: standard ID 1: extended ID */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            0x80000101              /* CAN message ID,Receiving from ECU,Bit31 0: standard ID 1: extended ID */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf(strcat(['            ',ECUIDContent])) eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            1                       /* Byte order,1:Motorola,2:Intel */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            BAUDRATE 500000         /* Baud rate */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            SAMPLE_POINT 75         /* Sampling point of time in percent */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            SAMPLE_RATE 1           /* Number of samples per Bit */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            BTL_CYCLES 10           /* Number of BTL-cycles */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            SJW      2              /* SJW-parameter in BTL-cycles */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            SYNC_EDGE  SINGLE       /* Synchronisation,SINGLE:falling edge,DUAL:falling and rising edge */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            DAQ_MODE  BURST         /* Mode of cylcic data acquisition,ALTERNATING:ECU is sending one ODT per cycle,BURST:ECU is sending a complete DAQ */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            CONSISTENCY  ODT        /* DAQ or ODT*/') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            ADDRESS_EXTENSION  DAQ  /* DAQ or ODT */') eol];
            
            % TP_BLOB_content
            TP_BLOB_content = [TP_BLOB_content sprintf('            /begin CHECKSUM_PARAM') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x8006                              /* Checksum Algorithm, (16 bit) CRC-CCITT */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0xFFFFFFFF                          /* Limit,maximum block length used by an ASAP1a-CCP command,for checksum calculation procedure */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                CHECKSUM_CALCULATION ACTIVE_PAGE    /* Calculation,ACTIVE_PAGE or BIT_OR_WITH_OPT_PAGE*/') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            /end CHECKSUM_PARAM') eol];
            TP_BLOB_content = [TP_BLOB_content eol];
            
            TP_BLOB_content = [TP_BLOB_content sprintf('            /begin DEFINED_PAGES') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                1                                          /* Logical number of memory page(1,2..) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                "Working Page"                             /* Name of memory page */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x00                                       /* Adress-Extension of the memory page (only Low Byte significant) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x40050000                                 /* Base address of the memory page */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x00010000                                 /* Length of the memory page(Memory size) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                RAM                                        /* Memory page in RAM */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                RAM_INIT_BY_ECU                            /* Memory page is initialised by ECU start-up */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            /end DEFINED_PAGES') eol];
            TP_BLOB_content = [TP_BLOB_content eol];
            
            TP_BLOB_content = [TP_BLOB_content sprintf('            /begin DEFINED_PAGES') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                2                                          /* Logical number of memory page(1,2..) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                "Reference Page"                           /* Name of memory page */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x00                                       /* Adress-Extension of the memory page (only Low Byte significant) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x00808000                                 /* Base address of the memory page */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                0x00010000                                 /* Length of the memory page(Memory size) */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('                FLASH                                      /* Memory page in FLASH */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            /end DEFINED_PAGES') eol];
		    TP_BLOB_content = [TP_BLOB_content eol];
            
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x08   /* START_STOP_ALL */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x09   /* GET_ACTIVE_CAL_PAGE */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x0C   /* CCP_SET_S_STATUS */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x0D   /* CCP_GET_S_STATUS */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x0E   /* CCP_BUILD_CHKSUM */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x11   /* CCP_SEL_CAL_PAGE */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x18   /* CCP_PROGRAM */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('            OPTIONAL_CMD 0x22   /* CCP_PROGRAM6 */') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('        /end TP_BLOB') eol];
            TP_BLOB_content = [TP_BLOB_content sprintf('    /end IF_DATA') eol];

            % MOD_PAR_content
            MOD_PAR_content = [sprintf('    /begin MOD_PAR "MOD PAR Comment Goes Here"') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('        /begin MEMORY_SEGMENT') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            Variables               /* Element name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            "Measurement_RAM"       /* Long name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            VARIABLES               /* Program type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            RAM                     /* Memory type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            INTERN                  /* Attribute */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x40000000              /* Address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x00050000              /* Size */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            -1 -1 -1 -1 -1          /* Offset */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('        /end MEMORY_SEGMENT') eol];
            
            MOD_PAR_content = [MOD_PAR_content eol];
            
            MOD_PAR_content = [MOD_PAR_content sprintf('        /begin MEMORY_SEGMENT') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            WorkingPage			/* Element name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            "Calibration_RAM" 	/* Long name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            DATA 				/* Program type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            RAM 				/* Memory type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            INTERN 				/* Attribute */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x40050000 			/* Address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x00010000 			/* Size */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            -1 -1 -1 -1 -1		/* Offset */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('        /end MEMORY_SEGMENT') eol];
            
            MOD_PAR_content = [MOD_PAR_content eol];
            
            MOD_PAR_content = [MOD_PAR_content sprintf('        /begin MEMORY_SEGMENT') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            CAL					/* Element name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            "Calibration_ROM"   /* Long name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            DATA 				/* Program type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            FLASH 				/* Memory type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            INTERN 				/* Attribute */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x00808000 			/* Address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x00010000 			/* Size */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            -1 -1 -1 -1 -1		/* Offset */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            /begin IF_DATA ASAP1B_CCP') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('                ADDR_MAPPING') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('                0x00808000		/* Original address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('                0x40050000		/* Mapping address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('                0x00010000		/* Size */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            /end IF_DATA') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('        /end MEMORY_SEGMENT') eol];
            
            MOD_PAR_content = [MOD_PAR_content eol];
            
            MOD_PAR_content = [MOD_PAR_content sprintf('        /begin MEMORY_SEGMENT') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            APP					/* Element name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            "APP Code" 			/* Long name */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            CODE 				/* Program type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            FLASH 				/* Memory type */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            INTERN 				/* Attribute */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x01000000 			/* Address */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            0x00100000 			/* Size */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('            -1 -1 -1 -1 -1		/* Offset */') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('        /end MEMORY_SEGMENT') eol];
            MOD_PAR_content = [MOD_PAR_content sprintf('    /end MOD_PAR') eol];
 
            %生成新的a2l文件
            OutputFileId = fopen([A2LPath,A2LName], 'w');
            if OutputFileId == -1
                fclose('all');
                warndlg(sprintf('无法打开目标a2l文件，生成失败，请重新执行操作！！！'),'提示');
                return;
            else
                fprintf(OutputFileId, '%s', Header{1});
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, '%s', '  /begin MODULE ModuleName "Module Comment Goes Here"');   
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, A2ML_content);   %A2ML
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, MOD_COMMON_content);   %MOD_COMMON
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, '%s', '    /begin IF_DATA ASAP1B_CCP');   
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, EventCh_content);
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, SEED_KEY_content);
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, TP_BLOB_content);   %CHECKSUM_PARAM & DEFINED_PAGES
                fprintf(OutputFileId, '\r\n');
                fprintf(OutputFileId, MOD_PAR_content);   %MOD_PAR
                fprintf(OutputFileId, '\r\n\t');
                fprintf(OutputFileId, '%s', UsefulContent{1});
                fclose('all');
            end
        end
    end
end