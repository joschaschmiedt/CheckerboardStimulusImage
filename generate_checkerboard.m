function generate_checkerboard(cfg)

%
cfg = [];
cfg.ppd = 50;
if ~exist('cfg', 'var'); cfg = []; end
if ~isfield(cfg, 'ppd')
    cfg.ppd = get_ppd();
end

if ~isfield(cfg, 'contrast');
    cfg.contrast = 1;
end


% number of white/black circle pairs
if ~isfield(cfg, 'radialCycles'); cfg.radialCycles = 10; end
if ~isfield(cfg, 'polarCycles'); cfg.polarCycles = 8; end

if ~isfield(cfg, 'contrast'); cfg.contrast = 1; end

cfg.screenId = 2;
cfg.screenSize = get(0, 'MonitorPositions');
cfg.screenSize = cfg.screenSize(cfg.screenId, [3 4])

%%


imgSize = max(cfg.screenSize); % Change size

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

imwrite(checks, 'checkerboard.png', 'Alpha', alphaMask)
