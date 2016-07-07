function generate_mask_wedge(cfg)
% Generate a gray mask with transparent wedge cutout in PNG file.
%
% INPUT
% -----
%   cfg : configuration struct with fields
%       .imgSize : size of stimulus in px (default=screen size)
%       .direction : directions for wedges (0=left HM, 90=upper VM, ...; default=[0 180])
%       .maskGrayValue : 8 bit gray value for mask (default=128)
%       .minRadius : start of wedge from center in px (default=100px)
%       .maxRadius : end of wedge from center in px (default=Inf)
%       .filename : name of PNG file (default='auto')
if ~exist('cfg', 'var'); cfg = []; end

if ~isfield(cfg, 'imgSize')
    cfg.screenId = 2;
    cfg.imgSize = get(0, 'MonitorPositions');
    cfg.imgSize = cfg.imgSize(cfg.screenId, [3 4]);
end

if ~isfield(cfg, 'openingAngle'); cfg.openingAngle = 15; end % degree
if ~isfield(cfg, 'direction'); cfg.direction = [0 180]; end % degree: 0=HM, 90=VM, counter-clockwise
if ~isfield(cfg, 'maskGrayValue'); cfg.maskGrayValue = 128; end % gray value (0-255)
if ~isfield(cfg, 'minRadius'); cfg.minRadius = 100; end % px
if ~isfield(cfg, 'maxRadius'); cfg.maxRadius = 500; end % px
if ~isfield(cfg, 'filename'); cfg.filename = 'auto'; end

% opening angle in radians
openAngleRad = cfg.openingAngle * pi / 180;

% coordinate system
x = (1:cfg.imgSize(1)) - round(cfg.imgSize(1)/2);
y = (1:cfg.imgSize(2)) - round(cfg.imgSize(2)/2);
[X,Y] = meshgrid(x, y);
R = sqrt(X.^2 + Y.^2);
Phi = atan2(Y,X)+pi;

% generate gray background
background = uint8(ones(size(R)) * cfg.maskGrayValue);

wedges = false(size(Phi));


for iDirection = 1:length(cfg.direction)
    % create wedges
    directionRad = cfg.direction(iDirection) * pi / 180;
    
    % range selection with periodic coordinates is a little tricky. 
    % This solution works but is not elegant.
    polarRange = [directionRad-openAngleRad/2 ...
        directionRad+openAngleRad/2];
    if any(polarRange > 2*pi) || any(polarRange < 0)
        polarRange = sort(mod(polarRange, 2*pi));
        invertPolarSelection = true;
    else
        invertPolarSelection = false;
    end
    wedge = ...
        Phi >= polarRange(1) & ...
        Phi <= polarRange(2);
    if invertPolarSelection
        wedge = ~wedge;
    end
    wedges = wedges | wedge;
end

wedges = wedges & ...
    R >= cfg.minRadius & ...
    R <= cfg.maxRadius;

wedges = ~wedges;

if strcmp(cfg.filename, 'auto')
    directionString = sprintf('%u-', cfg.direction);
    directionString = directionString(1:end-1);
    filename = sprintf('wedge_ori%s_%ux%upx_oang%gdeg_bg%d_r%g-%gpx.png', ...
        directionString, ...
        cfg.imgSize(1), ...
        cfg.imgSize(2), ...
        cfg.openingAngle, ...
        cfg.maskGrayValue, ...
        cfg.minRadius, ...
        cfg.maxRadius);
else
    filename = cfg.filename;
end
% write to file
imwrite(background, filename, 'Alpha', double(wedges))



