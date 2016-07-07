function generate_mask_annulus(cfg)
% Generate a gray mask with transparent annulus cutout in PNG file.
%
% INPUT
% -----
%   cfg : configuration struct with fields
%       .imgSize : size of stimulus in px (default=screen size)%       
%       .maskGrayValue : 8 bit gray value for mask (default=128)
%       .innerRadius : start of annulus from center in px (default=300)
%       .outerRadius : end of annulus from center in px (default=400)
%       .filename : name of PNG file (default='auto')

%% defaults
if ~exist('cfg', 'var'); cfg = []; end

if ~isfield(cfg, 'imgSize')
    cfg.screenId = 2;
    cfg.imgSize = get(0, 'MonitorPositions');
    cfg.imgSize = cfg.imgSize(cfg.screenId, [3 4]);
end

if ~isfield(cfg, 'maskGrayValue'); cfg.maskGrayValue = 128; end %(0-255)
if ~isfield(cfg, 'innerRadius'); cfg.innerRadius = 300; end % px
if ~isfield(cfg, 'outerRadius'); cfg.outerRadius = 400; end % px
if ~isfield(cfg, 'filename'); cfg.filename = 'auto'; end

%% create image
% coordinate system
x = (1:cfg.imgSize(1)) - round(cfg.imgSize(1)/2);
y = (1:cfg.imgSize(2)) - round(cfg.imgSize(2)/2);
[X,Y] = meshgrid(x, y);
R = sqrt(X.^2 + Y.^2);

% generate gray background
background = uint8(ones(size(R)) * cfg.maskGrayValue);

% create annulus
annulus = ...
    R >= cfg.innerRadius & ...
    R <= cfg.outerRadius;
annulus = ~annulus;

%% save image
if strcmp(cfg.filename, 'auto')
    filename = sprintf('annulus_%ux%upx_r%u-%upx_bg%u.png', ...
        cfg.imgSize(1), ...
        cfg.imgSize(2), ...
        cfg.innerRadius, ...
        cfg.outerRadius, ...
        cfg.maskGrayValue);
else
    filename = cfg.filename;
end
% write to file
imwrite(background, filename, 'Alpha', double(annulus))



