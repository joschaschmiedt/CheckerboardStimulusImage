function generate_checkerboard(cfg)
% Generate a radial black/white checkerboard PNG file
% 
% INPUT
% -----
%  cfg : struct for configuration with fields
%       .radialCycles : number of complete cycles along radial direction
%       .polarCycles : number of complete cycles along polar direction
%       .contrast : gray value for contrast (0-1)
%       .imgSize : size of image (px); default is smaller screen size
%       .filename : filename of checkerboard PNG ('auto')
% 
% OUTPUT
% ------
%  A PNG image file that is fully transparent outside the checkerboard
%  pattern. 
%% defaults
if ~exist('cfg', 'var'); cfg = []; end

% number of white/black circle pairs
if ~isfield(cfg, 'radialCycles'); cfg.radialCycles = 10; end
if ~isfield(cfg, 'polarCycles'); cfg.polarCycles = 8; end

% contrast
if ~isfield(cfg, 'contrast'); cfg.contrast = 1; end

% image size
if ~isfield(cfg, 'imgSize')
    cfg.screenId = 2;
    cfg.screenSize = get(0, 'MonitorPositions');
    cfg.screenSize = cfg.screenSize(cfg.screenId, [3 4]);
    imgSize = min(cfg.screenSize);
else
    imgSize = cfg.imgSize;
end

% filename
if ~isfield(cfg, 'filename'); cfg.filename = 'auto'; end

%% create checkerboard pattern
bgIndex = 128;
blackIndex = round(128 + cfg.contrast * 127);
whiteIndex = round(128 - cfg.contrast * 127);


xylim = 2*pi*cfg.radialCycles;
[x,y] = meshgrid(-xylim : 2*xylim/(imgSize-1) : xylim, ...
    -xylim : 2*xylim/(imgSize-1) : xylim);
radius = atan2(y,x);
checks = ((1+sign(sin(radius*cfg.polarCycles)+eps) .* ...
    sign(sin(sqrt(x.^2+y.^2))))/2) * (blackIndex-whiteIndex) + whiteIndex;


circle = x.^2 + y.^2 <= xylim^2;

checks = uint8(circle .* checks + bgIndex * ~circle);

alphaMask = double(circle);

%% store pattern in PNG file
if strcmp(cfg.filename, 'auto')
    saveFile = sprintf('checkerboard_%dpx_%grc_%gpc.png', ...
        imgSize, cfg.radialCycles, cfg.polarCycles);
else
    saveFile = cfg.filename;
end

imwrite(checks, saveFile, 'Alpha', alphaMask)
