%-------------------------------------------------------------------------------------------
%Author  : FanYANG
%version : V2.1.3
%Modofy date:   2021/07/26  ��  ��    �����ļ����ͷ��װ湦��
%               2022/03/11  ��轭    �ļ�����������.xls,�����¶����׼ģ���޸��������
%               2022/03/14  ��轭    ���ļ���Ϊfunction���Ա��Զ�����м���̲���������
%                                    ������dbc�߼������������µ�function�У��Ա�ͬһ��
%                                    excel�ļ���ͬ�������Ӧ��ͬ��DBC����
%               2022/03/21  ��轭    �������ĳɱ��������������޸�
%               2022/03/24  ��轭    �޸���ȡxlsinfo��ȡ����ʱ��·�����²���һĿ¼��ʧ������
%               2022/03/25  ��轭    1���޸�excel������ݶ�ȡ�г�������
%                                     2�����Ӳ���ǿ����ֵ��Ԫ��ĸ�ʽ�ж���������ֿո�򻻵���
%                                        ���������ļ��﷨��������
%                                     3�����ӱ���ע�͵�����д��
%               2022/03/25   ��轭   1�������ź����ظ������鹦��
%               2022/04/11   ��轭   1��ȥ���ź���ʼλ�뷢���������ƣ�����ʱ������������д����
%               2022/07/09   ��轭   1�����ӷ���������Ϣд��
%               2022/08/18   ��轭   1�������ʼֵ��������
%               2022/09/27   ��轭   1���޸��ı���ʽ�����UNIX��ʽINCA�޷���ȡ���⣬
%                                        �ĳ�Windows/DOS�ļ���ʽ
%               2022/09/29   ��轭   1���޸�IfActiveʱ�����������������������
%               2022/09/29   ��轭   1���޸����ַ��а�������"%"ʱ����matlabע������
%               2022/09/29   ��轭   1���޸�Motorola LSB�ֽ�˳���ʽ�ź���ʼλ�趨��������
%               2022/10/02   ��轭   1���޸�Motorrola LSB�ֽ�˳���źſ��ֽ���ʼλ�趨��������
%               2022/10/11   ��轭   1�����ɾ���ѡ��ʽ�޸�Ϊ�����б�ѡ���Թ������������ͬʱ����
%                                     2���ļ�����������Excel2DBC_Coverter��ΪExcel2DBC
%               2022/11/08   ��轭   1���޸�Ϊfig���ڷ�ʽ����
%                                     2�����Ӽ������ɷ�ʽ�����ڶ���������һ��DBC
%                                     3������ValueTable�Ƿ�����ѡ����ʱ���ڽ��INCA7.3����VT
%                                        ʱ�ɹ۲ⲻ�ɼ�¼����
%               2022/11/14   ��轭   1���޸���ͬ���������ظ��ź��޷���������
%               2022/11/23   ��轭   1�����ļ����󣬸ĳɽű�ֱ�����ɵ�����ʽ
%                                     2������dbcת����xlsģʽ����Tab�л���Ԥ��
%               2022/12/01   ��轭   1���ļ�����ΪDBCTools.m
%               2022/12/09   ��轭   1������DBCת����excel�����ܣ�
%               2022/12/19   ��轭   1���޸��ź�ֵ����������ָ�����м��пո����������DBC����VT����
%                                     2������excel��Ԫ�����������Ч������
%               2022/12/20   ��轭   1������WPS����excel�ļ�
%                                     2����������÷�ʽ��Ϊ�������ã�����WPS��ʽ
%                                     3�������źŽ��սڵ㶨��
%                                     4���ر���Чֵ������д
%               2023/03/16   ��轭   1���޸�ֵ������ʮ��������ʹ��ʮ������ת������
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
    
    StrTemp = 'DBC����';
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
                                        'String', '��ſƼ��������ƿ�����DBC����');

    GUI_DBCTool.VersionTxt = uicontrol('Parent', GUI_DBCTool.FigHndl,...
                                        'Style', 'text',...
                                        'Position', [ 530, 470, 80, 36 ],  ...
                                        'FontSize',14,...
                                        'String', VersionStr);
    % ���panel                                
    GUI_DBCTool.FuncFig = uipanel( 'Parent', GUI_DBCTool.FigHndl, 'units', 'pixels',  ...
                                   'Title', char( [  ] ), 'Position', [ 0, 0, 650, 480 ], 'Visible', 'on' );
    
    % ���Tab                               
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
                                    'String', 'Excel·����');
    
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
                                       'String', '�ļ�ѡ��',  ...
                                       'Callback', @FileSel_Callback);

    GUI_DBCTool.DBCNameTxt = uicontrol('Parent', GenDbcTab, 'Style', 'text',...
                                        'Position', [ 10, 345, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', 'DBC���ƣ�');

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
                                         'String', 'Sheet����');

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
                                     'String', { '��������';'��������' });

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
                                       'String', '�����ʾ�б�',  ...
                                       'Callback', @ClearList_Callback);
                                   
   GUI_DBCTool.GenDbcBtn = uicontrol('Parent', GenDbcTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 205, 80, 120 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '����DBC',  ...
                                       'Callback', @GenDBC_Callback);
   
    GUI_DBCTool.InfoTxt = uicontrol('Parent', GenDbcTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 120, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '��Ϣ��ʾ��');

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
                                    'String', 'DBC·����');
    
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
                                          'String', '�ļ�ѡ��',  ...
                                          'Callback', @DBCFileSel_Callback);

    GUI_DBCTool.ProjectTxt = uicontrol('Parent', GenFileTab, 'Style', 'text',...
                                        'Position', [ 10, 340, 90, 30 ],  ...
                                        'FontSize',12,...
                                        'HorizontalAlignment','left',...
                                        'String', '��Ŀ��ţ�');

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
                                        'String', '�ڵ�ͨ����');

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
                                       'String', '����Excel',  ...
                                       'Callback', @GenXls_Callback);
                                   
    GUI_DBCTool.ClrXlsListBtn = uicontrol('Parent', GenFileTab,...
                                       'Style', 'pushbutton',...
                                       'Position', [ 550, 262, 80, 50 ],  ...
                                       'FontSize',12,...
                                       'HorizontalAlignment','center',...
                                       'String', '�����ʾ',  ...
                                       'Callback', @ClrXlsList_Callback);
                                   
    GUI_DBCTool.XlsInfoTxt = uicontrol('Parent', GenFileTab,...
                                    'Style', 'text',...
                                    'Position', [ 10, 200, 90, 40 ],  ...
                                    'FontSize',12,...
                                    'HorizontalAlignment','left',...
                                    'String', '��Ϣ��ʾ��');

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
            % �ݲ����κ�����
        end

        [~,SheetNames] = xlsfinfo([ExcelPath,ExcelName]);
        SheetNames = SheetNames';
        try
            set(GUI_DBCTool.SheetNameList, 'String', SheetNames);
            set(GUI_DBCTool.SheetNameList, 'Max', size(SheetNames,1));
            set(GUI_DBCTool.SheetNameList, 'Value', get(GUI_DBCTool.SheetNameList, 'Max'));
            pause(0.001);
            if get(GUI_DBCTool.SheetNameList, 'Max') > 1
                set(GUI_DBCTool.SheetNameList, 'Value', []);    % Ĭ�ϼ��غ�ѡ��
            end
        catch
            % �ݲ����κ�����
        end
    else
        UpdateInfoList('δѡ���ļ�');
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
        UpdateInfoList('Excel�ļ�δ���壬���ɽ�������ֹ������');
        return;
    else
        if contains(ExcelFileInfo,{'.xls','.xlsx'})
            if exist(ExcelFileInfo, 'file')
                backslash = find(ExcelFileInfo == '\', 1, 'last' );
                if isempty(backslash)
                    UpdateInfoList('Excel�ļ�Ŀ¼�쳣�����ɽ�������ֹ������');
                    return;
                else
                    xlsfile_path = ExcelFileInfo(1:backslash);
                    xlsfile_name = ExcelFileInfo(backslash+1:end);
                end
            else
                UpdateInfoList('Excel�ļ�δ�ҵ������ɽ�������ֹ������');
                return;
            end

        else
            UpdateInfoList('Excel�ļ�δ���壬���ɽ�������ֹ������');
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
        UpdateInfoList('Excel�ļ�����������б��в�һ�£�����');
        UpdateInfoList('���ɽ�������ֹ������');
        set(GUI_DBCTool.SheetNameList, 'String', SheetNamesChk);
        set(GUI_DBCTool.SheetNameList, 'Max', size(SheetNamesChk,1));
        pause(0.001);
        if get(GUI_DBCTool.SheetNameList, 'Max') > 1
                set(GUI_DBCTool.SheetNameList, 'Value', []);    % Ĭ�ϼ��غ�ѡ��
        end
        UpdateInfoList('�����Ѹ��£�������ѡ�񣡣���');
        return;
    end

    DBCFileName = get(GUI_DBCTool.DBCNameStr, 'String');
    
    %ɾ������xx.dbc����µĺ�׺
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
    if strcmp(GenStyleStr,'��������')
        UpdateInfoList('----------------------------------------');
        UpdateInfoList('��������ģʽ');
        for Index = 1:numel(SelSheet)
            GenSheetName = SelSheet{Index};
            GenDBCName = strcat(DBCFileName,'_',GenSheetName);
            [ResultFb,CANMsgInfo] = GetCANMsgInfo(xlsfile_path,xlsfile_name,GenSheetName);
            if ResultFb == 1
                ChkResult = MsgInfoCheck(CANMsgInfo);
                if ChkResult == 0
                    UpdateInfoList(['Excel�ļ��� ',xlsfile_path,xlsfile_name,'������',GenSheetName,'���ظ����ȡ��DBC�ļ����ɣ�����']);
                    continue;
                end
                [BO_SG_Content,CM_BO_SG_Content,BA_BO_Content,BA_SG_Content,VAL_Content] = SortMsgInfo(CANMsgInfo);
                % �ڵ���Ϣ����
                MsgNode = CANMsgInfo.Node;
                [Header_content,BU_Content,BA_DEF_Content,BA_Content] = GetCommonInfo(GenDBCName,MsgNode);
                
                % ��Ϣ��������
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

                % дDBC�ļ�
                if exist(fullfile(xlsfile_path, [GenDBCName,'.dbc']), 'file')
                    UpdateInfoList(['ɾ��',xlsfile_path,[GenDBCName,'.dbc'],'�ļ�������']);
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
                UpdateInfoList(['DBC�ļ��� ',xlsfile_path,GenDBCName,' �����ɣ�����']);
            else
                UpdateInfoList(['DBC�ļ��� ',xlsfile_path,GenDBCName,' ����ʧ�ܣ�����ֹ������']);
                continue;      % �д������������һ������
            end
        end
    elseif strcmp(GenStyleStr,'��������')
        
        UpdateInfoList('��������ģʽ');
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
                
                UpdateInfoList(['Excel�ļ��� ',xlsfile_path,xlsfile_name,'������',GenSheetName,'��Ϣ��ȡ���']);
            else
                UpdateInfoList(['Excel�ļ��� ',xlsfile_path,xlsfile_name,'������',GenSheetName,'��Ϣ��ȡ�쳣']);
                UpdateInfoList(['DBC�ļ��� ',xlsfile_path,GenDBCName,' ����ʧ�ܣ�����ֹ������']);
                return;      % �д������������һ������
            end
        end
        
        ChkResult = MsgInfoCheck(CombineMsgInfo);
        
        if ChkResult == 0
            UpdateInfoList(['Excel�ļ��� ',xlsfile_path,xlsfile_name,' �йؼ���ϢID/�ź������ظ����ȡ��DBC�ļ����ɣ�����']);
            return;
        else
        
            % �ڵ���Ϣ����
            [Header_content,BU_Content,BA_DEF_Content,BA_Content] = GetCommonInfo(GenDBCName,CombineMsgInfo.Node);
            [BO_SG_Content,CM_BO_SG_Content,BA_BO_Content,BA_SG_Content,VAL_Content] = SortMsgInfo(CombineMsgInfo);

            % ��Ϣ��������
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

            % дDBC�ļ�
            if exist(fullfile(xlsfile_path, [GenDBCName,'.dbc']), 'file')
                UpdateInfoList(['ɾ��',xlsfile_path,[GenDBCName,'.dbc'],'�ļ�������']);
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
            UpdateInfoList(['DBC�ļ��� ',xlsfile_path,[GenDBCName,'.dbc'],'�����ɣ�����']);
        end
    else
        UpdateInfoList('����ģʽ�쳣');
        return;
    end

    UpdateInfoList('DBC����������ȫ����ɣ�����');
    UpdateInfoList('---------------------------------------------------------');

    if OpenFolder == 1
        winopen(xlsfile_path);      %DBC������ɺ��Զ���·���ļ���
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

% ��ȡexcel����������Ϣ
function [RetResult,MsgInfo,Err_content] = GetCANMsgInfo(FileDir,FileName,GenSheet)
    RetResult = 0;
    CheckPass = 1;
    SameName = 0;
    i = 1;
    j = 1;
    ExcelFile = strcat(FileDir,FileName);
    [~,~,CAN_Matrix_Text] = xlsread(ExcelFile,GenSheet);
    [column_num,row_num] = size(CAN_Matrix_Text);
    
    if column_num < 4   %��׼ģ��������4�вſ������ź�
        UpdateInfoList(['--�ļ�',FileDir,FileName,'������',GenSheet,'������̫�٣�����û���źŶ��壬���飡����']);
        return;
    elseif row_num < 22
        disp(['--�ļ�',FileDir,FileName,'������',GenSheet,'������̫�٣����ܲ��Ǳ�׼����ģ���ʽ�����飡����']);
        return;
    end
    
    % Excel����飬�����һ�����׼ģ�岻һ����ֱ���˳���ǰ����
    Err_content = '';
    if ~contains(cell2mat(CAN_Matrix_Text(1,1)), {'Msg Name','��������'})
        Err_content = [Err_content,'--A��ӦΪ�������ƣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,2)), {'Msg Type','��������'})
        Err_content = [Err_content,'--B��ӦΪ�������ͣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,3)), {'Msg ID(Hex)','���ı�ʶ��'})
        Err_content = [Err_content,'--C��ӦΪ����ʶ��������飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,4)), {'Msg Send Type','���ķ�������'})
        Err_content = [Err_content,'--D��ӦΪ���ķ������ͣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,5)), {'Msg Cycle Time (ms)','��������ʱ��'})
        Err_content = [Err_content,'--E��ӦΪ��������ʱ�䣬���飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,6)), {'Msg Length (Byte)','���ĳ���'})
        Err_content = [Err_content,'--F��ӦΪ���ĳ��ȣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,7)), {'Signal Name','�ź�����'})
        Err_content = [Err_content,'--G��ӦΪ�ź����ƣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,8)), {'Signal Description','�ź�����'})
        Err_content = [Err_content,'--H��ӦΪ�ź����������飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,9)), {'Signal Value Description','�ź�ֵ����'})
        Err_content = [Err_content,'--I��ӦΪ�ź�ֵ���������飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,10)), {'Byte Order','���и�ʽ'})
        Err_content = [Err_content,'--J��ӦΪ���и�ʽ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,11)), {'Start Byte','��ʼ�ֽ�'})
        Err_content = [Err_content,'--K��ӦΪ��ʼ�ֽڣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,12)), {'Start Bit','��ʼλ'})
        Err_content = [Err_content,'--L��ӦΪ��ʼλ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,13)), {'Signal Send Type','�źŷ�������'})
        Err_content = [Err_content,'--M��ӦΪ�źŷ������ͣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,14)), {'Bit Length (Bit)','�źų���'})
        Err_content = [Err_content,'--N��ӦΪ�źų��ȣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,15)), {'Data Type','��������'})
        Err_content = [Err_content,'--O��ӦΪ�������ͣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,16)), {'Resolution','����'})
        Err_content = [Err_content,'--P��ӦΪ���ȣ����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,17)), {'Offset','ƫ����'})
        Err_content = [Err_content,'--Q��ӦΪƫ���������飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,18)), {'Signal Min. Value (phys)','������Сֵ'})
        Err_content = [Err_content,'--R��ӦΪ������Сֵ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,19)), {'Signal Max. Value(phys)','�������ֵ'})
        Err_content = [Err_content,'--S��ӦΪ�������ֵ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,20)), {'Initial Value(Hex)','��ʼֵ'})
        Err_content = [Err_content,'--T��ӦΪ��ʼֵ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,21)), {'Invalid Value(Hex)','��Чֵ'})
        Err_content = [Err_content,'--U��ӦΪ��Чֵ�����飡����',10];
        CheckPass = 0;
    end
    if ~contains(cell2mat(CAN_Matrix_Text(1,22)), {'Unit','��λ'})
        Err_content = [Err_content,'--V��ӦΪ��λ�����飡����',10];
        CheckPass = 0;
    end
    
    % �������׼ģ�岻һ��ʱ��ֱ�ӷ���
    if CheckPass == 0
        Err_content = [10,'--�ļ�',FileDir,FileName,'�Ĺ�����',GenSheet,'��������ģ�岻һ�£����飡����--',10,Err_content];
        UpdateInfoList(Err_content);
        return;
    end

    %��ȡ�ڵ����Ʋ�ƴ�ӣ���23�����һ�У���2���ǽڵ�����
    if row_num > 22    %�޶���ڵ�ʱ��ʹ�ÿսڵ�
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

    for column_index = 3:column_num  %ȥ����1����2���ӵ�3�л�ȡ
        MsgLine = 0;
        Message_Text = CAN_Matrix_Text(column_index,1:row_num);     %���ж�ȡ����������ı�ʱ�޷��Զ���������
        %���л�ȡ��Ϣ��Ϊֱ�ӱ������ݣ�������cell��ʾ
        MsgName = cell2mat(Message_Text(1,1));       %��׼ģ�屨�����ƴ��ڵ�1��
        MsgType = cell2mat(Message_Text(1,2));       %��׼ģ�屨�����ʹ��ڵ�2��
        MsgID = cell2mat(Message_Text(1,3));         %��׼ģ��ID���ڵ�3��
        MsgSendType = cell2mat(Message_Text(1,4));   %��׼ģ�屨�ķ������ʹ��ڵ�4��
        MsgCycleTime = cell2mat(Message_Text(1,5));  %��׼ģ�屨�����ڴ��ڵ�5�� 
        MsgLength = cell2mat(Message_Text(1,6));     %��׼ģ�屨�ĳ��ȴ��ڵ�6��
        
        % ����Ϊ�ź���أ�ɾ��ԭByteNum��BitNum
        SignalName = cell2mat(Message_Text(1,7));     %��׼ģ���ź����ƴ��ڵ�7��
        Comment = cell2mat(Message_Text(1,8));        %��׼ģ���ź�����˵�����ڵ�8��
        ValueDesc = cell2mat(Message_Text(1,9));      %��׼ģ���ź�ֵ�������ڵ�9��
        ByteOrder = cell2mat(Message_Text(1,10));     %��׼ģ���ź����и�ʽ���ڵ�10��
        StartByte = cell2mat(Message_Text(1,11));     %��׼ģ���ź���ʼ�ֽڴ��ڵ�11��
        StartBit = cell2mat(Message_Text(1,12));      %��׼ģ���ź���ʼλ���ڵ�12��
        SendType = cell2mat(Message_Text(1,13));      %��׼ģ���źŷ������ʹ��ڵ�13��
        Length = cell2mat(Message_Text(1,14));        %��׼ģ���źų��ȴ��ڵ�14��
        DataType = cell2mat(Message_Text(1,15));      %��׼ģ���ź��������ʹ��ڵ�15��
        Factor = cell2mat(Message_Text(1,16));        %��׼ģ���źž��ȴ��ڵ�16��
        Offset = cell2mat(Message_Text(1,17));        %��׼ģ���ź�ƫ�������ڵ�17��
        Min = cell2mat(Message_Text(1,18));           %��׼ģ���ź�������Сֵ���ڵ�18��
        Max = cell2mat(Message_Text(1,19));           %��׼ģ���ź��������ֵ���ڵ�19��
        InitValue = cell2mat(Message_Text(1,20));     %��׼ģ���źų�ʼֵ���ڵ�20��
        InvalidValue = cell2mat(Message_Text(1,21));  %��׼ģ���ź���Чֵ���ڵ�21��
        Unit = cell2mat(Message_Text(1,22));          %��׼ģ���źŵ�λ���ڵ�22��

        %ID�ַ����������Ϊ16����д������0x100��0X100��ֻȡX����ַ���
        if ~isnan(MsgID)
            IDString = MsgID;    %��ȡID�ַ���
            if contains(IDString, {'x','X'})    %����x/X��ֻȡx/X����ַ���
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
            
            %����ID��Χȷ���Ƿ����Ϊ��׼֡������0x7FFʱ����Ҫ����Ϊ��չ֡������bit31����
            
            if ~isempty(regexp(IDString,'[^0-9a-fA-F]'))
                MsgLine = 0;
            elseif hex2dec(IDString) > hex2dec('1FFFFFFF')    % 536870911����29Bit���ֵ��Ϊ�Ƿ�ID
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
            
            if MsgLine == 1     %֡������
                MsgInfo.MsgList(i).Name = MsgName;
                MsgInfo.MsgList(i).Type = MsgType;
                MsgInfo.MsgList(i).SendType = MsgSendType;
                MsgInfo.MsgList(i).CycleTime = MsgCycleTime;
                MsgInfo.MsgList(i).Length = MsgLength;
                MsgInfo.MsgList(i).Desc = Comment;
                MsgInfo.MsgList(i).Receiver = '';           %�ݲ�������սڵ�
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
                    
                    if ~strcmpi(MsgNodeStStr,'S')   % �Ƿ��Ͷ��壬ֱ����һѭ��
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
            else                %��֡�����У���Ϊ���ź���
                if ~isnan(SignalName)     %�ź�����Ϊ�ղ���Ϊ�ɶ�ȡ������Ϣ
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
                        
                        if ~strcmpi(SigNodeStStr,'R')   % �ǽ��ն��壬ֱ����һѭ��
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
            if ~isnan(SignalName)     %�ź�����Ϊ�ղ���Ϊ�ɶ�ȡ������Ϣ
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

                    if ~strcmpi(SigNodeStStr,'R')   % �ǽ��ն��壬ֱ����һѭ��
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
    
    % BO SG д��
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
                            UpdateInfoList(['���� ',SignalName,' ������д��ʽ�쳣������ֵ�����飡����']);
                            return;
                        end

                        if ~ismember(ByteOrder,{'Intel','Motorola','Motorola MSB','Motorola LSB'})
                           UpdateInfoList(['���� ',SignalName,' �ֽ�˳����д��ʽ�쳣�����飡����']);
                           return; 
                        end

                        if strcmpi(ByteOrder, 'Intel')
                            if StartBit + Length > 64
                                UpdateInfoList(['���� ',SignalName,' ��ʼλ�볤����д��ƥ�䣬��Խ�����⣬���飡����']);
                                return;
                            else
                                StartBitHndl = StartBit;
                            end
                            ByteOrderStr = '1';
                        elseif strcmpi(ByteOrder, 'Motorola LSB') || strcmpi(ByteOrder, 'Motorola')

                            if StartBit < 0 || StartBit > 63
                                UpdateInfoList(['���� ',SignalName,' ��ʼλ��д���ޣ����飡����']);
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
                                    UpdateInfoList(['���� ',SignalName,' ��ʼλ�볤����д��ƥ�䣬��Խ�����⣬���飡����']);
                                    return;
                                else
                                    StartBitHndl = TransLSB(TransMatrixIdx);
                                end
                            end

                            ByteOrderStr = '0';
                        else
                            UpdateInfoList(['���� ',SignalName,' �ֽ�˳����дΪMotorola MSB����ǰ��δ�����˸�ʽ�ź��Զ����ɹ��ܣ����ֶ���дDBC������']);
                            return;
                        end
                    else
                        UpdateInfoList(['���� ',SignalName,' ��ʼλ��д��ʽ�쳣������ֵ�����飡����']);
                        return;
                    end
            else
                UpdateInfoList('�źŲ��ֹؼ���Ϣδ��䣬���飡����');
                return;
            end

            if strcmpi(DataType, 'Unsigned')    %�ź������趨��0Ϊ�޷��ţ�1Ϊ�з��ţ��������㣩
                DataType = '+ ';
            elseif strcmpi(DataType, 'Signed')
                DataType = '- ';
            else
                UpdateInfoList(['���� ',SignalName,' ����������д��ʽ�쳣�����飡����']);
                return;
            end

            if isnumeric(Factor)
                Factor = num2str(Factor);        %�����趨
            else
                UpdateInfoList(['���� ',SignalName,' ������д��ʽ�쳣������ֵ�����飡����']);
                return;
            end

            if isnumeric(Offset)
                Offset = num2str(Offset);        %ƫ�����趨
            else
                UpdateInfoList(['���� ',SignalName,' ƫ������д��ʽ�쳣������ֵ�����飡����']);
                return;
            end

            if isnumeric(Min)
                Min = num2str(Min);           %��Сֵ�趨
            else
                UpdateInfoList(['���� ',SignalName,' ��Сֵ��д��ʽ�쳣������ֵ�����飡����']);
                return;
            end

            if isnumeric(Max)
                Max = num2str(Max);           %���ֵ�趨
            else
                UpdateInfoList(['���� ',SignalName,' ���ֵ��д��ʽ�쳣������ֵ�����飡����']);
                return;
            end

            if ~isnan(Unit)
                if strcmp(Unit,'%')     % ��λΪ%ʱ��������������matlab��ʶ��ע�ͺ�������
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
            if contains(MsgDesc, {'%'})        % ����'%'���Ϊ'%%%%'������ע�ͺ����ַ�
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
                if contains(SigDesc, {'%'})        % ����'%'���Ϊ'%%%%'������ע�ͺ����ַ�
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
                ValDescStr = strsplit(ValDesc,'\n');    %ͨ����һ�з��ţ�\n��������ַ���
                % �ֽ�д��
                ValDesc = '';
                for ValDescIdx = 1:numel(ValDescStr)
                    if contains(ValDescStr{ValDescIdx},':')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},':');
                        if contains(DescTxt{1}, {'0x','0X'})    %����x/X��ֻȡx/X����ַ�����ʮ�����Ƽ���
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
                                ValNumStr = ValNum;                 % 20230316�޸�
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
                        if contains(ValDesc, {'%'})        % ����'%'���Ϊ'%%'������ע�ͺ����ַ�
                            ValDesc = strrep(ValDesc,'%','%%%%');
                        end
                    elseif contains(ValDescStr{ValDescIdx},'��')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},'��');
                        if contains(DescTxt{1}, {'0x','0X'})    %����x/X��ֻȡx/X����ַ���
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
                                ValNumStr = ValNum;                 % 20230316�޸�
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
                        if contains(ValDesc, {'%'})        % ����'%'���Ϊ'%%'������ע�ͺ����ַ�
                            ValDesc = strrep(ValDesc,'%','%%%%');
                        end
                    elseif contains(ValDescStr{ValDescIdx},'=')
                        DescTxt = strsplit(ValDescStr{ValDescIdx},'=');
                        if contains(DescTxt{1}, {'0x','0X'})    %����x/X��ֻȡx/X����ַ���
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
                                ValNumStr = ValNum;                 % 20230316�޸�
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
                        if contains(ValDesc, {'%'})        % ����'%'���Ϊ'%%'������ע�ͺ����ַ�
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
                if contains(InitValue, {'0x','0X'})    %����x/X��ֻȡx/X����ַ���
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
% ��������[RetChkResult] = MsgInfoCheck(CANMsgInfo)
% �������������CAN������Ϣ
% �޸����ڣ�
%           2022/12/01    xuhongjiang01    �½�����
%--------------------------------------------------------------------------
function [RetChkResult] = MsgInfoCheck(CANMsgInfo)
    RetChkResult = 1;
    
    % ID�ظ��Լ�飬��Ҫ�����ظ�ID����
    if ~isfield(CANMsgInfo,'MsgList')
       RetChkResult = 0;
       return;
    else
        RecordSame = [0];
        for Idx = 1:numel(CANMsgInfo.MsgList)            
            NextLoop = 0;
            SameIDNum = 0;
            for RecIdx = 1:numel(RecordSame)    %��ǰ���б���¼��ͬ���������˴�ѭ��
                if Idx==RecordSame(RecIdx)
                    NextLoop = 1;
                    break;
                end
            end
            if NextLoop == 1    
                continue;
            end
            
            CheckID = CANMsgInfo.MsgList(Idx).ID;
            if Idx == numel(CANMsgInfo.MsgList) %���һ����¼�����
                break;
            end
            
            for SubIdx = Idx+1:numel(CANMsgInfo.MsgList)    %����һ�п�ʼ��ѯ�Ƚ�
                if strcmp(CheckID,CANMsgInfo.MsgList(SubIdx).ID)
                    RecordSame(SameIDNum+1) = SubIdx;
                    SameIDNum = SameIDNum + 1;
                end
            end
            if SameIDNum > 0  % ��ʾID�ظ���Ϣ
                RetChkResult = 0;
                UpdateInfoList(['ID 0x', dec2hex(bitand(str2double(CheckID),hex2dec('1FFFFFFF'))),' ��',num2str(SameIDNum+1), '���ظ�������޸ģ�����']);
            end
        end
    end
    
    % �ź������ظ��Լ��
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
            for RecIdx = 1:numel(RecordNameSame)    %��ǰ���б���¼��ͬ���������˴�ѭ��
                if Idx==RecordNameSame(RecIdx)
                    NextLoop = 1;
                    break;
                end
            end
            if NextLoop == 1    
                continue;
            end
            
            CheckName = SignalTemp{Idx};
            if Idx == numel(SignalTemp) %���һ����¼�����
                break;
            end
            
            for SubIdx = Idx+1:numel(SignalTemp)    %����һ����¼��ʼ��ѯ�Ƚ�
                if strcmp(CheckName,SignalTemp{SubIdx})
                    RecordNameSame(SameNameNum+1) = SubIdx;
                    SameNameNum = SameNameNum + 1;
                end
            end
            if SameNameNum > 0  % ��ʾID�ظ���Ϣ
                RetChkResult = 0;
                UpdateInfoList(['�ź� ', CheckName,' ��',num2str(SameNameNum+1), '���ظ�������޸ģ�����']);
            end
        end
    end
end

%--------------------------------------------------------------------------
% ��������GetCommonInfo(DBCFileName,MsgNode)
% ������������ȡDBC�ļ�ͨ��������Ϣ
% �޸����ڣ�
%           2022/11/13    xuhongjiang01    �½�����
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
    Header_content = [Header_content sprintf('BS_:') eol];   %BS_:�����ʶ��壬���Բ�д
    Header_content = [Header_content eol];
    
    
    % BU_:���ڶ�������ڵ㣬��ʽΪ BU_:Nodename1 Nodename2 Nodename3 ����
    MessageNode = '';
    for NodeIdex = 1:numel(MsgNode)
        NodeNameStr = MsgNode{NodeIdex};
        MessageNode = strcat(MessageNode,32,NodeNameStr);
    end
    BU_Content = [sprintf(strcat('BU_:',MessageNode)) eol];

    % BA_DEF_ ���Զ��岿�֣���ʽ����ǰ�����屨�ļ��ź�����
    % BA_DEF_ Object AttributeName ValueType Min Max;
    % BA_DEF_DEF_ AttributeName DefaultValue;

    % Network�������
    BA_DEF_Content = [sprintf(strcat('BA_DEF_',32,'"BusType"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"ProtocolType"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"DBName"',32,'STRING',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_',32,'"Manufacturer"',32,'STRING',';')) eol];

    % Node�������
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

    % Signal�������
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

    % Message�������
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

    %----------------����Ϊ���Ĭ�϶���--------------------
    % NetworkĬ�����Զ���
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"BusType"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"ProtocolType"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"DBName"',32,'""',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"Manufacturer"',32,'"Vector"',';')) eol];

    % NodeĬ�����Զ���
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

    % SignalĬ�����Զ���
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"SigType"',32,'"Default"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"SPN"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigILSupport"',32,'"Yes"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigSendType"',32,'"NoSigSendType"',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigInactiveValue"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigStartValue"',32,'0',';')) eol];
    BA_DEF_Content = [BA_DEF_Content sprintf(strcat('BA_DEF_DEF_',32,'"GenSigEVName"',32,'"Env@Nodename_@Signame"',';')) eol];

    % ��������Ĭ�϶���
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
                % �ݲ����κ�����
            end
        else
            try
                set(GUI_DBCTool.DBCPathStr, 'String', '');
                set(GUI_DBCTool.DBCPathStr, 'Value', 0);
            catch
                % �ݲ����κ�����
            end
            UpdateXlsInfoList('ѡ���ļ���dbc�ļ������飡����');
        end
    else
        set(GUI_DBCTool.DBCPathStr, 'String', '');
        set(GUI_DBCTool.DBCPathStr, 'Value', 0);
        UpdateXlsInfoList('δѡ���ļ�������');
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
        UpdateXlsInfoList('DBC�ļ�δ���壬���ɽ�������ֹ������');
        return;
    else
        if contains(DBCFileInfo,{'.dbc','.DBC'})
            if exist(DBCFileInfo, 'file')
                backslash = find(DBCFileInfo == '\', 1, 'last' );
                if isempty(backslash)
                    UpdateXlsInfoList('DBC�ļ�Ŀ¼�쳣�����ɽ�������ֹ������');
                    return;
                else
                    DbcPath = DBCFileInfo(1:backslash);
                    DbcFile = DBCFileInfo(backslash+1:end);
                end
            else
                UpdateXlsInfoList('DBC�ļ�δ�ҵ������ɽ�������ֹ������');
                return;
            end

        else
            UpdateXlsInfoList('DBC�ļ�δ���壬���ɽ�������ֹ������');
            return;
        end
    end
    
    msgInfoList = readDbcFile( [ DbcPath, DbcFile ] );
    
    ExcelPath = DbcPath;
    PrjStr = get(GUI_DBCTool.ProjectStr,'String');
    NodChStr = get(GUI_DBCTool.NodChStr,'String');
    
    ExcelFile = [ PrjStr, '_', NodChStr,'_', datestr( now, 'yyyymmdd' ),'.xlsx' ];
    
    % �ж��Ƿ���ͬ���������ѱ���
    try
        hExcel = actxGetRunningServer('excel.application');     %��ȡ�Ѵ�EXCEL�������������ؾ��
        for i=1:hExcel.Workbooks.Count
            if strcmp(ExcelFile,hExcel.Workbooks.Item(i).Name)
               UpdateXlsInfoList(['�Ѵ�ͬ����� ',ExcelFile,'����رջ��޸������ļ����ƺ����²����������̣�����']);
               msgbox(['�Ѵ�ͬ����� ',ExcelFile,'����رջ��޸������ļ����ƺ����²����������̣�����']);
               return;
            end
        end
        
    catch GetRunningErr 
        switch GetRunningErr.identifier
            case 'MATLAB:COM:invalidprogid'
                try
                    hExcel = actxGetRunningServer('ket.application');     %��ȡ�Ѵ�WPS�������������ؾ��
                    for i=1:hExcel.Workbooks.Count
                        if strcmp(ExcelFile,hExcel.Workbooks.Item(i).Name)
                           UpdateXlsInfoList(['�Ѵ�ͬ����� ',ExcelFile,'����رջ��޸������ļ����ƺ����²����������̣�����']);
                           msgbox(['�Ѵ�ͬ����� ',ExcelFile,'����رջ��޸������ļ����ƺ����²����������̣�����']);
                           return;
                        end
                    end
                catch suberr
                    switch suberr.identifier
                        case 'MATLAB:COM:invalidprogid'
                            UpdateXlsInfoList('δ�ҵ�Microsoft Office��WPS Office������');
                            msgbox('δ�ҵ�Microsoft Office��WPS Office������');
                            return;
                        case 'MATLAB:COM:norunningserver'
                            % Do nothing
                        otherwise
                            UpdateXlsInfoList('��ȡExcel���������ʱ����δ֪���󣡣���');
                            msgbox('��ȡExcel���������ʱ����δ֪���󣡣���');
                            return; 
                    end
                end
            case 'MATLAB:COM:norunningserver'
                % Do nothing
            otherwise
                UpdateXlsInfoList('��ȡExcel���������ʱ����δ֪���󣡣���');
                msgbox('��ȡExcel���������ʱ����δ֪���󣡣���');
                return;
        end
    end
    
    % ���й�����ɾ��
    if exist([ ExcelPath, ExcelFile ],'file')
        answer = questdlg('�ļ���Ŀ¼���Ѵ��ڣ��Ƿ񸲸��滻�������ɣ�����','��ʾ','��','��','��');
        switch answer
            case '��'
                AllFileName = [ ExcelPath, ExcelFile ];
                delete(AllFileName);
                
                if exist([ ExcelPath, ExcelFile ],'file')
                    UpdateXlsInfoList('---�ļ�ɾ��ʧ��---');
                    msgbox('�ļ�ɾ��ʧ�ܣ������г���ռ�ã����飡����');
                    return;
                else
                    UpdateXlsInfoList('---�ļ���ɾ��---');
                end

            case '��'
                UpdateXlsInfoList('Excel�ļ����ɹ����У��û�ѡ���˳�---');
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
    
    % ---------------���÷�����-----------------------
    try
        hExcel = actxserver('excel.application');     %��ȡEXCEL�������������ؾ��
    catch GetRunningErr 
        switch GetRunningErr.identifier
            case 'MATLAB:COM:InvalidProgid'
                try
                    hExcel = actxserver('ket.application');     %��ȡWPS�������������ؾ��
                catch suberr
                    switch suberr.identifier
                        case 'MATLAB:COM:InvalidProgid'
                            UpdateXlsInfoList('δ�ҵ�Microsoft Office��WPS Office������');
                            msgbox('δ�ҵ�Microsoft Office��WPS Office������');
                            return;
                    end
                end
            otherwise
                UpdateXlsInfoList('��ȡExcel���������ʱ����δ֪���󣡣���');
                msgbox('��ȡExcel���������ʱ����δ֪���󣡣���');
                return;
        end
    end

    hExcel.Visible = 0;                    %����Excel������Ϊ���ɼ�״̬
    
    hWorkbooks = hExcel.Workbooks.Add;
    
    UpdateXlsInfoList('Excel�ļ������У������ĵȴ�---');
    
    hSheet = hWorkbooks.Sheets.Item(1);
    
    hSheet.Activate;                      % ����ñ��
    hSheet.Name = NodChStr;                 % �趨����������
    
    hSheet.Cells.Font.name = '����';
    hSheet.Cells.Font.size = 11;
    hSheet.Cells.HorizontalAlignment=3;  
    hSheet.Cells.VerticalAlignment=2;
    hSheet.Cells.WrapText=1;                % ���е�Ԫ���Զ�����
    
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
    
    hSheet.Range('A1').Value = [ 'Msg Name', char( 10 ), '��������' ];
    hSheet.Range('A1').ColumnWidth = 12;
    hSheet.Range('A1:A2').MergeCells = 1;
    
    hSheet.Range('B1').Value = [ 'Msg Type', char( 10 ), '��������' ];
    hSheet.Range('B1').ColumnWidth = 8.11;
    hSheet.Range('B1:B2').MergeCells = 1;
    
    hSheet.Range('C1').Value = [ 'Msg ID',char( 10 ),'(Hex)', char( 10 ), '���ı�ʶ��' ];
    hSheet.Range('C1').ColumnWidth = 12.11;
    hSheet.Range('C1:C2').MergeCells = 1;
    
    hSheet.Range('D1').Value = [ 'Msg Send Type', char( 10 ), '���ķ�������' ];
    hSheet.Range('D1').ColumnWidth = 8.11;
    hSheet.Range('D1:D2').MergeCells = 1;
    
    hSheet.Range('E1').Value = [ 'Msg Cycle Time',char( 10 ),'(ms)', char( 10 ), '��������ʱ��'];
    hSheet.Range('E1').ColumnWidth = 8.11;
    hSheet.Range('E1:E2').MergeCells = 1;
    
    hSheet.Range('F1').Value = [ 'Msg Length',char( 10 ),'(Byte)', char( 10 ), '���ĳ���'];
    hSheet.Range('F1').ColumnWidth = 8.11;
    hSheet.Range('F1:F2').MergeCells = 1;
    
    hSheet.Range('G1').Value = [ 'Signal Name', char( 10 ), '�ź�����'];
    hSheet.Range('G1').ColumnWidth = 25;
    hSheet.Range('G1:G2').MergeCells = 1;
    
    hSheet.Range('H1').Value = [ 'Signal Description', char( 10 ), '�ź�����'];
    hSheet.Range('H1').ColumnWidth = 34.11;
    hSheet.Range('H1:H2').MergeCells = 1;
    
    hSheet.Range('I1').Value = [ 'Signal Value Description',char( 10 ),'(Dec)', char( 10 ), '�ź�ֵ����'];
    hSheet.Range('I1').ColumnWidth = 28.22;
    hSheet.Range('I1:I2').MergeCells = 1;
    
    hSheet.Range('J1').Value = [ 'Byte Order', char( 10 ), '���и�ʽ',char( 10 ),'(Intel/Motorola)'];
    hSheet.Range('J1').ColumnWidth = 8.11;
    hSheet.Range('J1:J2').MergeCells = 1;
    
    hSheet.Range('K1').Value = [ 'Start Byte', char( 10 ), '��ʼ�ֽ�'];
    hSheet.Range('K1').ColumnWidth = 8.11;
    hSheet.Range('K1:K2').MergeCells = 1;
    
    hSheet.Range('L1').Value = [ 'Start Bit', char( 10 ), '��ʼλ'];
    hSheet.Range('L1').ColumnWidth = 8.11;
    hSheet.Range('L1:L2').MergeCells = 1;
    
    hSheet.Range('M1').Value = [ 'Signal Send Type', char( 10 ), '�źŷ�������'];
    hSheet.Range('M1').ColumnWidth = 8.11;
    hSheet.Range('M1:M2').MergeCells = 1;
    
    hSheet.Range('N1').Value = [ 'Bit Length',char( 10 ),'(Bit)', char( 10 ), '�źų���'];
    hSheet.Range('N1').ColumnWidth = 8.11;
    hSheet.Range('N1:N2').MergeCells = 1;
    
    hSheet.Range('O1').Value = [ 'Data Type', char( 10 ), '�ź�����'];
    hSheet.Range('O1').ColumnWidth = 8.78;
    hSheet.Range('O1:O2').MergeCells = 1;
    
    hSheet.Range('P1').Value = [ 'Resolution', char( 10 ), '����'];
    hSheet.Range('P1').ColumnWidth = 8.11;
    hSheet.Range('P1:P2').MergeCells = 1;
    
    hSheet.Range('Q1').Value = [ 'Offset', char( 10 ), 'ƫ����'];
    hSheet.Range('Q1').ColumnWidth = 8.11;
    hSheet.Range('Q1:Q2').MergeCells = 1;
    
    hSheet.Range('R1').Value = [ 'Signal Min. Value',char( 10 ),'(phys)', char( 10 ), '������Сֵ'];
    hSheet.Range('R1').ColumnWidth = 12.33;
    hSheet.Range('R1:R2').MergeCells = 1;
    
    hSheet.Range('S1').Value = [ 'Signal Max. Value',char( 10 ),'(phys)', char( 10 ), '�������ֵ'];
    hSheet.Range('S1').ColumnWidth = 12.33;
    hSheet.Range('S1:S2').MergeCells = 1;
    
    hSheet.Range('T1').Value = [ 'Initial Value',char( 10 ),'(Hex)', char( 10 ), '��ʼֵ' ];
    hSheet.Range('T1').ColumnWidth = 8.11;
    hSheet.Range('T1:T2').MergeCells = 1;
    
    hSheet.Range('U1').Value = [ 'Invalid Value',char( 10 ),'(Hex)', char( 10 ), '��Чֵ' ];
    hSheet.Range('U1').ColumnWidth = 8.11;
    hSheet.Range('U1:U2').MergeCells = 1;
    
    hSheet.Range('V1').Value = [ 'Unit', char( 10 ), '��λ'];
    hSheet.Range('V1').ColumnWidth = 8.11;
    hSheet.Range('V1:V2').MergeCells = 1;
    
    hSheet.Range('W1').Value = [ 'Node', char( 10 ), '�ڵ�'];
    
    hSheet.Range('1:2').Font.name='Arial';  %���õ�Ԫ������
    hSheet.Range('1:2').Font.size=10;  %���õ�Ԫ�������С
    hSheet.Range('1:2').HorizontalAlignment=3;  %���õ�Ԫ����뷽ʽ�������,���뷽ʽ����������б�˳��һ�£�1-8�ֱ�Ϊ�����桢���������������С����ң�����������䡢���˶��롢���о��С���ɢ���루������
    hSheet.Range('1:2').VerticalAlignment=1;  %���õ�Ԫ����뷽ʽ��ֱ������У����뷽ʽ����������б�˳��һ�£�1-5�ֱ�Ϊ�������ϡ����С����¡����˶��롢��ɢ����
    %���õ�Ԫ�������ʽΪ�Ӵ֣�0Ϊ�رգ�1Ϊ���ã�б��ͬ����italic���»���underline��
    hSheet.Range('1:2').Font.bold=1;
    hSheet.Range('1:2').Font.italic=1;

    for idx=1:numel(Nodes)
        ColIdxStr = Num2ColumnIdxStr(22+idx);
        hSheet.Range([ColIdxStr,'2']).Value = Nodes{idx};
        hSheet.Range([ColIdxStr,':',ColIdxStr]).ColumnWidth=3;
        hSheet.Range([ColIdxStr,'2']).HorizontalAlignment=3;
        hSheet.Range([ColIdxStr,'2']).VerticalAlignment=1;
        hSheet.Range([ColIdxStr,'2']).Orientation = 90;  % �趨���ֽǶ�
    end

    hSheet.Range(['W1:',ColIdxStr,'1']).MergeCells = 1;
    hSheet.Range(['A1:',ColIdxStr,'2']).Interior.Color=16764210; %��ɫΪ16764210
    
    for j = 1:size( msgInfoList, 2 )
        
        % ��ȡ�кţ��ڴ˻������½�һ��
        UsedRowNum = hSheet.UsedRange.Rows.Count;
        MsgStartRowNumStr = num2str(UsedRowNum+1);
        
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.name='Arial';  %���õ�Ԫ������
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.size=10;  %���õ�Ԫ�������С
        hSheet.Range([MsgStartRowNumStr,':',MsgStartRowNumStr]).Font.bold=1;
        hSheet.Range(['A',MsgStartRowNumStr,':',ColIdxStr,MsgStartRowNumStr]).Interior.Color=16764210; %��ɫΪ16764210
        
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
        hSheet.Range(['H',MsgStartRowNumStr]).Font.name='����';
        
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
                
                % �ź�����
                hSheet.Range(['G',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).name;
                
                % �ź�����
                hSheet.Range(['H',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).comment;
                
                
                % ���и�ʽ
                if ( msgInfoList( 1, j ).sigInfoList( 1, jj ).formatIsMot )
                    hSheet.Range(['J',CurrRowNumStr]).Value = 'Motolora';
                else 
                    hSheet.Range(['J',CurrRowNumStr]).Value = 'Intel';
                end 
                
                % ��ʼλ
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
                
                % ��ʼ�ֽ�
                hSheet.Range(['K',CurrRowNumStr]).Value = fix(sigLSB/8);
                
                % �źŷ�������
                SigSendType = msgInfoList( 1, j ).sigInfoList( 1, jj ).sendType;
                if strcmp( SigSendType,'Cyclic' )
                    hSheet.Range(['M',CurrRowNumStr]).Value = 'Cycle';
                elseif strcmp( SigSendType,'IfActive' )
                    hSheet.Range(['M',CurrRowNumStr]).Value = SigSendType;
                end
                
                % �źų���
                hSheet.Range(['N',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).wordLen;
                
                % ��������
                if ( msgInfoList( 1, j ).sigInfoList( 1, jj ).isSigned )
                    hSheet.Range(['O',CurrRowNumStr]).Value = 'Signed';
                else 
                    hSheet.Range(['O',CurrRowNumStr]).Value = 'Unsigned';
                end 
                
                sigFactor = msgInfoList( 1, j ).sigInfoList( 1, jj ).factor;
                sigOffset = msgInfoList( 1, j ).sigInfoList( 1, jj ).offset;
                % ����
                hSheet.Range(['P',CurrRowNumStr]).Value = sigFactor;
                % ƫ����
                hSheet.Range(['Q',CurrRowNumStr]).Value = sigOffset;
                % ������Сֵ
                hSheet.Range(['R',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).min;
                % �������ֵ
                hSheet.Range(['S',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).max;
                % �źų�ʼֵ
                initVal_Hex = dec2hex(msgInfoList( 1, j ).sigInfoList( 1, jj ).initVal * sigFactor + sigOffset);
                hSheet.Range(['T',CurrRowNumStr]).Value = [ '0x', initVal_Hex ];
                % �ź���Чֵ������д�����ݣ�DBC���޴˶���
%                 hSheet.Range(['U',CurrRowNumStr]).Value = msgInfoList( 1, j ).sigInfoList( 1, jj ).invalidVal;
                
                % ��λ
                sigUnit = msgInfoList( 1, j ).sigInfoList( 1, jj ).unit;
                sigUnit = strrep( sigUnit, '1/min', 'rpm' );

                if ~isempty( sigUnit )
                    hSheet.Range(['V',CurrRowNumStr]).Value = sigUnit;
                end
                
                % �źŽ��սڵ�
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
                
                % �ź�ֵ����
                count0x = 0;
                if ~isempty( msgInfoList( 1, j ).sigInfoList( 1, jj ).sigVal )
                    exp_sigVal = '(\d+)\s*[=:��]\s*(([^;]){1,})(;)?';
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
    UpdateXlsInfoList('Excel�ļ�������---');
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
                        % ͬһ֡����ֻ����һ�ָ�ʽ
                        if ~isequal( msgInfoList( i ).sigInfoList( 1 ).formatIsMot, msgInfoList( i ).sigInfoList( k ).formatIsMot )
                            error( [ 'The signal format of ', msgInfoList( i ).sigInfoList( k ).name, ' is different from others inside message ', msgInfoList( i ).name ] );
                            break ;
                        end 
                    end 
                end 

                i = i + 1;
            end 
        end 
        
        % ����ע�ͻ�ȡ
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
        
        % �ź�ע�ͻ�ȡ
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
        
        % ���Զ�����Ϣ��ȡ
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
        
        % ����Ĭ�϶����ȡ
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
        
        % ��ȡ���ķ������͡����ڼ��źų�ʼֵ����Ϣ
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
        
        % �ź�ֵ�����ȡ
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
        % �����쳣������Ӧ��Ϊ1��
    end
end
