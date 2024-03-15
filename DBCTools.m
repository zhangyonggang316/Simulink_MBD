%-------------------------------------------------------------------------------------------
%Author  : FanYANG
%version : V2.1.3
%Modofy date:   2021/07/26  杨  帆    建立文件，释放首版功能
%               2022/03/11  许鸿江    文件过滤器增加.xls,按照新定义标准模板修改生成语句
%               2022/03/14  许鸿江    将文件改为function，以便自动清除中间过程产生变量，
%                                    将生成dbc逻辑独立整理至新的function中，以便同一个
%                                    excel文件不同工作表对应不同的DBC生成
%               2022/03/21  许鸿江    将表名改成变量，可以自行修改
%               2022/03/24  许鸿江    修复获取xlsinfo获取表名时无路径导致不在一目录下失败问题
%               2022/03/25  许鸿江    1、修复excel表格数据读取列超界问题
%                                     2、增加部分强制数值单元格的格式判定，避免出现空格或换挡符
%                                        导致生成文件语法错误问题
%                                     3、增加报文注释的内容写入
%               2022/03/25   许鸿江   1、增加信号名重复定义检查功能
%               2022/04/11   许鸿江   1、去除信号起始位与发送类型限制，生成时不检测此两处填写内容
%               2022/07/09   许鸿江   1、增加发送周期信息写入
%               2022/08/18   许鸿江   1、补充初始值定义生成
%               2022/09/27   许鸿江   1、修改文本格式，解决UNIX格式INCA无法读取问题，
%                                        改成Windows/DOS文件格式
%               2022/09/29   许鸿江   1、修复IfActive时，报文周期误填非数字问题
%               2022/09/29   许鸿江   1、修复各字符中包含符号"%"时，误被matlab注释问题
%               2022/09/29   许鸿江   1、修复Motorola LSB字节顺序格式信号起始位设定错误问题
%               2022/10/02   许鸿江   1、修复Motorrola LSB字节顺序，信号跨字节起始位设定错误问题
%               2022/10/11   许鸿江   1、生成矩阵选择方式修改为弹窗列表选择，以供后续更多矩阵同时生成
%                                     2、文件及函数名由Excel2DBC_Coverter改为Excel2DBC
%               2022/11/08   许鸿江   1、修改为fig窗口方式操作
%                                     2、增加集合生成方式，用于多个表格生成一个DBC
%                                     3、增加ValueTable是否生成选择，临时用于解决INCA7.3中文VT
%                                        时可观测不可记录问题
%               2022/11/14   许鸿江   1、修复不同工作表有重复信号无法报错问题
%               2022/11/23   许鸿江   1、简化文件需求，改成脚本直接生成弹窗方式
%                                     2、增加dbc转换成xls模式，有Tab切换，预留
%               2022/12/01   许鸿江   1、文件更名为DBCTools.m
%               2022/12/09   许鸿江   1、加入DBC转换成excel矩阵功能，
%               2022/12/19   许鸿江   1、修复信号值描述数字与分割符号中间有空格符导致生成DBC不含VT问题
%                                     2、部分excel单元格添加数据有效性内容
%               2022/12/20   许鸿江   1、适配WPS建立excel文件
%                                     2、表格宽度设置方式改为单独设置，适配WPS格式
%                                     3、加入信号接收节点定义
%                                     4、关闭无效值内容填写
%               2023/03/16   许鸿江   1、修复值描述处十进制意外使用十六进制转换问题
%-------------------------------------------------------------------------------------------
function DBCTools
    clear
    warning off
    VersionStr = 'V2.1.2';
    global GUI_DBCTool
    global GUI_DataTemp;
    global GUI_XlsDataTemp
    GUI_DataTemp = {};
    GUI_XlsDataTemp = {};
    try 
        close( GUI_DBCTool.FigHndl )
    catch 
    end 
    
    StrTemp = 'DBC工具';
    GUI_DBCTool.FigHndl = figure( 'units', 'pixels',  ...
                                'Position', [ 340, 170, 650, 520 ],  ...
                                'menubar', 'none',  ...
                                'name', StrTemp,  ...
                                'numbertitle', 'off',  ...
                                'resize', 'off' );
                                    
    set( GUI_DBCTool.FigHndl, 'CloseRequestFcn', @CloseGuiFcn )
                                 
    GUI_DBCTool.TitleTxt = uicontrol( 'Parent', GUI_DBCTool.FigHndl,  ...
                                        'Style', 'text',  ...
                                        'Position', [ 90, 470, 440, 40 ],  ...
                                        'FontSize',16,...
                                        'String', '皓耘科技整机控制开发部DBC工具');

    GUI_DBCTool.VersionTxt = uicontrol('Parent', GUI_DBCTool.FigHndl,...
                                        'Style', 'text',...
                                        'Position', [ 530, 470, 80, 36 ],  ...
                                        'FontSize',14,...
                                        'String', VersionStr);
    % 设计panel                                
    GUI_DBCTool.FuncFig = uipanel( 'Parent', GUI_DBCTool.FigHndl, 'units', 'pixels',  ...
                                   'Title', char( [  ] ), 'Position', [ 0, 0, 650, 480 ], 'Visible', 'on' );
    
    % 设计Tab                               
    TabId = uitabgroup( GUI_DBCTool.FuncFig, 'Position', [ 0, 0, 1, 1 ] );
    StrTemp = 'excel2dbc';
    GenDbcTab = uitab( TabId, 'Title', StrTemp );
    StrTemp = 'dbc2excel';
    GenFileTab = uitab( TabId, 'Title', StrTemp );
    
    % Tab xls2dbc
    GUI_DBCTool.PathTxt = uicontrol('Parent', GenDbcTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 395, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', 'Excel路径：');
    
    GUI_DBCTool.PathStr = uicontrol('Parent', GenDbcTab,...
                                    'Style', 'edit',...
                                    'Position', [ 100, 390, 430, 50 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '',...
                                    'Max',2,...
                                    'Enable','off');
    
    GUI_DBCTool.FileSelBtn = uicontrol('Parent', GenDbcTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 345, 80, 95 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '文件选择',  ...
                                       'Callback', @FileSel_Callback);

    GUI_DBCTool.DBCNameTxt = uicontrol('Parent', GenDbcTab, 'Style', 'text',...
                                        'Position', [ 10, 345, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', 'DBC名称：');

    GUI_DBCTool.DBCNameStr = uicontrol('Parent', GenDbcTab,...
                                       'Style', 'edit',...
                                       'Position', [ 100, 345, 430, 30 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','left',...
                                       'String', 'CAN_Matrix');

    GUI_DBCTool.SheetNameTxt = uicontrol('Parent', GenDbcTab,...
                                         'Style', 'text',...
                                         'Position', [ 10, 285, 90, 40 ],  ...
                                         'FontSize',12,...
                                         'HorizontalAlignment','left',...
                                         'String', 'Sheet名：');

    GUI_DBCTool.SheetNameList = uicontrol('Parent', GenDbcTab,...
                                          'Style', 'listbox',...
                                          'Position', [ 100, 185, 240, 140 ],  ...
                                          'FontSize',12,...
                                          'HorizontalAlignment','left',...
                                          'String', '');

    GUI_DBCTool.GenStyle = uicontrol('Parent', GenDbcTab,...
                                     'Style', 'popup',...
                                     'Position', [ 370, 275, 140, 50 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', { '单独生成';'集合生成' });

    GUI_DBCTool.ValTableSel = uicontrol('Parent', GenDbcTab,...
                                        'Style', 'popup',...
                                         'Position', [ 370, 225, 140, 50 ],  ...
                                         'FontSize',12,...
                                         'HorizontalAlignment','left',...
                                         'String', { 'GenValTable';'NoValTable' });
                                     
    GUI_DBCTool.ClearListBtn = uicontrol('Parent', GenDbcTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 370, 185, 140, 40 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '清空提示列表',  ...
                                       'Callback', @ClearList_Callback);
                                   
   GUI_DBCTool.GenDbcBtn = uicontrol('Parent', GenDbcTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 205, 80, 120 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '生成DBC',  ...
                                       'Callback', @GenDBC_Callback);
   
    GUI_DBCTool.InfoTxt = uicontrol('Parent', GenDbcTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 120, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '信息提示：');

    GUI_DBCTool.InfoList = uicontrol('Parent', GenDbcTab,...
                                     'Style', 'listbox',...
                                     'Position', [ 100, 20, 530, 140 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', '');
    % Tab dbc2excel
    GUI_DBCTool.DBCPathTxt = uicontrol('Parent', GenFileTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 395, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', 'DBC路径：');
    
    GUI_DBCTool.DBCPathStr = uicontrol('Parent', GenFileTab,...
                                    'Style', 'edit',...
                                    'Position', [ 100, 390, 430, 50 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '',...
                                    'Max',2,...
                                    'Enable','off');
    
    GUI_DBCTool.DBCFileSelBtn = uicontrol('Parent', GenFileTab,...
                                          'Style', 'pushbutton',...
                                          'Position', [ 550, 390, 80, 50 ],  ...
                                          'FontSize',12,...
                                          'HorizontalAlignment','center',...
                                          'String', '文件选择',  ...
                                          'Callback', @DBCFileSel_Callback);

    GUI_DBCTool.ProjectTxt = uicontrol('Parent', GenFileTab, 'Style', 'text',...
                                        'Position', [ 10, 340, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', '项目编号：');

    GUI_DBCTool.ProjectStr = uicontrol('Parent', GenFileTab,...
                                       'Style', 'edit',...
                                       'Position', [ 100, 326, 430, 50 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','left',...
                                       'String', 'HY');
                                   
    GUI_DBCTool.NodChTxt = uicontrol('Parent', GenFileTab, 'Style', 'text',...
                                        'Position', [ 10, 280, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', '节点通道：');

    GUI_DBCTool.NodChStr = uicontrol('Parent', GenFileTab,...
                                       'Style', 'edit',...
                                       'Position', [ 100, 262, 430, 50 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','left',...
                                       'String', 'VCU_CAN0');
                                   
    GUI_DBCTool.GenXlsBtn = uicontrol('Parent', GenFileTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 325, 80, 50 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '生成Excel',  ...
                                       'Callback', @GenXls_Callback);
                                   
    GUI_DBCTool.ClrXlsListBtn = uicontrol('Parent', GenFileTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 262, 80, 50 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '清空提示',  ...
                                       'Callback', @ClrXlsList_Callback);
                                   
    GUI_DBCTool.XlsInfoTxt = uicontrol('Parent', GenFileTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 200, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '信息提示：');

    GUI_DBCTool.XlsInfoList = uicontrol('Parent', GenFileTab,...
                                     'Style', 'listbox',...
                                     'Position', [ 100, 20, 530, 220 ],  ...
                                     'FontSize',12,...
                                     'HorizontalAlignment','left',...
                                     'String', '');
    
%     fJFrame = get( GUI_DBCTool.FigHndl, 'JavaFrame');
%     pause(0.01);
%     fJFrame.fHG2Client.getWindow.setAlwaysOnTop( true );
end

function CloseGuiFcn( ~, ~ )
    global GUI_DBCTool
    try 
        close( GUI_DBCTool.FigHndl )
    catch 
    end 
    closereq
end

function FileSel_Callback(~,~)
    global GUI_DBCTool
    [ExcelName,ExcelPath] =uigetfile({'*.xlsx;*.xls'},'Select the Data Dictionary');
    if ~isequal(ExcelName,0)
        try
            set(GUI_DBCTool.PathStr, 'String', [ExcelPath,ExcelName]);
            set(GUI_DBCTool.PathStr, 'Value', 2);
        catch
            % 暂不做任何事情
        end

        [~,SheetNames] = xlsfinfo([ExcelPath,ExcelName]);
        SheetNames = SheetNames';
        try
            set(GUI_DBCTool.SheetNameList, 'String', SheetNames);
            set(GUI_DBCTool.SheetNameList, 'Max', size(SheetNames,1));
            set(GUI_DBCTool.SheetNameList, 'Value', get(GUI_DBCTool.SheetNameList, 'Max'));
            pause(0.001);
            if get(GUI_DBCTool.SheetNameList, 'Max') > 1
                set(GUI_DBCTool.SheetNameList, 'Value', []);    % 默认加载后不选中
            end
        catch
            % 暂不做任何事情
        end
    else
        UpdateInfoList('未选择文件');
    end
end

function ClearList_Callback(~, ~)
    global GUI_DBCTool
    global GUI_DataTemp
    GUI_DataTemp = {};
    set(GUI_DBCTool.InfoList, 'String', GUI_DataTemp,'Value',1);
end

function GenDBC_Callback(~, ~)
    global GUI_DBCTool
    OpenFolder = 0;
    
    ExcelFileInfo = get(GUI_DBCTool.PathStr, 'String');
    if isempty(ExcelFileInfo)
        UpdateInfoList('Excel文件未定义，生成进程已终止！！！');
        return;
    else
        if contains(ExcelFileInfo,{'.xls','.xlsx'})
            if exist(ExcelFileInfo, 'file')
                backslash = find(ExcelFileInfo == '\', 1, 'last' );
                if isempty(backslash)
                    UpdateInfoList('Excel文件目录异常，生成进程已终止！！！');
                    return;
                else
                    xlsfile_path = ExcelFileInfo(1:backslash);
                    xlsfile_name = ExcelFileInfo(backslash+1:end);
                end
            else
                UpdateInfoList('Excel文件未找到，生成进程已终止！！！');
                return;
            end

        else
            UpdateInfoList('Excel文件未定义，生成进程已终止！！！');
            return;
        end
    end

    [~,SheetNamesChk] = xlsfinfo([xlsfile_path,xlsfile_name]);
    SheetNamesChk = SheetNamesChk';
    SheetNameStr = get(GUI_DBCTool.SheetNameList, 'String');
    if isequal(SheetNamesChk,SheetNameStr)
        SheetSelVal = get(GUI_DBCTool.SheetNameList, 'Value');
        SelSheet = SheetNameStr(SheetSelVal);
    else
        UpdateInfoList('Excel文件定义表名与列表中不一致！！！');
        UpdateInfoList('生成进程已终止！！！');
        set(GUI_DBCTool.SheetNameList, 'String', SheetNamesChk);
        set(GUI_DBCTool.SheetNameList, 'Max', size(SheetNamesChk,1));
        pause(0.001);
        if get(GUI_DBCTool.SheetNameList, 'Max') > 1
                set(GUI_DBCTool.SheetNameList, 'Value', []);    % 默认加载后不选中
        end
        UpdateInfoList('表名已更新，请重新选择！！！');
        return;
    end

    DBCFileName = get(GUI_DBCTool.DBCNameStr, 'String');
    
    %删除输入xx.dbc情况下的后缀
    if numel(DBCFileName) > 4
        if strcmpi('.dbc',DBCFileName(end-3:end))
            DBCFileName = DBCFileName(1:end-4);       
        end
    end

    GenStyleStr = get(GUI_DBCTool.GenStyle, 'String');
    GenStyleVal = get(GUI_DBCTool.GenStyle, 'Value');
    GenStyleStr = GenStyleStr(GenStyleVal);
    GenVTStr = get(GUI_DBCTool.ValTableSel, 'String');
    GenVTVal = get(GUI_DBCTool.ValTableSel, 'Value');
    GenVTStr = GenVTStr(GenVTVal);

    eol = '\n';
    Header_content = [];
    BU_Content = [];
    BO_SG_Content = [];
    CM_BO_SG_Content = [];
    BA_BO_Content = [];
    BA_SG_Content = [];
    VAL_Content = [];
    BA_DEF_Content = [];
    BA_Content = [];
    MsgNode = {};
    if strcmp(GenStyleStr,'单独生成')
        UpdateInfoList('----------------------------------------');
        UpdateInfoList('单独生成模式');
        for Index = 1:numel(SelSheet)
            GenSheetName = SelSheet{Index};
            GenDBCName = strcat(DBCFileName,'_',GenSheetName);
            [ResultFb,CANMsgInfo] = GetCANMsgInfo(xlsfile_path,xlsfile_name,GenSheetName);
            if ResultFb == 1
                ChkResult = MsgInfoCheck(CANMsgInfo);
                if ChkResult == 0
                    UpdateInfoList(['Excel文件： ',xlsfile_path,xlsfile_name,'工作表',GenSheetName,'有重复项，已取消DBC文件生成！！！']);
                    continue;
                end
                [BO_SG_Content,CM_BO_SG_Content,BA_BO_Content,BA_SG_Content,VAL_Content] = SortMsgInfo(CANMsgInfo);
                % 节点信息整理
                MsgNode = CANMsgInfo.Node;
                [Header_content,BU_Content,BA_DEF_Content,BA_Content] = GetCommonInfo(GenDBCName,MsgNode);
                
                % 信息排序整合
                Combine_content = [Header_content BU_Content];
                Combine_content = [Combine_content eol];
                Combine_content = [Combine_content BO_SG_Content];
                Combine_content = [Combine_content eol];
                Combine_content = [Combine_content CM_BO_SG_Content];
                Combine_content = [Combine_content eol];
                Combine_content = [Combine_content BA_DEF_Content];
                Combine_content = [Combine_content BA_Content];
                Combine_content = [Combine_content BA_BO_Content];
                Combine_content = [Combine_content BA_SG_Content];

                if strcmpi(GenVTStr,'GenValTable')
                    Combine_content = [Combine_content eol];
                    Combine_content = [Combine_content VAL_Content];
                    Combine_content = [Combine_content eol];
                end

                % 写DBC文件
                if exist(fullfile(xlsfile_path, [GenDBCName,'.dbc']), 'file')
                    UpdateInfoList(['删除',xlsfile_path,[GenDBCName,'.dbc'],'文件！！！']);
                    delete(fullfile(xlsfile_path, [GenDBCName,'.dbc']));
                end
                filePath = fullfile(xlsfile_path, [GenDBCName,'.dbc']);
                fid = fopen(filePath,'wt+');
                if -1 == fid
                    error('Cannot open the file.');
                end
                fprintf(fid, Combine_content);
                fclose(fid);

                OpenFolder = 1;
                UpdateInfoList(['DBC文件： ',xlsfile_path,GenDBCName,' 已生成！！！']);
            else
                UpdateInfoList(['DBC文件： ',xlsfile_path,GenDBCName,' 生成失败，已终止！！！']);
                continue;      % 有错误继续生成下一工作表
            end
        end
    elseif strcmp(GenStyleStr,'集合生成')
        
        UpdateInfoList('集合生成模式');
        GenDBCName = DBCFileName;
        CombineMsgInfo = {};
        for Index = 1:numel(SelSheet)
            GenSheetName = SelSheet{Index};
            [ResultFb,CANMsgInfo] = GetCANMsgInfo(xlsfile_path,xlsfile_name,GenSheetName);
            if ResultFb == 1
                if ~isfield(CombineMsgInfo,'Node')
                    CombineMsgInfo.Node = CANMsgInfo.Node;
                else
                    for idx = 1:numel(CANMsgInfo.Node)
                        if ~ismember(CANMsgInfo.Node{idx},CombineMsgInfo.Node)
                            CombineMsgInfo.Node{numel(CombineMsgInfo.Node)+1} = CANMsgInfo.Node{idx};
                        end
                    end
                end
                
                if ~isfield(CombineMsgInfo,'MsgList')
                    CombineMsgInfo.MsgList = CANMsgInfo.MsgList;
                else
                    for idx = 1:numel(CANMsgInfo.MsgList)
                        CombineMsgInfo.MsgList(numel(CombineMsgInfo.MsgList)+1) = CANMsgInfo.MsgList(idx);
                    end
                end
                
                UpdateInfoList(['Excel文件： ',xlsfile_path,xlsfile_name,'工作表',GenSheetName,'信息提取完成']);
            else
                UpdateInfoList(['Excel文件： ',xlsfile_path,xlsfile_name,'工作表',GenSheetName,'信息提取异常']);
                UpdateInfoList(['DBC文件： ',xlsfile_path,GenDBCName,' 生成失败，已终止！！！']);
                return;      % 有错误继续生成下一工作表
            end
        end
        
        ChkResult = MsgInfoCheck(CombineMsgInfo);
        
        if ChkResult == 0
            UpdateInfoList(['Excel文件： ',xlsfile_path,xlsfile_name,' 中关键信息ID/信号名有重复项，已取消DBC文件生成！！！']);
            return;
        else
        
            % 节点信息整理
            [Header_content,BU_Content,BA_DEF_Content,BA_Content] = GetCommonInfo(GenDBCName,CombineMsgInfo.Node);
            [BO_SG_Content,CM_BO_SG_Content,BA_BO_Content,BA_SG_Content,VAL_Content] = SortMsgInfo(CombineMsgInfo);

            % 信息排序整合
            Combine_content = [Header_content BU_Content];
            Combine_content = [Combine_content eol];
            Combine_content = [Combine_content BO_SG_Content];
            Combine_content = [Combine_content eol];
            Combine_content = [Combine_content CM_BO_SG_Content];
            Combine_content = [Combine_content eol];
            Combine_content = [Combine_content BA_DEF_Content];
            Combine_content = [Combine_content BA_Content];
            Combine_content = [Combine_content BA_BO_Content];
            Combine_content = [Combine_content BA_SG_Content];

            if strcmpi(GenVTStr,'GenValTable')
                Combine_content = [Combine_content eol];
                Combine_content = [Combine_content VAL_Content];
                Combine_content = [Combine_content eol];
            end

            % 写DBC文件
            if exist(fullfile(xlsfile_path, [GenDBCName,'.dbc']), 'file')
                UpdateInfoList(['删除',xlsfile_path,[GenDBCName,'.dbc'],'文件！！！']);
                delete(fullfile(xlsfile_path, [GenDBCName,'.dbc']));
            end
            filePath = fullfile(xlsfile_path, [GenDBCName,'.dbc']);
            fid = fopen(filePath,'wt+');
            if -1 == fid
                error('Cannot open the file.');
            end
            fprintf(fid, Combine_content);
            fclose(fid);
            OpenFolder = 1;
            UpdateInfoList(['DBC文件： ',xlsfile_path,[GenDBCName,'.dbc'],'已生成！！！']);
        end
    else
        UpdateInfoList('生成模式异常');
        return;
    end

    UpdateInfoList('DBC生成流程已全部完成！！！');
    UpdateInfoList('---------------------------------------------------------');

    if OpenFolder == 1
        winopen(xlsfile_path);      %DBC生成完成后，自动打开路径文件夹
    end
end


function UpdateInfoList(InfoStr)
    global GUI_DBCTool
    global GUI_DataTemp
    
    while 1
        MaxLineCharNum = 52;
        if size(InfoStr,2) > MaxLineCharNum
            StrTemp = InfoStr(1:MaxLineCharNum);
            InfoStr = InfoStr(MaxLineCharNum+1:end);
            if isempty(GUI_DataTemp)
                GUI_DataTemp = {StrTemp};
            else
                GUI_DataTemp = [GUI_DataTemp;StrTemp];
            end
        else
            StrTemp = InfoStr;
            if isempty(GUI_DataTemp)
                GUI_DataTemp = {StrTemp};
            else
                GUI_DataTemp = [GUI_DataTemp;StrTemp];
            end
            break;
        end
    end
    
    set(GUI_DBCTool.InfoList, 'String', GUI_DataTemp);
    set(GUI_DBCTool.InfoList, 'Max', size(GUI_DataTemp,1));
    set(GUI_DBCTool.InfoList, 'Value',get(GUI_DBCTool.InfoList, 'Max'));
    pause(0.001);
%     if get(GUI_DBCTool.InfoList, 'Max') > 1
%         set(GUI_DBCTool.InfoList, 'Value',[]);
%     end
end

% 获取excel表格定义矩阵信息
function [RetResult,MsgInfo,Err_content] = GetCANMsgInfo(FileDir,FileName,GenSheet)
    RetResult = 0;
    CheckPass = 1;
    SameName = 0;
    i = 1;
    j = 1;
    ExcelFile = strcat(FileDir,FileName);
    [~,~,CAN_Matrix_Text] = xlsread(ExcelFile,GenSheet);
    [column_num,row_num] = size(CAN_Matrix_Text);
    
    if column_num < 4   %标准模板中最少4行才可能有信号
        UpdateInfoList(['--文件',FileDir,FileName,'工作表',GenSheet,'中行数太少，可能没有信号定义，请检查！！！']);
        return;
    elseif row_num < 22
        disp(['--文件',FileDir,FileName,'工作表',GenSheet,'中列数太少，可能不是标准矩阵模板格式，请检查！！！']);
        return;
    end
    
    % Excel表格检查，如果第一行与标准模板不一样，直接退出当前生成
    Err_content = '';
    if ~contains(cell2mat(CAN_Matrix_Text(1,1)), {'Msg Name','报文名称'})
        Err_content = [Err_content,'--A列应为报文名称，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,2)), {'Msg Type','报文类型'})
        Err_content = [Err_content,'--B列应为报文类型，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,3)), {'Msg ID(Hex)','报文标识符'})
        Err_content = [Err_content,'--C列应为报文识别符，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,4)), {'Msg Send Type','报文发送类型'})
        Err_content = [Err_content,'--D列应为报文发送类型，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,5)), {'Msg Cycle Time (ms)','报文周期时间'})
        Err_content = [Err_content,'--E列应为报文周期时间，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,6)), {'Msg Length (Byte)','报文长度'})
        Err_content = [Err_content,'--F列应为报文长度，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,7)), {'Signal Name','信号名称'})
        Err_content = [Err_content,'--G列应为信号名称，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,8)), {'Signal Description','信号描述'})
        Err_content = [Err_content,'--H列应为信号描述，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,9)), {'Signal Value Description','信号值描述'})
        Err_content = [Err_content,'--I列应为信号值描述，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,10)), {'Byte Order','排列格式'})
        Err_content = [Err_content,'--J列应为排列格式，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,11)), {'Start Byte','起始字节'})
        Err_content = [Err_content,'--K列应为起始字节，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,12)), {'Start Bit','起始位'})
        Err_content = [Err_content,'--L列应为起始位，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,13)), {'Signal Send Type','信号发送类型'})
        Err_content = [Err_content,'--M列应为信号发送类型，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,14)), {'Bit Length (Bit)','信号长度'})
        Err_content = [Err_content,'--N列应为信号长度，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,15)), {'Data Type','数据类型'})
        Err_content = [Err_content,'--O列应为数据类型，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,16)), {'Resolution','精度'})
        Err_content = [Err_content,'--P列应为精度，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,17)), {'Offset','偏移量'})
        Err_content = [Err_content,'--Q列应为偏移量，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,18)), {'Signal Min. Value (phys)','物理最小值'})
        Err_content = [Err_content,'--R列应为物理最小值，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,19)), {'Signal Max. Value(phys)','物理最大值'})
        Err_content = [Err_content,'--S列应为物理最大值，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,20)), {'Initial Value(Hex)','初始值'})
        Err_content = [Err_content,'--T列应为初始值，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,21)), {'Invalid Value(Hex)','无效值'})
        Err_content = [Err_content,'--U列应为无效值，请检查！！！',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,22)), {'Unit','单位'})
        Err_content = [Err_content,'--V列应为单位，请检查！！！',10];
        CheckPass = 0;
    end
    
    % 首行与标准模板不一致时，直接返回
    if CheckPass == 0
        Err_content = [10,'--文件',FileDir,FileName,'的工作表',GenSheet,'列排序与模板不一致，请检查！！！--',10,Err_content];
        UpdateInfoList(Err_content);
        return;
    end

    %获取节点名称并拼接，从23到最后一列，行2都是节点名称
    if row_num > 22    %无定义节点时，使用空节点
        NodeName = {};
        NodeNum = 0;
        for NodeIdex = 23:row_num
            if ~isnan(cell2mat(CAN_Matrix_Text(2,NodeIdex)))
                NodeNum = NodeNum + 1;
                NodeName{NodeNum} = cell2mat(CAN_Matrix_Text(2,NodeIdex));
            end
        end
    end
    
    MsgInfo.Node = NodeName';

    for column_index = 3:column_num  %去除行1与行2，从第3行获取
        MsgLine = 0;
        Message_Text = CAN_Matrix_Text(column_index,1:row_num);     %按行读取，解决列数改变时无法自动适配问题
        %所有获取信息改为直接保存内容，不再用cell表示
        MsgName = cell2mat(Message_Text(1,1));       %标准模板报文名称处于第1列
        MsgType = cell2mat(Message_Text(1,2));       %标准模板报文类型处于第2列
        MsgID = cell2mat(Message_Text(1,3));         %标准模板ID处于第3列
        MsgSendType = cell2mat(Message_Text(1,4));   %标准模板报文发送类型处于第4列
        MsgCycleTime = cell2mat(Message_Text(1,5));  %标准模板报文周期处于第5列 
        MsgLength = cell2mat(Message_Text(1,6));     %标准模板报文长度处于第6列
        
        % 以下为信号相关，删除原ByteNum与BitNum
        SignalName = cell2mat(Message_Text(1,7));     %标准模板信号名称处于第7列
        Comment = cell2mat(Message_Text(1,8));        %标准模板信号描述说明处于第8列
        ValueDesc = cell2mat(Message_Text(1,9));      %标准模板信号值描述处于第9列
        ByteOrder = cell2mat(Message_Text(1,10));     %标准模板信号排列格式处于第10列
        StartByte = cell2mat(Message_Text(1,11));     %标准模板信号起始字节处于第11列
        StartBit = cell2mat(Message_Text(1,12));      %标准模板信号起始位处于第12列
        SendType = cell2mat(Message_Text(1,13));      %标准模板信号发送类型处于第13列
        Length = cell2mat(Message_Text(1,14));        %标准模板信号长度处于第14列
        DataType = cell2mat(Message_Text(1,15));      %标准模板信号数据类型处于第15列
        Factor = cell2mat(Message_Text(1,16));        %标准模板信号精度处于第16列
        Offset = cell2mat(Message_Text(1,17));        %标准模板信号偏移量处于第17列
        Min = cell2mat(Message_Text(1,18));           %标准模板信号物理最小值处于第18列
        Max = cell2mat(Message_Text(1,19));           %标准模板信号物理最大值处于第19列
        InitValue = cell2mat(Message_Text(1,20));     %标准模板信号初始值处于第20列
        InvalidValue = cell2mat(Message_Text(1,21));  %标准模板信号无效值处于第21列
        Unit = cell2mat(Message_Text(1,22));          %标准模板信号单位处于第22列

        %ID字符串处理，如果为16进制写法，如0x100或0X100，只取X后的字符串
        if ~isnan(MsgID)
            IDString = MsgID;    %提取ID字符串
            if contains(IDString, {'x','X'})    %若有x/X，只取x/X后的字符串
                xPos = find(IDString == 'x',length(IDString), 'last'); 
                XPos = find(IDString == 'X',length(IDString), 'last');
                if ~isempty(xPos) && ~isempty(XPos)
                    IDString = IDString(max(max(xPos),max(XPos))+1:end);
                elseif ~isempty(xPos)
                    IDString = IDString(max(xPos)+1:end);
                else
                    IDString = IDString(max(XPos)+1:end);
                end
            end
            
            %根据ID范围确定是否可能为标准帧，大于0x7FF时，需要定义为扩展帧，增加bit31定义
            
            if ~isempty(regexp(IDString,'[^0-9a-fA-F]'))
                MsgLine = 0;
            elseif hex2dec(IDString) > hex2dec('1FFFFFFF')    % 536870911，超29Bit最大值认为是非ID
                MsgLine = 0;    
            elseif hex2dec(IDString) > hex2dec('7FF')    % 2047
                MsgIDStr = num2str(hex2dec(IDString) + hex2dec('80000000'));
                if isfield(MsgInfo,'MsgList')
                   if strcmp(MsgInfo.MsgList(i).ID,MsgIDStr)
                       MsgLine = 0;
                   else
                       MsgLine = 1;
                       i = i + 1;
                       MsgInfo.MsgList(i).ID = MsgIDStr;
                   end
                else
                   MsgLine = 1;
                   MsgInfo.MsgList(i).ID = MsgIDStr;
                end
            else
                MsgIDStr = num2str(hex2dec(IDString));
                if isfield(MsgInfo,'MsgList')
                   if strcmp(MsgInfo.MsgList(i).ID,MsgIDStr)
                       MsgLine = 0;
                   else
                       MsgLine = 1;
                       i = i + 1;
                       MsgInfo.MsgList(i).ID = MsgIDStr;
                   end
                else
                   MsgLine = 1;
                   MsgInfo.MsgList(i).ID = MsgIDStr;
                end
            end
            
            if MsgLine == 1     %帧定义行
                MsgInfo.MsgList(i).Name = MsgName;
                MsgInfo.MsgList(i).Type = MsgType;
                MsgInfo.MsgList(i).SendType = MsgSendType;
                MsgInfo.MsgList(i).CycleTime = MsgCycleTime;
                MsgInfo.MsgList(i).Length = MsgLength;
                MsgInfo.MsgList(i).Desc = Comment;
                MsgInfo.MsgList(i).Receiver = '';           %暂不处理接收节点
                SendNode = '';
                for SendNodeIdex = 23:row_num
                    MsgNodeStStr = cell2mat(Message_Text(1,SendNodeIdex));
                    if ~isnan(MsgNodeStStr)
                        if isnumeric(MsgNodeStStr)
                            continue;
                        else
                            MsgNodeStStr = strtrim(MsgNodeStStr);
                        end
                    else
                        continue;
                    end
                    
                    if ~strcmpi(MsgNodeStStr,'S')   % 非发送定义，直接下一循环
                        continue;
                    elseif isempty(SendNode)
                        SendNode = MsgInfo.Node{SendNodeIdex-22};
                    elseif ~isempty(SendNode)
                        SendNode = '';
                    else
                    end
                end
                MsgInfo.MsgList(i).Sender = SendNode;
                j = 1;
            else                %非帧定义行，认为是信号行
                if ~isnan(SignalName)     %信号名不为空才认为可读取其他信息
                    MsgInfo.MsgList(i).SigList(j).Name = SignalName;
                    MsgInfo.MsgList(i).SigList(j).Desc = Comment;
                    MsgInfo.MsgList(i).SigList(j).ValDesc = ValueDesc;
                    MsgInfo.MsgList(i).SigList(j).ByteOrder = ByteOrder;
                    MsgInfo.MsgList(i).SigList(j).StartByte = StartByte;
                    MsgInfo.MsgList(i).SigList(j).StartBit = StartBit;
                    MsgInfo.MsgList(i).SigList(j).SendType = SendType;
                    MsgInfo.MsgList(i).SigList(j).Length = Length;
                    MsgInfo.MsgList(i).SigList(j).DataType = DataType;
                    MsgInfo.MsgList(i).SigList(j).Factor = Factor;
                    MsgInfo.MsgList(i).SigList(j).Offset = Offset;
                    MsgInfo.MsgList(i).SigList(j).PhyMin = Min;
                    MsgInfo.MsgList(i).SigList(j).PhyMax = Max;
                    MsgInfo.MsgList(i).SigList(j).InitValue = InitValue;
                    MsgInfo.MsgList(i).SigList(j).InvalidValue = InvalidValue;
                    MsgInfo.MsgList(i).SigList(j).Unit = Unit;
                    MsgInfo.MsgList(i).SigList(j).Receiver = '';
                    
                    RcvNode = '';
                    for RcvNodeIdex = 23:row_num
                        SigNodeStStr = cell2mat(Message_Text(1,RcvNodeIdex));
                        
                        if ~isnan(SigNodeStStr)
                            if isnumeric(SigNodeStStr)
                                continue;
                            else
                                SigNodeStStr = strtrim(SigNodeStStr);
                            end
                        else
                            continue;
                        end
                        
                        if ~strcmpi(SigNodeStStr,'R')   % 非接收定义，直接下一循环
                            continue;
                        elseif strcmp(MsgInfo.Node{RcvNodeIdex-22},MsgInfo.MsgList(i).Sender)
                            continue;
                        elseif isempty(RcvNode)
                            RcvNode = MsgInfo.Node{RcvNodeIdex-22};
                        elseif ~isempty(RcvNode)
                            RcvNode = [RcvNode,',',MsgInfo.Node{RcvNodeIdex-22}];
                        else
                        end
                    end
                    MsgInfo.MsgList(i).SigList(j).Receiver = RcvNode;
                    
                    j = j + 1;
                end
            end
        else
            if ~isnan(SignalName)     %信号名不为空才认为可读取其他信息
                MsgInfo.MsgList(i).SigList(j).Name = SignalName;
                MsgInfo.MsgList(i).SigList(j).Desc = Comment;
                MsgInfo.MsgList(i).SigList(j).ValDesc = ValueDesc;
                MsgInfo.MsgList(i).SigList(j).ByteOrder = ByteOrder;
                MsgInfo.MsgList(i).SigList(j).StartByte = StartByte;
                MsgInfo.MsgList(i).SigList(j).StartBit = StartBit;
                MsgInfo.MsgList(i).SigList(j).SendType = SendType;
                MsgInfo.MsgList(i).SigList(j).Length = Length;
                MsgInfo.MsgList(i).SigList(j).DataType = DataType;
                MsgInfo.MsgList(i).SigList(j).Factor = Factor;
                MsgInfo.MsgList(i).SigList(j).Offset = Offset;
                MsgInfo.MsgList(i).SigList(j).PhyMin = Min;
                MsgInfo.MsgList(i).SigList(j).PhyMax = Max;
                MsgInfo.MsgList(i).SigList(j).InitValue = InitValue;
                MsgInfo.MsgList(i).SigList(j).InvalidValue = InvalidValue;
                MsgInfo.MsgList(i).SigList(j).Unit = Unit;
                MsgInfo.MsgList(i).SigList(j).Receiver = '';
                    
                RcvNode = '';
                for RcvNodeIdex = 23:row_num
                    SigNodeStStr = cell2mat(Message_Text(1,RcvNodeIdex));

                    if ~isnan(SigNodeStStr)
                        if isnumeric(SigNodeStStr)
                            continue;
                        else
                            SigNodeStStr = strtrim(SigNodeStStr);
                        end
                    else
                        continue;
                    end

                    if ~strcmpi(SigNodeStStr,'R')   % 非接收定义，直接下一循环
                        continue;
                    elseif strcmp(MsgInfo.Node{RcvNodeIdex-22},MsgInfo.MsgList(i).Sender)
                        continue;
                    elseif isempty(RcvNode)
                        RcvNode = MsgInfo.Node{RcvNodeIdex-22};
                    elseif ~isempty(RcvNode)
                        RcvNode = [RcvNode,',',MsgInfo.Node{RcvNodeIdex-22}];
                    else
                    end
                end
                MsgInfo.MsgList(i).SigList(j).Receiver = RcvNode;
                    
                j = j + 1;
            end
        end
    end
    RetResult = 1;
end



function [BO_SG_Content,CM_BO_SG_Content,BA_BO_Content,BA_SG_Content,VAL_Content] = SortMsgInfo(CANMsgInfo)
    eol = '\n';
    
    % BO SG 写入
    BO_SG_Content = [];
    for BO_Index = 1:numel(CANMsgInfo.MsgList)
        Sender = 'Vector__XXX';
        if ~isempty(CANMsgInfo.MsgList(BO_Index).Sender)
            Sender = CANMsgInfo.MsgList(BO_Index).Sender;
        end
        BO_SG_Content = [BO_SG_Content sprintf(strcat('BO_',32,CANMsgInfo.MsgList(BO_Index).ID,32,CANMsgInfo.MsgList(BO_Index).Name,':',32,...
                                                        num2str(CANMsgInfo.MsgList(BO_Index).Length),32,Sender)) eol];

        for SG_Index = 1:numel(CANMsgInfo.MsgList(BO_Index).SigList)                    

            SignalName = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Name;
            ByteOrder = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).ByteOrder;
            StartBit = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).StartBit;
            Length = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Length;
            DataType = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).DataType;
            Factor = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Factor;
            Offset = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Offset;
            Min = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).PhyMin;
            Max = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).PhyMax;
            Unit = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Unit;
            Receiver = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Receiver;

            if ~all(isnan(SignalName)) && ~all(isnan(ByteOrder)) && ~all(isnan(StartBit))...
                && ~all(isnan(Length)) && ~all(isnan(DataType)) && ~all(isnan(Factor))...
                && ~all(isnan(Offset)) && ~all(isnan(Min)) && ~all(isnan(Max))
                    if isnumeric(StartBit)
                        if ~isnumeric(Length)                 
                            UpdateInfoList(['变量 ',SignalName,' 长度填写格式异常，非数值，请检查！！！']);
                            return;
                        end

                        if ~ismember(ByteOrder,{'Intel','Motorola','Motorola MSB','Motorola LSB'})
                           UpdateInfoList(['变量 ',SignalName,' 字节顺序填写格式异常，请检查！！！']);
                           return; 
                        end

                        if strcmpi(ByteOrder, 'Intel')
                            if StartBit + Length > 64
                                UpdateInfoList(['变量 ',SignalName,' 起始位与长度填写不匹配，有越界问题，请检查！！！']);
                                return;
                            else
                                StartBitHndl = StartBit;
                            end
                            ByteOrderStr = '1';
                        elseif strcmpi(ByteOrder, 'Motorola LSB') || strcmpi(ByteOrder, 'Motorola')

                            if StartBit < 0 || StartBit > 63
                                UpdateInfoList(['变量 ',SignalName,' 起始位填写超限，请检查！！！']);
                                return;
                            else
                                LSB = zeros( 8, 8 );
                                for Li = 1:8
                                    for Lj = 1:8
                                        LSB( Li, Lj ) = 8 * Li - Lj;
                                    end
                                end
                                TransLSB =  LSB';
                                TransMatrixIdx = find(TransLSB == StartBit) + 1 - Length;
                                if TransMatrixIdx < 1 || TransMatrixIdx > 64
                                    UpdateInfoList(['变量 ',SignalName,' 起始位与长度填写不匹配，有越界问题，请检查！！！']);
                                    return;
                                else
                                    StartBitHndl = TransLSB(TransMatrixIdx);
                                end
                            end

                            ByteOrderStr = '0';
                        else
                            UpdateInfoList(['变量 ',SignalName,' 字节顺序填写为Motorola MSB，当前暂未开发此格式信号自动生成功能，请手动编写DBC！！！']);
                            return;
                        end
                    else
                        UpdateInfoList(['变量 ',SignalName,' 起始位填写格式异常，非数值，请检查！！！']);
                        return;
                    end
            else
                UpdateInfoList('信号部分关键信息未填充，请检查！！！');
                return;
            end

            if strcmpi(DataType, 'Unsigned')    %信号类型设定，0为无符号，1为有符号（包含浮点）
                DataType = '+ ';
            elseif strcmpi(DataType, 'Signed')
                DataType = '- ';
            else
                UpdateInfoList(['变量 ',SignalName,' 数据类型填写格式异常，请检查！！！']);
                return;
            end

            if isnumeric(Factor)
                Factor = num2str(Factor);        %精度设定
            else
                UpdateInfoList(['变量 ',SignalName,' 精度填写格式异常，非数值，请检查！！！']);
                return;
            end

            if isnumeric(Offset)
                Offset = num2str(Offset);        %偏移量设定
            else
                UpdateInfoList(['变量 ',SignalName,' 偏移量填写格式异常，非数值，请检查！！！']);
                return;
            end

            if isnumeric(Min)
                Min = num2str(Min);           %最小值设定
            else
                UpdateInfoList(['变量 ',SignalName,' 最小值填写格式异常，非数值，请检查！！！']);
                return;
            end

            if isnumeric(Max)
                Max = num2str(Max);           %最大值设定
            else
                UpdateInfoList(['变量 ',SignalName,' 最大值填写格式异常，非数值，请检查！！！']);
                return;
            end

            if ~isnan(Unit)
                if strcmp(Unit,'%')     % 单位为%时，单独处理，避免matlab误识别注释后面内容
                    Unit = '%%%%';
                else
                end
            else
                Unit = '';
            end
            
            if isempty(Receiver)
                Receiver = 'Vector__XXX';
            end

            BO_SG_Content = [BO_SG_Content sprintf(strcat(32,'SG_',32,SignalName,32,':',32,num2str(StartBitHndl),'|',num2str(Length),'@',ByteOrderStr,DataType,32,...
                                                            '(',Factor,',',Offset,')',32,'[',Min,'|',Max,']',32,'"',Unit,'"',32,Receiver)) eol];
        end
        BO_SG_Content = [BO_SG_Content eol];
    end


    % CM_ BO_/SG_
    CM_BO_SG_Content = [];
    for BO_Index = 1:numel(CANMsgInfo.MsgList)
    if ~isnan(CANMsgInfo.MsgList(BO_Index).Desc)
        if isnumeric(CANMsgInfo.MsgList(BO_Index).Desc)
            MsgDesc = num2str(CANMsgInfo.MsgList(BO_Index).Desc);
        else
            MsgDesc = CANMsgInfo.MsgList(BO_Index).Desc;
            if contains(MsgDesc, {'%'})        % 符号'%'替代为'%%%%'，避免注释后续字符
                MsgDesc = strrep(MsgDesc,'%','%%%%');
            end
        end
        CM_BO_SG_Content = [CM_BO_SG_Content sprintf(strcat('CM_',32,'BO_',32,CANMsgInfo.MsgList(BO_Index).ID,32,'"',MsgDesc,'";')) eol];
    end
    for SG_Index = 1:numel(CANMsgInfo.MsgList(BO_Index).SigList)
        if ~isnan(CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Desc)
            if isnumeric(CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Desc)
                SigDesc = num2str(CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Desc);
            else
                SigDesc = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Desc;
                if contains(SigDesc, {'%'})        % 符号'%'替代为'%%%%'，避免注释后续字符
                    SigDesc = strrep(SigDesc,'%','%%%%');
                end
            end
            CM_BO_SG_Content = [CM_BO_SG_Content sprintf(strcat('CM_',32,'SG_',32,CANMsgInfo.MsgList(BO_Index).ID,32,...
                                                            CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Name,32,'"',SigDesc,'";')) eol];
        end
    end
    end

    % VAL_
    VAL_Content = [];
    for BO_Index = 1:numel(CANMsgInfo.MsgList)
    for SG_Index = 1:numel(CANMsgInfo.MsgList(BO_Index).SigList)
        if ~isnan(CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).ValDesc)
            if ~isnumeric(CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).ValDesc)
                ValDesc = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).ValDesc;
                ValDescStr = strsplit(ValDesc,'\n');    %通过新一行符号（\n），拆分字符串
                % 分解写入
                ValDesc = '';
                for ValDescIdx = 1:numel(ValDescStr)
                    if contains(ValDescStr{ValDescIdx},':')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},':');
                        if contains(DescTxt{1}, {'0x','0X'})    %若有x/X，只取x/X后的字符串，十六进制兼容
                            xPos = find(DescTxt{1} == 'x',1, 'last'); 
                            XPos = find(DescTxt{1} == 'X',1, 'last');
                            if ~isempty(xPos) && ~isempty(XPos)
                                ValNum = DescTxt{1}(max(max(xPos),max(XPos))+1:end);
                            elseif ~isempty(xPos)
                                ValNum = DescTxt{1}(max(xPos)+1:end);
                            else
                                ValNum = DescTxt{1}(max(XPos)+1:end);
                            end
                            ValNum = strtrim(ValNum);
                            if isempty(regexp(ValNum,'[^0-9a-fA-F]'))
                                ValNumStr = num2str(hex2dec(ValNum));
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        else
                            ValNum = DescTxt{1};
                            ValNum = strtrim(ValNum);
                            if isempty(regexp(ValNum,'[^0-9]'))
                                ValNumStr = ValNum;                 % 20230316修改
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        end
                        ValDescTxt = strtrim(DescTxt{2});
                        
                        ValDesc = strcat(ValDesc,32,'"',ValDescTxt,'"');
                        if contains(ValDesc, {'%'})        % 符号'%'替代为'%%'，避免注释后续字符
                            ValDesc = strrep(ValDesc,'%','%%%%');
                        end
                    elseif contains(ValDescStr{ValDescIdx},'：')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},'：');
                        if contains(DescTxt{1}, {'0x','0X'})    %若有x/X，只取x/X后的字符串
                            xPos = find(DescTxt{1} == 'x',1, 'last'); 
                            XPos = find(DescTxt{1} == 'X',1, 'last');
                            if ~isempty(xPos) && ~isempty(XPos)
                                ValNum = DescTxt{1}(max(max(xPos),max(XPos))+1:end);
                            elseif ~isempty(xPos)
                                ValNum = DescTxt{1}(max(xPos)+1:end);
                            else
                                ValNum = DescTxt{1}(max(XPos)+1:end);
                            end
                            
                            ValNum = strtrim(ValNum);
                            if isempty(regexp(ValNum,'[^0-9a-fA-F]'))
                                ValNumStr = num2str(hex2dec(ValNum));
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        else
                            ValNum = strtrim(DescTxt{1});

                            if isempty(regexp(ValNum,'[^0-9]'))
                                ValNumStr = ValNum;                 % 20230316修改
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        end
                        ValDescTxt = strtrim(DescTxt{2});
                        ValDesc = strcat(ValDesc,32,'"',ValDescTxt,'"');
                        if contains(ValDesc, {'%'})        % 符号'%'替代为'%%'，避免注释后续字符
                            ValDesc = strrep(ValDesc,'%','%%%%');
                        end
                    elseif contains(ValDescStr{ValDescIdx},'=')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},'=');
                        if contains(DescTxt{1}, {'0x','0X'})    %若有x/X，只取x/X后的字符串
                            xPos = find(DescTxt{1} == 'x',1, 'last'); 
                            XPos = find(DescTxt{1} == 'X',1, 'last');
                            if ~isempty(xPos) && ~isempty(XPos)
                                ValNum = DescTxt{1}(max(max(xPos),max(XPos))+1:end);
                            elseif ~isempty(xPos)
                                ValNum = DescTxt{1}(max(xPos)+1:end);
                            else
                                ValNum = DescTxt{1}(max(XPos)+1:end);
                            end
                            
                            ValNum = strtrim(ValNum);
                            
                            if isempty(regexp(ValNum,'[^0-9a-fA-F]'))
                                ValNumStr = num2str(hex2dec(ValNum));
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        else
                            ValNum = strtrim(DescTxt{1});
                            
                            if isempty(regexp(ValNum,'[^0-9]'))
                                ValNumStr = ValNum;                 % 20230316修改
                                if isempty(ValDesc)
                                    ValDesc = ValNumStr;
                                else
                                    ValDesc = strcat(ValDesc,32,ValNumStr);
                                end
                            else
                                continue;
                            end
                        end
                        ValDescTxt = strtrim(DescTxt{2});
                        ValDesc = strcat(ValDesc,32,'"',ValDescTxt,'"');
                        if contains(ValDesc, {'%'})        % 符号'%'替代为'%%'，避免注释后续字符
                            ValDesc = strrep(ValDesc,'%','%%%%');
                        end
                    end
                end

                if ~isempty(ValDesc)
                    VAL_Content = [VAL_Content sprintf(strcat('VAL_',32,CANMsgInfo.MsgList(BO_Index).ID,32,...
                                                            CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Name,32,ValDesc,';')) eol];
                else
                end

            end

        end
    end
    end

    % BA_ BO_
    BA_BO_Content = [];
    for BO_Index = 1:numel(CANMsgInfo.MsgList)
    MsgID = CANMsgInfo.MsgList(BO_Index).ID;
    MsgSendType = CANMsgInfo.MsgList(BO_Index).SendType;
    MsgCycleTime = CANMsgInfo.MsgList(BO_Index).CycleTime;

    if strcmpi(MsgSendType,'IfActive')
        if isempty(BA_BO_Content)
            BA_BO_Content = [sprintf(strcat('BA_',32,'"GenMsgSendType"',32,'BO_',32,MsgID,32,'7',';')) eol];
        else
            BA_BO_Content = [BA_BO_Content sprintf(strcat('BA_',32,'"GenMsgSendType"',32,'BO_',32,MsgID,32,'7',';')) eol];
        end
    elseif strcmpi(MsgSendType,'Cycle')
        if ~isnan(MsgCycleTime) && isnumeric(MsgCycleTime)
            if isempty(BA_BO_Content)
                BA_BO_Content = [sprintf(strcat('BA_',32,'"GenMsgCycleTime"',32,'BO_',32,MsgID,32,num2str(MsgCycleTime),';')) eol];
                BA_BO_Content = [BA_BO_Content sprintf(strcat('BA_',32,'"GenMsgSendType"',32,'BO_',32,MsgID,32,'0',';')) eol];
            else
                BA_BO_Content = [BA_BO_Content sprintf(strcat('BA_',32,'"GenMsgCycleTime"',32,'BO_',32,MsgID,32,num2str(MsgCycleTime),';')) eol];
                BA_BO_Content = [BA_BO_Content sprintf(strcat('BA_',32,'"GenMsgSendType"',32,'BO_',32,MsgID,32,'0',';')) eol];
            end
        end
    end
    end
    % BA_ SG_
    BA_SG_Content = [];
    for BO_Index = 1:numel(CANMsgInfo.MsgList)
    MsgID = CANMsgInfo.MsgList(BO_Index).ID;
    for SG_Index = 1:numel(CANMsgInfo.MsgList(BO_Index).SigList)
        SigName = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Name;
        InitValue = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).InitValue;
        Factor = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Factor;
        Offset = CANMsgInfo.MsgList(BO_Index).SigList(SG_Index).Offset;
        if ~isnan(Factor) && isnumeric(Factor) && ~isnan(Offset) && isnumeric(Offset)
            if ~isnan(InitValue)
                if contains(InitValue, {'0x','0X'})    %若有x/X，只取x/X后的字符串
                    xPos = find(InitValue == 'x',1, 'last'); 
                    XPos = find(InitValue == 'X',1, 'last');
                    if ~isempty(xPos) && ~isempty(XPos)
                        Ini_Val = InitValue(max(max(xPos),max(XPos))+1:end);
                    elseif ~isempty(xPos)
                        Ini_Val = InitValue(max(xPos)+1:end);
                    else
                        Ini_Val = InitValue(max(XPos)+1:end);
                    end
                    if isempty(regexp(Ini_Val,'[^0-9a-fA-F]'))
                        Ini_Val_Num = hex2dec(Ini_Val);
                    else
                        return;
                    end
                else
                    if isempty(regexp(InitValue,'[^0-9a-fA-F]'))
                        Ini_Val_Num = hex2dec(InitValue);
                    else
                        return;
                    end
                end
                IV = (Ini_Val_Num - Offset )/ Factor;
                IV_Str = num2str(IV);

                if isempty(BA_SG_Content)
                    BA_SG_Content = [sprintf(strcat('BA_',32,'"GenSigStartValue"',32,'SG_',32,MsgID,32,SigName,32,IV_Str,';')) eol];
                else
                    BA_SG_Content = [BA_SG_Content sprintf(strcat('BA_',32,'"GenSigStartValue"',32,'SG_',32,MsgID,32,SigName,32,IV_Str,';')) eol];
                end
            end
        end
    end
    end


end

%--------------------------------------------------------------------------
% 函数名：[RetChkResult] = MsgInfoCheck(CANMsgInfo)
% 函数描述：检查CAN矩阵信息
% 修改日期：
%           2022/12/01    xuhongjiang01    新建函数
%--------------------------------------------------------------------------
function [RetChkResult] = MsgInfoCheck(CANMsgInfo)
    RetChkResult = 1;
    
    % ID重复性检查，需要避免重复ID定义
    if ~isfield(CANMsgInfo,'MsgList')
       RetChkResult = 0;
       return;
    else
        RecordSame = [0];
        for Idx = 1:numel(CANMsgInfo.MsgList)            
            NextLoop = 0;
            SameIDNum = 0;
            for RecIdx = 1:numel(RecordSame)    %当前行有被记录相同，则跳过此次循环
                if Idx==RecordSame(RecIdx)
                    NextLoop = 1;
                    break;
                end
            end
            if NextLoop == 1    
                continue;
            end
            
            CheckID = CANMsgInfo.MsgList(Idx).ID;
            if Idx == numel(CANMsgInfo.MsgList) %最后一个记录不检查
                break;
            end
            
            for SubIdx = Idx+1:numel(CANMsgInfo.MsgList)    %从下一行开始轮询比较
                if strcmp(CheckID,CANMsgInfo.MsgList(SubIdx).ID)
                    RecordSame(SameIDNum+1) = SubIdx;
                    SameIDNum = SameIDNum + 1;
                end
            end
            if SameIDNum > 0  % 提示ID重复信息
                RetChkResult = 0;
                UpdateInfoList(['ID 0x', dec2hex(bitand(str2double(CheckID),hex2dec('1FFFFFFF'))),' 有',num2str(SameIDNum+1), '个重复项，请检查修改！！！']);
            end
        end
    end
    
    % 信号名称重复性检查
   if ~isfield(CANMsgInfo,'MsgList')
       RetChkResult = 0;
       return;
   else
       SignalTemp = {};
       for i=1:numel(CANMsgInfo.MsgList)
           for j=1:numel(CANMsgInfo.MsgList(i).SigList)
               SignalTemp{numel(SignalTemp)+1} = CANMsgInfo.MsgList(i).SigList(j).Name;
           end
       end
       SignalTemp = SignalTemp';
       
        RecordNameSame = [0];
        for Idx = 1:numel(SignalTemp)            
            NextLoop = 0;
            SameNameNum = 0;
            for RecIdx = 1:numel(RecordNameSame)    %当前行有被记录相同，则跳过此次循环
                if Idx==RecordNameSame(RecIdx)
                    NextLoop = 1;
                    break;
                end
            end
            if NextLoop == 1    
                continue;
            end
            
            CheckName = SignalTemp{Idx};
            if Idx == numel(SignalTemp) %最后一个记录不检查
                break;
            end
            
            for SubIdx = Idx+1:numel(SignalTemp)    %从下一个记录开始轮询比较
                if strcmp(CheckName,SignalTemp{SubIdx})
                    RecordNameSame(SameNameNum+1) = SubIdx;
                    SameNameNum = SameNameNum + 1;
                end
            end
            if SameNameNum > 0  % 提示ID重复信息
                RetChkResult = 0;
                UpdateInfoList(['信号 ', CheckName,' 有',num2str(SameNameNum+1), '个重复项，请检查修改！！！']);
            end
        end
    end
end

%--------------------------------------------------------------------------
% 函数名：GetCommonInfo(DBCFileName,MsgNode)
% 函数描述：获取DBC文件通用描述信息
% 修改日期：
%           2022/11/13    xuhongjiang01    新建函数
%--------------------------------------------------------------------------
function [Header_content,BU_Content,BA_DEF_Content,BA_Content] = GetCommonInfo(DBCFileName,MsgNode)
    eol = '\n';
    
    Header_content = [sprintf('VERSION ""') eol];
    Header_content = [Header_content eol];
    Header_content = [Header_content eol];
    Header_content = [Header_content sprintf('NS_ :') eol];
    Header_content = [Header_content sprintf('\tNS_DESC_') eol];
    Header_content = [Header_content sprintf('\tCM_') eol];
    Header_content = [Header_content sprintf('\tBA_DEF_') eol];
    Header_content = [Header_content sprintf('\tBA_') eol];
    Header_content = [Header_content sprintf('\tVAL_') eol];
    Header_content = [Header_content sprintf('\tCAT_DEF_') eol];
    Header_content = [Header_content sprintf('\tCAT_') eol];
    Header_content = [Header_content sprintf('\tFILTER') eol];
    Header_content = [Header_content sprintf('\tBA_DEF_DEF_') eol];
    Header_content = [Header_content sprintf('\tEV_DATA_') eol];
    Header_content = [Header_content sprintf('\tENVVAR_DATA_') eol];
    Header_content = [Header_content sprintf('\tSGTYPE_') eol];
    Header_content = [Header_content sprintf('\tSGTYPE_VAL_') eol];
    Header_content = [Header_content sprintf('\tBA_DEF_SGTYPE_') eol];
    Header_content = [Header_content sprintf('\tBA_SGTYPE_') eol];
    Header_content = [Header_content sprintf('\tSIG_TYPE_REF_') eol];
    Header_content = [Header_content sprintf('\tVAL_TABLE_') eol];
    Header_content = [Header_content sprintf('\tSIG_GROUP_') eol];
    Header_content = [Header_content sprintf('\tSIG_VALTYPE_') eol];
    Header_content = [Header_content sprintf('\tSIGTYPE_VALTYPE_') eol];
    Header_content = [Header_content sprintf('\tBO_TX_BU_') eol];
    Header_content = [Header_content sprintf('\tBA_DEF_REL_') eol];
    Header_content = [Header_content sprintf('\tBA_REL_') eol];
    Header_content = [Header_content sprintf('\tBA_DEF_DEF_REL_') eol];
    Header_content = [Header_content sprintf('\tBU_SG_REL_') eol];
    Header_content = [Header_content sprintf('\tBU_EV_REL_') eol];
    Header_content = [Header_content sprintf('\tBU_BO_REL_') eol];
    Header_content = [Header_content sprintf('\tSG_MUL_VAL_') eol];
    Header_content = [Header_content eol];
    Header_content = [Header_content sprintf('BS_:') eol];   %BS_:波特率定义，可以不写
    Header_content = [Header_content eol];
    
    
    % BU_:用于定义网络节点，格式为 BU_:Nodename1 Nodename2 Nodename3 ……
    MessageNode = '';
    for NodeIdex = 1:numel(MsgNode)
        NodeNameStr = MsgNode{NodeIdex};
        MessageNode = strcat(MessageNode,32,NodeNameStr);
    end
    BU_Content = [sprintf(strcat('BU_:',MessageNode)) eol];

    % BA_DEF_ 属性定义部分，格式，当前仅定义报文及信号设置
    % BA_DEF_ Object AttributeName ValueType Min Max;
    % BA_DEF_DEF_ AttributeName DefaultValue;

    % Network相关属性
    BA_DEF_Content = [sprintf(strcat('BA_DEF_',32,'"BusType"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"ProtocolType"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"DBName"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"Manufacturer"',32,'STRING',';')) eol];

    % Node相关属性
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"ECU"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmStationAddress"',32,'INT',32,'0',32,'254',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939AAC"',32,'INT',32,'0',32,'1',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939IndustryGroup"',32,'INT',32,'0',32,'7',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939System"',32,'INT',32,'0',32,'127',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939SystemInstance"',32,'INT',32,'0',32,'15',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939Function"',32,'INT',32,'0',32,'255',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939FunctionInstance"',32,'INT',32,'0',32,'7',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939ECUInstance"',32,'INT',32,'0',32,'3',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939ManufacturerCode"',32,'INT',32,'0',32,'2047',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BU_',32,'"NmJ1939IdentityNumber"',32,'INT',32,'0',32,'2097151',';')) eol];

    % Signal相关属性
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"SigType"',32,'ENUM',32,'"Default"',',','"Range"',',','"RangeSigned"',',',...
                                                    '"ASCII"',',','"Discrete"',',','"Control"',',','"ReferencePGN"',',','"DTC"',',','"StringDelimiter"',',',...
                                                    '"StringLength"',',','"StringLengthControl"',',','"MessageCounter"',',','"MessageChecksum"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"SPN"',32,'INT',32,'0',32,'524287',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"GenSigILSupport"',32,'ENUM',32,'"No","Yes"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"GenSigSendType"',32,'ENUM',32,'"Cyclic"',',','"OnWrite"',',','"OnWriteWithRepetition"',',',...
                                                    '"OnChange"',',','"OnChangeWithRepetition"',',','"IfActive"',',','"IfActiveWithRepetition"',',','"NoSigSendType"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"GenSigInactiveValue"',32,'INT',32,'0',32,'1000000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"GenSigStartValue"',32,'INT',32,'0',32,'10000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'SG_',32,'"GenSigEVName"',32,'STRING',';')) eol];

    % Message相关属性
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgILSupport"',32,'ENUM','"No","Yes"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgSendType"',32,'ENUM',32,'"Cyclic","NotUsed","NotUsed","NotUsed","NotUsed","NotUsed","NotUsed","IfActive","noMsgSendType"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgDelayTime"',32,'INT',32,'0',32,'1000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgStartDelayTime"',32,'INT',32,'0',32,'100000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgFastOnStart"',32,'INT',32,'0',32,'1000000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgNrOfRepetition"',32,'INT',32,'0',32,'1000000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgCycleTime"',32,'INT',32,'0',32,'60000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgCycleTimeFast"',32,'INT',32,'0',32,'1000000',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"GenMsgRequestable"',32,'INT',32,'0',32,'1',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'BO_',32,'"VFrameFormat"',32,'ENUM',32,'"StandardCAN","ExtendedCAN","reserved","J1939PG"',';')) eol];

    %----------------以下为相关默认定义--------------------
    % Network默认属性定义
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"BusType"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"ProtocolType"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"DBName"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"Manufacturer"',32,'"Vector"',';')) eol];

    % Node默认属性定义
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"ECU"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmStationAddress"',32,'254',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939AAC"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939IndustryGroup"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939System"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939SystemInstance"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939Function"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939FunctionInstance"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939ECUInstance"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939ManufacturerCode"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"NmJ1939IdentityNumber"',32,'0',';')) eol];

    % Signal默认属性定义
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"SigType"',32,'"Default"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"SPN"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigILSupport"',32,'"Yes"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigSendType"',32,'"NoSigSendType"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigInactiveValue"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigStartValue"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigEVName"',32,'"Env@Nodename_@Signame"',';')) eol];

    % 报文属性默认定义
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgILSupport"',32,'"Yes"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgSendType"',32,'"noMsgSendType"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgDelayTime"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgStartDelayTime"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgFastOnStart"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgNrOfRepetition"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgCycleTime"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgCycleTimeFast"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenMsgRequestable"',32,'1',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"VFrameFormat"',32,'"','ExtendedCAN','"',';')) eol];
    
    % BA_
    BA_Content = [sprintf(strcat('BA_',32,'"ProtocolType"',32,'""',';')) eol];
    BA_Content = [BA_Content sprintf(strcat('BA_',32,'"Manufacturer"',32,'"HY"',';')) eol];
    BA_Content = [BA_Content sprintf(strcat('BA_',32,'"BusType"',32,'"CAN"',';')) eol];
    BA_Content = [BA_Content sprintf(strcat('BA_',32,'"DBName"',32,'"',DBCFileName,'"',';')) eol];
end

% DBC2Excel
function DBCFileSel_Callback(~,~)
    global GUI_DBCTool
    [DBCName,DBCPath] =uigetfile({'*.dbc'},'Select the Data Dictionary');
    if ~isequal(DBCName,0)
        if strcmpi(DBCName(end-3:end),'.dbc')
            try
                set(GUI_DBCTool.DBCPathStr, 'String', [DBCPath,DBCName]);
                set(GUI_DBCTool.DBCPathStr, 'Value', 2);
            catch
                % 暂不做任何事情
            end
        else
            try
                set(GUI_DBCTool.DBCPathStr, 'String', '');
                set(GUI_DBCTool.DBCPathStr, 'Value', 0);
            catch
                % 暂不做任何事情
            end
            UpdateXlsInfoList('选中文件非dbc文件，请检查！！！');
        end
    else
        set(GUI_DBCTool.DBCPathStr, 'String', '');
        set(GUI_DBCTool.DBCPathStr, 'Value', 0);
        UpdateXlsInfoList('未选择文件！！！');
    end
end

function UpdateXlsInfoList(InfoStr)
    global GUI_DBCTool
    global GUI_XlsDataTemp
    
    while 1
        MaxLineCharNum = 52;
        if size(InfoStr,2) > MaxLineCharNum
            StrTemp = InfoStr(1:MaxLineCharNum);
            InfoStr = InfoStr(MaxLineCharNum+1:end);
            if isempty(GUI_XlsDataTemp)
                GUI_XlsDataTemp = {StrTemp};
            else
                GUI_XlsDataTemp = [GUI_XlsDataTemp;StrTemp];
            end
        else
            StrTemp = InfoStr;
            if isempty(GUI_XlsDataTemp)
                GUI_XlsDataTemp = {StrTemp};
            else
                GUI_XlsDataTemp = [GUI_XlsDataTemp;StrTemp];
            end
            break;
        end
    end
    
    set(GUI_DBCTool.XlsInfoList, 'String', GUI_XlsDataTemp);
    set(GUI_DBCTool.XlsInfoList, 'Max', size(GUI_XlsDataTemp,1));
    set(GUI_DBCTool.XlsInfoList, 'Value',get(GUI_DBCTool.XlsInfoList, 'Max'));
    pause(0.001);
%     if get(GUI_DBCTool.XlsInfoList, 'Max') > 1
%         set(GUI_DBCTool.XlsInfoList, 'Value',[]);
%     end
end

function ClrXlsList_Callback(~, ~)
    global GUI_DBCTool
    global GUI_XlsDataTemp
    GUI_XlsDataTemp = {};
    set(GUI_DBCTool.XlsInfoList, 'String', GUI_XlsDataTemp,'Value',1);
end

function GenXls_Callback(~,~)
    global GUI_DBCTool
    
    DBCFileInfo = get(GUI_DBCTool.DBCPathStr, 'String');
    if isempty(DBCFileInfo)
        UpdateXlsInfoList('DBC文件未定义，生成进程已终止！！！');
        return;
    else
        if contains(DBCFileInfo,{'.dbc','.DBC'})
            if exist(DBCFileInfo, 'file')
                backslash = find(DBCFileInfo == '\', 1, 'last' );
                if isempty(backslash)
                    UpdateXlsInfoList('DBC文件目录异常，生成进程已终止！！！');
                    return;
                else
                    DbcPath = DBCFileInfo(1:backslash);
                    DbcFile = DBCFileInfo(backslash+1:end);
                end
            else
                UpdateXlsInfoList('DBC文件未找到，生成进程已终止！！！');
                return;
            end

        else
            UpdateXlsInfoList('DBC文件未定义，生成进程已终止！！！');
            return;
        end
    end
    
    msgInfoList = readDbcFile( [ DbcPath, DbcFile ] );
    
    ExcelPath = DbcPath;
    PrjStr = get(GUI_DBCTool.ProjectStr,'String');
    NodChStr = get(GUI_DBCTool.NodChStr,'String');
    
    ExcelFile = [ PrjStr, '_', NodChStr,'_', datestr( now, 'yyyymmdd' ),'.xlsx' ];
    
    % 判定是否有同名工作簿已被打开
    try
        hExcel = actxGetRunningServer('excel.application');     %获取已打开EXCEL服务器，并返回句柄
        for i=1:hExcel.Workbooks.Count
            if strcmp(ExcelFile,hExcel.Workbooks.Item(i).Name)
               UpdateXlsInfoList(['已打开同名表格 ',ExcelFile,'，请关闭或修改生成文件名称后重新操作生成流程！！！']);
               msgbox(['已打开同名表格 ',ExcelFile,'，请关闭或修改生成文件名称后重新操作生成流程！！！']);
               return;
            end
        end
        
    catch GetRunningErr 
        switch GetRunningErr.identifier
            case 'MATLAB:COM:invalidprogid'
                try
                    hExcel = actxGetRunningServer('ket.application');     %获取已打开WPS服务器，并返回句柄
                    for i=1:hExcel.Workbooks.Count
                        if strcmp(ExcelFile,hExcel.Workbooks.Item(i).Name)
                           UpdateXlsInfoList(['已打开同名表格 ',ExcelFile,'，请关闭或修改生成文件名称后重新操作生成流程！！！']);
                           msgbox(['已打开同名表格 ',ExcelFile,'，请关闭或修改生成文件名称后重新操作生成流程！！！']);
                           return;
                        end
                    end
                catch suberr
                    switch suberr.identifier
                        case 'MATLAB:COM:invalidprogid'
                            UpdateXlsInfoList('未找到Microsoft Office或WPS Office！！！');
                            msgbox('未找到Microsoft Office或WPS Office！！！');
                            return;
                        case 'MATLAB:COM:norunningserver'
                            % Do nothing
                        otherwise
                            UpdateXlsInfoList('获取Excel服务器句柄时发生未知错误！！！');
                            msgbox('获取Excel服务器句柄时发生未知错误！！！');
                            return; 
                    end
                end
            case 'MATLAB:COM:norunningserver'
                % Do nothing
            otherwise
                UpdateXlsInfoList('获取Excel服务器句柄时发生未知错误！！！');
                msgbox('获取Excel服务器句柄时发生未知错误！！！');
                return;
        end
    end
    
    % 已有工作簿删除
    if exist([ ExcelPath, ExcelFile ],'file')
        answer = questdlg('文件在目录下已存在，是否覆盖替换继续生成？？？','提示','是','否','否');
        switch answer
            case '是'
                AllFileName = [ ExcelPath, ExcelFile ];
                delete(AllFileName);
                
                if exist([ ExcelPath, ExcelFile ],'file')
                    UpdateXlsInfoList('---文件删除失败---');
                    msgbox('文件删除失败，可能有程序占用，请检查！！！');
                    return;
                else
                    UpdateXlsInfoList('---文件已删除---');
                end

            case '否'
                UpdateXlsInfoList('Excel文件生成过程中，用户选择退出---');
                return;
        end
    end    

    Sender = cell( 0 );
    Receiver = cell( 0 );
    for j = 1:size( msgInfoList, 2 )
        Sender{ j, 1 } = msgInfoList( 1, j ).sender;
        for jj = 1:size( msgInfoList( 1, j ).receiver, 2 )
            Receiver{ size( Receiver, 1 ) + 1, 1 } = msgInfoList( 1, j ).receiver{ 1, jj };
        end 
    end 
    Sender = unique( Sender );
    Receiver = unique( Receiver );
    Nodes = unique( [ Sender;Receiver ] );
    
    % ---------------调用服务器-----------------------
    try
        hExcel = actxserver('excel.application');     %获取EXCEL服务器，并返回句柄
    catch GetRunningErr 
        switch GetRunningErr.identifier
            case 'MATLAB:COM:InvalidProgid'
                try
                    hExcel = actxserver('ket.application');     %获取WPS服务器，并返回句柄
                catch suberr
                    switch suberr.identifier
                        case 'MATLAB:COM:InvalidProgid'
                            UpdateXlsInfoList('未找到Microsoft Office或WPS Office！！！');
                            msgbox('未找到Microsoft Office或WPS Office！！！');
                            return;
                    end
                end
            otherwise
                UpdateXlsInfoList('获取Excel服务器句柄时发生未知错误！！！');
                msgbox('获取Excel服务器句柄时发生未知错误！！！');
                return;
        end
    end

    hExcel.Visible = 0;                    %设置Excel服务器为不可见状态
    
    hWorkbooks = hExcel.Workbooks.Add;
    
    UpdateXlsInfoList('Excel文件生成中，请耐心等待---');
    
    hSheet = hWorkbooks.Sheets.Item(1);
    
    hSheet.Activate;                      % 激活该表格
    hSheet.Name = NodChStr;                 % 设定工作表名称
    
    hSheet.Cells.Font.name = '等线';
    hSheet.Cells.Font.size = 11;
    hSheet.Cells.HorizontalAlignment=3;  
    hSheet.Cells.VerticalAlignment=2;
    hSheet.Cells.WrapText=1;                % 所有单元格自动换行
    
    hSheet.Range('G:I').HorizontalAlignment=2;
    hSheet.Range('G:H').VerticalAlignment=3;
    
    hSheet.Range('B:B').Validation.Add('xlValidateList',1,1,'Normal,NM,Diag');
    hSheet.Range('D:D').Validation.Add('xlValidateList',1,1,'Cycle,Event,IfActive,CE,CA');
    hSheet.Range('J:J').Validation.Add('xlValidateList',1,1,'Intel,Motorola LSB,Motorola MSB,Motorola');
    hSheet.Range('M:M').Validation.Add('xlValidateList',1,1,'Cycle,OnWrite,OnWriteWithRepetition,OnChange,OnChangeWithRepetition,IfActive,IfActiveWithRepetition');
    hSheet.Range('O:O').Validation.Add('xlValidateList',1,1,'Unsigned,Signed,IEEE float,IEEE double');
    
    hSheet.Range('B1:B2').Validation.Delete;
    hSheet.Range('D1:D2').Validation.Delete;
    hSheet.Range('J1:J2').Validation.Delete;
    hSheet.Range('M1:M2').Validation.Delete;
    hSheet.Range('O1:O2').Validation.Delete;
    
    hSheet.Range('A1:A2').RowHeight = 48;
    
    hSheet.Range('A1').Value = [ 'Msg Name', char( 10 ), '报文名称' ];
    hSheet.Range('A1').ColumnWidth = 12;
    hSheet.Range('A1:A2').MergeCells = 1;
    
    hSheet.Range('B1').Value = [ 'Msg Type', char( 10 ), '报文类型' ];
    hSheet.Range('B1').ColumnWidth = 8.11;
    hSheet.Range('B1:B2').MergeCells = 1;
    
    hSheet.Range('C1').Value = [ 'Msg ID',char( 10 ),'(Hex)', char( 10 ), '报文标识符' ];
    hSheet.Range('C1').ColumnWidth = 12.11;
    hSheet.Range('C1:C2').MergeCells = 1;
    
    hSheet.Range('D1').Value = [ 'Msg Send Type', char( 10 ), '报文发送类型' ];
    hSheet.Range('D1').ColumnWidth = 8.11;
    hSheet.Range('D1:D2').MergeCells = 1;
    
    hSheet.Range('E1').Value = [ 'Msg Cycle Time',char( 10 ),'(ms)', char( 10 ), '报文周期时间'];
    hSheet.Range('E1').ColumnWidth = 8.11;
    hSheet.Range('E1:E2').MergeCells = 1;
    
    hSheet.Range('F1').Value = [ 'Msg Length',char( 10 ),'(Byte)', char( 10 ), '报文长度'];
    hSheet.Range('F1').ColumnWidth = 8.11;
    hSheet.Range('F1:F2').MergeCells = 1;
    
    hSheet.Range('G1').Value = [ 'Signal Name', char( 10 ), '信号名称'];
    hSheet.Range('G1').ColumnWidth = 25;
    hSheet.Range('G1:G2').MergeCells = 1;
    
    hSheet.Range('H1').Value = [ 'Signal Description', char( 10 ), '信号描述'];
    hSheet.Range('H1').ColumnWidth = 34.11;
    hSheet.Range('H1:H2').MergeCells = 1;
    
    hSheet.Range('I1').Value = [ 'Signal Value Description',char( 10 ),'(Dec)', char( 10 ), '信号值描述'];
    hSheet.Range('I1').ColumnWidth = 28.22;
    hSheet.Range('I1:I2').MergeCells = 1;
    
    hSheet.Range('J1').Value = [ 'Byte Order', char( 10 ), '排列格式',char( 10 ),'(Intel/Motorola)'];
    hSheet.Range('J1').ColumnWidth = 8.11;
    hSheet.Range('J1:J2').MergeCells = 1;
    
    hSheet.Range('K1').Value = [ 'Start Byte', char( 10 ), '起始字节'];
    hSheet.Range('K1').ColumnWidth = 8.11;
    hSheet.Range('K1:K2').MergeCells = 1;
    
    hSheet.Range('L1').Value = [ 'Start Bit', char( 10 ), '起始位'];
    hSheet.Range('L1').ColumnWidth = 8.11;
    hSheet.Range('L1:L2').MergeCells = 1;
    
    hSheet.Range('M1').Value = [ 'Signal Send Type', char( 10 ), '信号发送类型'];
    hSheet.Range('M1').ColumnWidth = 8.11;
    hSheet.Range('M1:M2').MergeCells = 1;
    
    hSheet.Range('N1').Value = [ 'Bit Length',char( 10 ),'(Bit)', char( 10 ), '信号长度'];
    hSheet.Range('N1').ColumnWidth = 8.11;
    hSheet.Range('N1:N2').MergeCells = 1;
    
    hSheet.Range('O1').Value = [ 'Data Type', char( 10 ), '信号类型'];
    hSheet.Range('O1').ColumnWidth = 8.78;
    hSheet.Range('O1:O2').MergeCells = 1;
    
    hSheet.Range('P1').Value = [ 'Resolution', char( 10 ), '精度'];
    hSheet.Range('P1').ColumnWidth = 8.11;
    hSheet.Range('P1:P2').MergeCells = 1;
    
    hSheet.Range('Q1').Value = [ 'Offset', char( 10 ), '偏移量'];
    hSheet.Range('Q1').ColumnWidth = 8.11;
    hSheet.Range('Q1:Q2').MergeCells = 1;
    
    hSheet.Range('R1').Value = [ 'Signal Min. Value',char( 10 ),'(phys)', char( 10 ), '物理最小值'];
    hSheet.Range('R1').ColumnWidth = 12.33;
    hSheet.Range('R1:R2').MergeCells = 1;
    
    hSheet.Range('S1').Value = [ 'Signal Max. Value',char( 10 ),'(phys)', char( 10 ), '物理最大值'];
    hSheet.Range('S1').ColumnWidth = 12.33;
    hSheet.Range('S1:S2').MergeCells = 1;
    
    hSheet.Range('T1').Value = [ 'Initial Value',char( 10 ),'(Hex)', char( 10 ), '初始值' ];
    hSheet.Range('T1').ColumnWidth = 8.11;
    hSheet.Range('T1:T2').MergeCells = 1;
    
    hSheet.Range('U1').Value = [ 'Invalid Value',char( 10 ),'(Hex)', char( 10 ), '无效值' ];
    hSheet.Range('U1').ColumnWidth = 8.11;
    hSheet.Range('U1:U2').MergeCells = 1;
    
    hSheet.Range('V1').Value = [ 'Unit', char( 10 ), '单位'];
    hSheet.Range('V1').ColumnWidth = 8.11;
    hSheet.Range('V1:V2').MergeCells = 1;
    
    hSheet.Range('W1').Value = [ 'Node', char( 10 ), '节点'];
    
    hSheet.Range('1:2').Font.name='Arial';  %设置单元格字体
    hSheet.Range('1:2').Font.size=10;  %设置单元格字体大小
    hSheet.Range('1:2').HorizontalAlignment=3;  %设置单元格对齐方式横向居中,对齐方式与软件下拉列表顺序一致，1-8分别为：常规、靠左（缩进）、居中、靠右（缩进）、填充、两端对齐、跨列居中、分散对齐（缩进）
    hSheet.Range('1:2').VerticalAlignment=1;  %设置单元格对齐方式竖直方向居中，对齐方式与软件下拉列表顺序一致，1-5分别为：、靠上、居中、靠下、两端对齐、分散对齐
    %设置单元格字体格式为加粗，0为关闭，1为启用，斜体同理用italic，下划线underline，
    hSheet.Range('1:2').Font.bold=1;
    hSheet.Range('1:2').Font.italic=1;

    for idx=1:numel(Nodes)
        ColIdxStr = Num2ColumnIdxStr(22+idx);
        hSheet.Range([ColIdxStr,'2']).Value = Nodes{idx};
        hSheet.Range([ColIdxStr,':',ColIdxStr]).ColumnWidth=3;
        hSheet.Range([ColIdxStr,'2']).HorizontalAlignment=3;
        hSheet.Range([ColIdxStr,'2']).VerticalAlignment=1;
        hSheet.Range([ColIdxStr,'2']).Orientation = 90;  % 设定文字角度
    end

    hSheet.Range(['W1:',ColIdxStr,'1']).MergeCells = 1;
    hSheet.Range(['A1:',ColIdxStr,'2']).Interior.Color=16764210; %蓝色为16764210
    
    for j = 1:size( msgInfoList, 2 )
        
        % 获取行号，在此基础上新建一行
        UsedRowNum = hSheet.UsedRange.Rows.Count;
        MsgStartRowNumStr = num2str(UsedRowNum+1);
        
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.name='Arial';  %设置单元格字体
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.size=10;  %设置单元格字体大小
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.bold=1;
        hSheet.Range(['A',MsgStartRowNumStr,':',ColIdxStr,MsgStartRowNumStr]).Interior.Color=16764210; %蓝色为16764210
        
        hSheet.Range(['A',MsgStartRowNumStr]).Value = msgInfoList( 1, j ).name;

        fullMsgID = dec2bin( str2num( msgInfoList( 1, j ).id ), 32 );
        MsgID = bin2dec( fullMsgID( 4:end  ) );
        decMsgID = MsgID;
        hexMsgID = dec2hex( decMsgID, 8 );
        
        hSheet.Range(['B',MsgStartRowNumStr]).Value = 'Normal';
        hSheet.Range(['C',MsgStartRowNumStr]).Value = [ '0x', hexMsgID ];
        
        MsgSendType = msgInfoList( 1, j ).sendType;
        if strcmp(MsgSendType,'IfActive')
            hSheet.Range(['D',MsgStartRowNumStr]).Value = MsgSendType;
        elseif strcmp(MsgSendType,'Cyclic')
            hSheet.Range(['D',MsgStartRowNumStr]).Value = 'Cycle';
        end
        
        hSheet.Range(['E',MsgStartRowNumStr]).Value = str2num( msgInfoList( 1, j ).cycleTime );
        hSheet.Range(['F',MsgStartRowNumStr]).Value = str2num( msgInfoList( 1, j ).dlc );
        hSheet.Range(['H',MsgStartRowNumStr]).Value = msgInfoList( 1, j ).comment;
        hSheet.Range(['H',MsgStartRowNumStr]).Font.name='宋体';
        
        for NodIdx = 1 : length(Nodes)
            if strcmp(Nodes{NodIdx},msgInfoList( 1, j ).sender)
                hSheet.Range([Num2ColumnIdxStr(22+NodIdx),MsgStartRowNumStr]).Value = 'S';
                break;
            end
        end
        
        if ~isempty( msgInfoList( j ).sigInfoList )
            SigStartRowNumStr = num2str(hSheet.UsedRange.Rows.Count+1);
            for jj = 1:size( msgInfoList( 1, j ).sigInfoList, 2 )
                UsedRowNum = hSheet.UsedRange.Rows.Count;
                CurrRowNumStr = num2str(UsedRowNum+1);
                
                % 信号名称
                hSheet.Range(['G',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).name;
                
                % 信号描述
                hSheet.Range(['H',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).comment;
                
                
                % 排列格式
                if ( msgInfoList( 1, j ).sigInfoList( 1, jj ).formatIsMot )
                    hSheet.Range(['J',CurrRowNumStr]).Value = 'Motolora';
                else 
                    hSheet.Range(['J',CurrRowNumStr]).Value = 'Intel';
                end 
                
                % 起始位
                if ( msgInfoList( 1, j ).sigInfoList( 1, jj ).formatIsMot )
                    LSB = zeros( 8, 8 );
                    for Li = 1:8
                        for Lj = 1:8
                            LSB( Li, Lj ) = 8 * Li - Lj;
                        end 
                    end 
                    invLSB = LSB';
                    startBit = msgInfoList( 1, j ).sigInfoList( 1, jj ).startBit;
                    wordLen = msgInfoList( 1, j ).sigInfoList( 1, jj ).wordLen;
                    sigLSB = invLSB( find( invLSB == startBit ) + wordLen - 1 );
                    hSheet.Range(['L',CurrRowNumStr]).Value = sigLSB;
                else
                    sigLSB = msgInfoList( 1, j ).sigInfoList( 1, jj ).startBit;
                    hSheet.Range(['L',CurrRowNumStr]).Value = sigLSB;
                end
                
                % 起始字节
                hSheet.Range(['K',CurrRowNumStr]).Value = fix(sigLSB/8);
                
                % 信号发送类型
                SigSendType = msgInfoList( 1, j ).sigInfoList( 1, jj ).sendType;
                if strcmp( SigSendType,'Cyclic' )
                    hSheet.Range(['M',CurrRowNumStr]).Value = 'Cycle';
                elseif strcmp( SigSendType,'IfActive' )
                    hSheet.Range(['M',CurrRowNumStr]).Value = SigSendType;
                end
                
                % 信号长度
                hSheet.Range(['N',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).wordLen;
                
                % 数据类型
                if ( msgInfoList( 1, j ).sigInfoList( 1, jj ).isSigned )
                    hSheet.Range(['O',CurrRowNumStr]).Value = 'Signed';
                else 
                    hSheet.Range(['O',CurrRowNumStr]).Value = 'Unsigned';
                end 
                
                sigFactor = msgInfoList( 1, j ).sigInfoList( 1, jj ).factor;
                sigOffset = msgInfoList( 1, j ).sigInfoList( 1, jj ).offset;
                % 精度
                hSheet.Range(['P',CurrRowNumStr]).Value = sigFactor;
                % 偏移量
                hSheet.Range(['Q',CurrRowNumStr]).Value = sigOffset;
                % 物理最小值
                hSheet.Range(['R',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).min;
                % 物理最大值
                hSheet.Range(['S',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).max;
                % 信号初始值
                initVal_Hex = dec2hex(msgInfoList( 1, j ).sigInfoList( 1, jj ).initVal * sigFactor + sigOffset);
                hSheet.Range(['T',CurrRowNumStr]).Value = [ '0x', initVal_Hex ];
                % 信号无效值，不填写此内容，DBC中无此定义
%                 hSheet.Range(['U',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).invalidVal;
                
                % 单位
                sigUnit = msgInfoList( 1, j ).sigInfoList( 1, jj ).unit;
                sigUnit = strrep( sigUnit, '1/min', 'rpm' );

                if ~isempty( sigUnit )
                    hSheet.Range(['V',CurrRowNumStr]).Value = sigUnit;
                end
                
                % 信号接收节点
                receiver = {};
                sigReceiver = msgInfoList( 1, j ).sigInfoList( 1, jj ).receiver;
                if ~strcmp(sigReceiver,'Vector__XXX')
                    receiver = regexp( sigReceiver, '\,+', 'split' );
                    receiver = receiver';
                    for RcveIdx=1:size(receiver,1)
                        for NodeIndex = 1 : length(Nodes)
                            if strcmp(Nodes{NodeIndex},receiver{RcveIdx})
                                hSheet.Range([Num2ColumnIdxStr(22+NodeIndex),CurrRowNumStr]).Value = 'R';
                                break;
                            end
                        end
                    end
                end
                
                % 信号值描述
                count0x = 0;
                if ~isempty( msgInfoList( 1, j ).sigInfoList( 1, jj ).sigVal )
                    exp_sigVal = '(\d+)\s*[=:：]\s*(([^;]){1,})(;)?';
                    tok_sigVal = regexp( msgInfoList( 1, j ).sigInfoList( 1, jj ).sigVal, exp_sigVal, 'tokens' );
                    sigVal = '';
                    if size( tok_sigVal, 2 ) == 1
                        UpdateXlsInfoList( [ 'There is an error in Signal Comment. Please check signal : ', msgInfoList( 1, j ).sigInfoList( 1, jj ).name ] );
                    else 
                        for i_tok = 1:size( tok_sigVal, 2 ) - 1

                            if isempty( regexpi( tok_sigVal{ 1, i_tok }{ 1, 2 }, 'not(\s+)?use(d)?|Reserve(d)?', 'match' ) )
                                sigVal = [ sigVal, '0x', dec2hex( str2num( tok_sigVal{ 1, i_tok }{ 1, 1 } ) ), ' : ', strtrim( tok_sigVal{ 1, i_tok }{ 1, 2 } ),char( 10 ) ];
                                count0x = count0x + 1;
                            end 
                        end 
                        sigVal = [ sigVal, '0x', dec2hex( str2num( tok_sigVal{ 1, i_tok + 1 }{ 1, 1 } ) ), ' : ', strtrim( tok_sigVal{ 1, i_tok + 1 }{ 1, 2 } )];
                        count0x = count0x + 1;

                        if count0x < 2 ^ msgInfoList( 1, j ).sigInfoList( 1, jj ).wordLen
                            sigVal = [ sigVal, char( 10 ), 'others : Reserved' ];
                        end 
                    end 
                else 
                    if ~isempty( sigUnit ) && ~strcmp( sigUnit, '-' )
                        sigVal = [ 'Linear:', char( 10 ),  ...
                        ' - resolution: ', num2str( sigFactor ), sigUnit, ' per bit', char( 10 ),  ...
                        ' - offset: ', num2str( sigOffset ),  ...
                         ];
                    else 
                        sigVal = '';
                    end 
                end 
                hSheet.Range(['I',CurrRowNumStr]).Value = sigVal;

            end 
            SigEndRowNumStr = num2str(hSheet.UsedRange.Rows.Count+1);
            hSheet.Range([SigStartRowNumStr,':',SigEndRowNumStr]).Group;
            
        else 
            % Do nothing
        end 
    end

    UsedRowNum = hSheet.UsedRange.Rows.Count;
    CurrRowNumStr = num2str(UsedRowNum+1);
    hSheet.Range(['A1:',[ColIdxStr,CurrRowNumStr]]).Borders.LineStyle = 1;
    hWorkbooks.SaveAs([ ExcelPath, ExcelFile ]);
    Quit(hExcel);
    delete(hExcel);
    UpdateXlsInfoList('Excel文件已生成---');
    winopen(ExcelPath);
end

function [ msgInfoList ] = readDbcFile( dbcName )
    UpdateXlsInfoList( [ '>> Reading file ', dbcName, ' ...' ] );
    i = 1;

    dbc_fp = fopen( dbcName, 'r' );

    eol = sprintf( '\n' );

    if  - 1 == dbc_fp
        error( 'Can not open the file' );
    else 
        rexpMsgHeader = '^\s*BO_\s+(\d+)\s+(\w+)\s*:\s*(\d{1,1})\s*(\w*)';
        rexpSignal = '^\s+SG_\s+(\w+)\s+(\w*)\s*:\s*(\d{1,2})\|(\d{1,2})@(0|1)(+|-)\s*\(\s*([0-9+\-.eE]+)\s*,\s*([0-9+\-.eE]+)\s*\)\s*\[\s*([0-9+\-.eE]+)\|\s*([0-9+\-.eE]+)\s*\]\s*"([^"]*)"\s*(.+)$';
        rexpMsgCmt = '^\s*CM_\s+BO_\s+(\d+)\s+"(.*)(";$)?';
        rexpSigCmt = '^\s*CM_\s+SG_\s+(\d+)\s+(\w+)\s*"(.*)(";$)?';
        rexpAttrDeclare = '^BA_DEF_\s+(\w+)?\s+"(\w+)"\s+(\w+)\s+';
        rexpAttrDefault = '^BA_DEF_DEF_\s+"(\w+)"\s+"?(\w+)"?;$';
        rexpAttrSetting = '^BA_\s+"(\w+)"\s+(.+);$';
        rexpSigVal = '^\s*VAL_\s+(\d+)\s+(\w+)\s*(.*);$';
        while ( ~feof( dbc_fp ) )
            j = 1;
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 

            tok = regexp( line, rexpMsgHeader, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                tok{ 1 } = num2str( str2num( tok{ 1 } ) );
                msgInfoList( i ).id = tok{ 1 };
                msgInfoList( i ).name = tok{ 2 };
                msgInfoList( i ).dlc = tok{ 3 };
                msgInfoList( i ).sender = tok{ 4 };
                msgInfoList( i ).receiver = '';

                msgInfoList( i ).cycleTime = '';
                msgInfoList( i ).sendType = '';
                msgInfoList( i ).sigInfoList = '';
                msgInfoList( i ).comment = '';

                while ( 1 )
                    line = fgetl( dbc_fp );
                    if ~ischar( line )
                        break ;
                    end 
                    tok = regexp( line, rexpSignal, 'tokens' );

                    if ( ~isempty( tok ) )
                        tok = tok{ 1 }';

                        msgInfoList( i ).sigInfoList( j ).name = tok{ 1 };
                        if isempty( tok{ 2 } )
                            msgInfoList( i ).sigInfoList( j ).isMulti = '-';
                        else 
                            msgInfoList( i ).sigInfoList( j ).isMulti = tok{ 2 };
                        end 
                        msgInfoList( i ).sigInfoList( j ).startBit = str2num( tok{ 3 } );
                        msgInfoList( i ).sigInfoList( j ).wordLen = str2num( tok{ 4 } );
                        msgInfoList( i ).sigInfoList( j ).formatIsMot = strcmp( char( tok{ 5 } ), '0' );
                        msgInfoList( i ).sigInfoList( j ).isSigned = strcmp( tok{ 6 }, '-' );
                        msgInfoList( i ).sigInfoList( j ).factor = str2num( tok{ 7 } );
                        msgInfoList( i ).sigInfoList( j ).offset = str2num( tok{ 8 } );
                        msgInfoList( i ).sigInfoList( j ).min = str2num( tok{ 9 } );
                        msgInfoList( i ).sigInfoList( j ).max = str2num( tok{ 10 } );
                        msgInfoList( i ).sigInfoList( j ).unit = tok{ 11 };
                        msgInfoList( i ).sigInfoList( j ).receiver = tok{ 12 };

                        msgInfoList( i ).sigInfoList( j ).initVal = 0;
                        msgInfoList( i ).sigInfoList( j ).invalidVal = '';
                        msgInfoList( i ).sigInfoList( j ).sendType = '';
                        msgInfoList( i ).sigInfoList( j ).sigVal = '';
                        msgInfoList( i ).sigInfoList( j ).comment = '';
                        msgInfoList( i ).sigInfoList( j ).spn = '';


                        receiver = msgInfoList( i ).sigInfoList( j ).receiver;
                        receiver = regexp( receiver, '\,+', 'split' );
                        for n = 1:length( receiver )
                            if ismember( receiver( n ), msgInfoList( i ).receiver ) || strcmp( receiver( n ), 'Vector__XXX' )
                                continue ;
                            else 
                                msgInfoList( i ).receiver = [ msgInfoList( i ).receiver, receiver( n ) ];
                            end 
                        end 

                        j = j + 1;
                    else 
                        break ;
                    end 
                end 

                len = length( msgInfoList( i ).sigInfoList );
                if len > 1
                    for k = 2:len
                        % 同一帧报文只能有一种格式
                        if ~isequal( msgInfoList( i ).sigInfoList( 1 ).formatIsMot, msgInfoList( i ).sigInfoList( k ).formatIsMot )
                            error( [ 'The signal format of ', msgInfoList( i ).sigInfoList( k ).name, ' is different from others inside message ', msgInfoList( i ).name ] );
                            break ;
                        end 
                    end 
                end 

                i = i + 1;
            end 
        end 
        
        % 报文注释获取
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end

        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 

            tok = regexp( line, rexpMsgCmt, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                tempMsgCmt = tok{ 2 };
                while size( line, 2 ) < 2 || ~strcmp( line( end  - 1:end  ), '";' )
                    line = fgetl( dbc_fp );
                    if ~ischar( line )
                        break ;
                    end 
                    if size( line, 2 ) < 2
                        tempMsgCmt = [ tempMsgCmt, char( 10 ), line ];
                    else 
                        tok1 = regexp( line, '(.*)(";$)?', 'tokens' );
                        tok1 = tok1{ 1 }';
                        tempMsgCmt = [ tempMsgCmt, char( 10 ), tok1{ 1 } ];
                    end 
                end 

                tok2 = regexp( tempMsgCmt, '(.*)(";)$', 'tokens' );
                tok2 = tok2{ 1 }';
                tempMsgCmt = tok2{ 1 };
                for k = 1:length( msgInfoList )
                    if ( strcmp( msgInfoList( k ).id, tok{ 1 } ) )
                        msgInfoList( k ).comment = tempMsgCmt;
                        break ;
                    end 
                end 
            end 
        end 
        
        % 信号注释获取
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end 
        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 

            tok = regexp( line, rexpSigCmt, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                tempSigCmt = tok{ 3 };
                while size( line, 2 ) < 2 || ~strcmp( line( end  - 1:end  ), '";' )
                    line = fgetl( dbc_fp );
                    if ~ischar( line )
                        break ;
                    end

                    if size( line, 2 ) < 2
                        tempSigCmt = [ tempSigCmt, char( 10 ), line ];
                    else 
                        tok1 = regexp( line, '(.*)(";$)?', 'tokens' );
                        tok1 = tok1{ 1 }';
                        tempSigCmt = [ tempSigCmt, char( 10 ), tok1{ 1 } ];
                    end 
                end 

                tok2 = regexp( tempSigCmt, '(.*)(";)$', 'tokens' );
                tok2 = tok2{ 1 }';
                tempSigCmt = tok2{ 1 };
                for k = 1:length( msgInfoList )
                    for m = 1:length( msgInfoList( k ).sigInfoList )
                        if ( strcmp( msgInfoList( k ).sigInfoList( m ).name, tok{ 2 } ) )
                            msgInfoList( k ).sigInfoList( m ).comment = tempSigCmt;
                            break ;
                        end 
                    end 
                end 
            end 
        end 
        
        % 属性定义信息获取
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end 
        iA = 1;
        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end

            tok = regexp( line, rexpAttrDeclare, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                switch tok{ 1 }
                    case 'SG_'
                        Attribute( iA ).TypeOfObject = 'Signal';
                    case 'BO_'
                        Attribute( iA ).TypeOfObject = 'Message';
                    case 'BU_'
                        Attribute( iA ).TypeOfObject = 'Node';
                    case ''
                        Attribute( iA ).TypeOfObject = 'Network';
                    otherwise 
                        Attribute( iA ).TypeOfObject = '-';
                end 

                Attribute( iA ).Name = tok{ 2 };
                Attribute( iA ).ValueType = tok{ 3 };
                switch tok{ 3 }
                    case 'STRING'
                        Attribute( iA ).Min = '-';
                        Attribute( iA ).Max = '-';
                        Attribute( iA ).Default = '';
                    case 'ENUM'
                        Attribute( iA ).Min = '-';
                        Attribute( iA ).Max = '-';
                        tok1 = regexp( line, '"(\w+)"(,|;)', 'tokens' );
                        if ( ~isempty( tok1 ) )
                            for jA = 1:size( tok1, 2 )
                                Attribute( iA ).ValueRange{ jA } = tok1{ jA }{ 1 };
                            end 
                        end 
                        Attribute( iA ).Default = '';
                    case 'INT'
                        tok1 = regexp( line, '^BA_DEF_\s+\w*\s+"\w+"\s+\w+\s+(\d+)\s+(\d+);$', 'tokens' );
                        if ( ~isempty( tok1 ) )
                            tok1 = tok1{ 1 }';
                        end 
                        Attribute( iA ).Min = tok1{ 1 };
                        Attribute( iA ).Max = tok1{ 2 };
                        Attribute( iA ).Default = 0;
                    case 'HEX'
                        tok1 = regexp( line, '^BA_DEF_\s+\w*\s+"\w+"\s+\w+\s+(\d+)\s+(\d+);$', 'tokens' );
                        if ( ~isempty( tok1 ) )
                            tok1 = tok1{ 1 }';
                        end 
                        Attribute( iA ).Min = tok1{ 1 };
                        Attribute( iA ).Max = tok1{ 2 };
                        Attribute( iA ).Default = 0;
                        otherwise 
                        Attribute( iA ).Min = '-';
                        Attribute( iA ).Max = '-';
                        Attribute( iA ).Default = '';
                end 
                iA = iA + 1;
            end 
        end 
        
        % 属性默认定义获取
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end

        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 
            tok = regexp( line, rexpAttrDefault, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                for iA = 1:size( Attribute, 2 )
                    if ( strcmp( tok{ 1 }, Attribute( iA ).Name ) )
                        Attribute( iA ).Default = tok{ 2 };
                    end 
                end 
            end 
        end 
        
        
        for i = 1:length( Attribute )
            switch Attribute( i ).TypeOfObject
                case 'Network'
                case 'Node'
                case 'Message'
                    for k = 1:length( msgInfoList )
                        switch Attribute( i ).Name
                            case 'GenMsgSendType'
                                msgInfoList( k ).sendType = Attribute( i ).Default;
                            case 'GenMsgCycleTime'
                                msgInfoList( k ).cycleTime = num2str( Attribute( i ).Default );
                            otherwise 
                                eval( [ 'msgInfoList(k).', Attribute( i ).Name, '= Attribute(i).Default;' ] );
                        end 
                    end 
                case 'Signal'
                    for k = 1:length( msgInfoList )
                        for m = 1:length( msgInfoList( k ).sigInfoList )
                            switch Attribute( i ).Name
                                case 'GenSigStartValue'
                                    msgInfoList( k ).sigInfoList( m ).initVal = str2num( Attribute( i ).Default );
                                case 'GenSigInactiveValue'
                                    msgInfoList( k ).sigInfoList( m ).invalidVal = str2num( Attribute( i ).Default );
                                case 'GenSigSendType'
                                    msgInfoList( k ).sigInfoList( m ).sendType = Attribute( i ).Default;
                                case 'GenSigSPN'
                                    msgInfoList( k ).sigInfoList( m ).spn = Attribute( i ).Default;
                                otherwise 
                                    eval( [ 'msgInfoList(k).sigInfoList(m).', Attribute( i ).Name, '= Attribute(i).Default;' ] );
                            end 
                        end 
                    end 
                otherwise 
            end 
        end 
        
        % 获取报文发送类型、周期及信号初始值等信息
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end
        
        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 
            tok = regexp( line, rexpAttrSetting, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                for i = 1:length( Attribute )
                    if ( strcmp( tok{ 1 }, Attribute( i ).Name ) )
                        switch Attribute( i ).TypeOfObject
                            case 'Network'
                            case 'Node'
                            case 'Message'
                                tok1 = regexp( line, '^BA_\s+"\w+"\s+BO_\s+(\d+)\s+(\w+);$', 'tokens' );
                                if ( ~isempty( tok1 ) )
                                    tok1 = tok1{ 1 }';
                                    for k = 1:length( msgInfoList )
                                        if ( strcmp( msgInfoList( k ).id, tok1{ 1 } ) )
                                            switch Attribute( i ).Name
                                                case 'GenMsgSendType'
                                                    if str2num(tok1{ 2 }) < length(Attribute( i ).ValueRange)
                                                        msgInfoList( k ).sendType = Attribute( i ).ValueRange{str2num(tok1{ 2 })+1};
                                                    else
                                                        msgInfoList( k ).sendType = Attribute( i ).Default;
                                                    end
                                                case 'GenMsgCycleTime'
                                                    cycle = str2num( tok1{ 2 } );
                                                    tmp = floor( cycle / 10 ) * 10;
                                                    if ~isequal( cycle, tmp )
                                                        disp( [ 'The cycle of message ', msgInfoList( k ).name, ' is not times of 10ms' ] );
                                                        disp( [ 'Change its cycle time to ', num2str( tmp ), ' ms' ] );
                                                        disp( ' ' );
                                                    end 
                                                    msgInfoList( k ).cycleTime = num2str( tmp );
                                                otherwise 
                                                    eval( [ 'msgInfoList(k).', Attribute( i ).Name, '= tok1{2};' ] );
                                            end 
                                            break ;
                                        end 
                                    end 
                                end 
                            case 'Signal'
                                tok1 = regexp( line, '^BA_\s+"\w+"\s+SG_\s+(\d+)\s+(\w+)\s+(\w+);$', 'tokens' );
                                if ( ~isempty( tok1 ) )
                                    tok1 = tok1{ 1 }';
                                    for k = 1:length( msgInfoList )
                                        if ( strcmp( msgInfoList( k ).id, tok1{ 1 } ) )
                                            for m = 1:length( msgInfoList( k ).sigInfoList )
                                                if ( strcmp( msgInfoList( k ).sigInfoList( m ).name, tok1{ 2 } ) )
                                                    switch Attribute( i ).Name
                                                        case 'GenSigStartValue'
                                                            msgInfoList( k ).sigInfoList( m ).initVal = str2num( tok1{ 3 } );
                                                        case 'GenSigInactiveValue'
                                                            msgInfoList( k ).sigInfoList( m ).invalidVal = ['0x',dec2hex(str2num( tok1{ 3 } ))];
                                                        case 'GenSigSendType'
                                                            msgInfoList( k ).sigInfoList( m ).sendType = tok1{ 3 };
                                                        case 'GenSigSPN'
                                                            msgInfoList( k ).sigInfoList( m ).spn = tok1{ 3 };
                                                        otherwise 
                                                            eval( [ 'msgInfoList(k).sigInfoList(m).', Attribute( i ).Name, '= tok1{3};' ] );
                                                    end 
                                                    break;
                                                end 
                                            end 
                                            break ;
                                        end 
                                    end 
                                end 
                            otherwise 
                        end 
                        break ;
                    end 
                end 
            end 
        end
        
        % 信号值定义获取
        status = fseek( dbc_fp, 0, 'bof' );
        if (  - 1 == status )
            error( 'cannot set the position indicator' );
        end 
        while ( ~feof( dbc_fp ) )
            line = fgetl( dbc_fp );
            if ~ischar( line )
                break ;
            end 
            tok = regexp( line, rexpSigVal, 'tokens' );
            if ( ~isempty( tok ) )
                tok = tok{ 1 }';
                findVal = 0;
                for k = 1:length( msgInfoList )
                    for m = 1:length( msgInfoList( k ).sigInfoList )
                        if ( strcmp( msgInfoList( k ).sigInfoList( m ).name, tok{ 2 } ) )
                            findVal = 1;
                            tok = regexp( tok{ 3 }, '[""]', 'split' );
                            sig_val = '';
                            for n = 1:2:length( tok ) - 1
                                tok{ n } = strrep( tok{ n }, ' ', '' );

                                tok{ n + 1 } = strtrim( tok{ n + 1 } );

                                if isempty( regexp( tok{ n + 1 }, ';$', 'match' ) )
                                    tok{ n + 1 } = [ tok{ n + 1 }, ';' ];
                                end 
                                sig_val = [ sig_val, tok{ n }, ':', tok{ n + 1 }, eol ];
                            end 
                            msgInfoList( k ).sigInfoList( m ).sigVal = sig_val;
                            break ;
                        end 
                    end 

                    if findVal == 1
                        break;
                    end 
                end 
            end 
        end 

    end 

    msgInfoList = sortMsgInfoList( msgInfoList );

    fclose( dbc_fp );

    UpdateXlsInfoList( [ '## The DBC file ', dbcName, ' has been sucessfully read.' ] );
end 

function msgInfoList = sortMsgInfoList( msgInfoList )
    for m = 1:length( msgInfoList )
        numOfSig = length( msgInfoList( m ).sigInfoList );
        for n = 1:numOfSig
            for k = n:numOfSig
                cur_sig_start_bit = msgInfoList( m ).sigInfoList( n ).startBit;
                next_sig_start_bit = msgInfoList( m ).sigInfoList( k ).startBit;
                if ( cur_sig_start_bit > next_sig_start_bit )
                    tmpSigInfoList = msgInfoList( m ).sigInfoList( k );
                    msgInfoList( m ).sigInfoList( k ) = msgInfoList( m ).sigInfoList( n );
                    msgInfoList( m ).sigInfoList( n ) = tmpSigInfoList;
                end 
            end 
        end 
    end 
end

function Str = Num2ColumnIdxStr(Num)
    if Num>0
        CC = mod(Num,26);
        DD = fix(Num/26);
        if DD >0
            Str = [char(DD+64),char(CC+64)];
        else
            Str = char(CC+64);
        end
    else
        % 列数异常，至少应该为1列
    end
end
