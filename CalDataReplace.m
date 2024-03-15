function CalDataReplace()
%% CAL_GlobalVariables.c string replacement
srcFileName = 'CAL_GlobalVariables.c';
oldStrSrc = '=';
newStrSrc = '__attribute__((section (".CcpCalRamAddr"))) =';
srcFid = fopen(srcFileName,'r+');
while feof(srcFid) == 0    
    tline = fgetl(srcFid);    
    tline01 = strrep(tline,oldStrSrc,newStrSrc);    
    ffid = fopen('temp.c','a+');    
    fprintf(ffid,'%s\n',tline01);    
    fclose(ffid);
end
fclose(srcFid);

delete('CAL_GlobalVariables.c');
movefile('temp.c', 'CAL_GlobalVariables.c');

%% CAL_GlobalVariables.h string replacement
includeFileName = 'CAL_GlobalVariables.h';
oldStrInclude = ';';
newStrInclude = ' __attribute__((section (".CcpCalRamAddr")));';
includeFid  = fopen(includeFileName, 'r+');
while feof(includeFid) == 0
    tline = fgetl(includeFid);
    tline01 = strrep(tline, oldStrInclude, newStrInclude);
    ffid = fopen('temp.h', 'a+');
    fprintf(ffid, "%s\n", tline01);
    fclose(ffid);
end
fclose(includeFid);

delete('CAL_GlobalVariables.h');
movefile('temp.h', 'CAL_GlobalVariables.h');
end
