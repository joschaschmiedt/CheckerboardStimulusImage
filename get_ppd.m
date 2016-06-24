% function ppd = get_ppd()

% DELL U2312HM
% 509.2 mm x 286.4mm
% 1920 x 1080 px
pxpmm = 1920/509.2;
pxp

cfgFile = '/Library/Application Support/MWorks/Configuration/setup_variables.xml';
ppdChoice = 0;
while ~ismember(ppdChoice, [1 2])
    ppdChoice = input(strcat('No pixels per degree (PPD) defined. \n',...
        '   (1) Enter manually\n', ...
        '   (2) Read from configuration\n', ...
        '       (/Library/Application Support/MWorks/Configuration/setup_variables.xml)\n'));
end
switch ppdChoice
    case 1
        cfg.ppd = input('PPD = ');
    case 2
        
        xDoc = xmlread(cfgFile);
        allSettings = xDoc.getElemgentsByTagName('dictionary_element');
        for ii = 0:allSettings.getLength()-1
            thisSetting = allSettings.item(ii).get
%             thisList = thisListitem.getElementsByTagName('key');
        end
%         size
end
umberNode.getTextContent