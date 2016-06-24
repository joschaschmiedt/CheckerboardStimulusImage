function generate_mask_wedge(cfg)

% cfg = [];
cfg.ppd = 50;
if ~exist('cfg', 'var'); cfg = []; end
if ~isfield(cfg, 'ppd')
    cfg.ppd = get_ppd();
end

cfg.screenId = 2;
cfg.screenSize = get(0, 'MonitorPositions');
cfg.screenSize = cfg.screenSize(cfg.screenId, [3 4]);

% % if ~isfield(cfg, 'center'); cfg.center = [0 0]; end % px
if ~isfield(cfg, 'openingAngle'); cfg.openingAngle = 15; end % degree
if ~isfield(cfg, 'direction'); cfg.direction = [90 ]; end % degree: 0=lower VM, 90=right HM
if ~isfield(cfg, 'maskGrayValue'); cfg.maskGrayValue = 128; end % gray value (0-255)
if ~isfield(cfg, 'minRadius'); cfg.minRadius = 2; end % vis. deg.
if ~isfield(cfg, 'maxRadius'); cfg.maxRadius = 15; end % vis. deg.
    
openAngleRad = cfg.openingAngle * 2 * pi / 360;

x = (1:cfg.screenSize(1)) - round(cfg.screenSize(1)/2);% + cfg.center(1);
y = (1:cfg.screenSize(2)) - round(cfg.screenSize(2)/2);% + cfg.center(2);
[X,Y] = meshgrid(x, y);

R = sqrt(X.^2 + Y.^2);
Rdeg = R/cfg.ppd;
Phi = atan2(X,Y);
background = uint8(ones(size(R)) * cfg.maskGrayValue);

wedges = false(size(background));
for ii = 1:length(cfg.direction)
    directionRad = cfg.direction(ii) * 2 * pi / 360;
    wedge = ...
        Phi >= directionRad-openAngleRad/2 & ...
        Phi <= directionRad+openAngleRad/2 & ...
        Rdeg >= cfg.minRadius & ...
        Rdeg <= cfg.maxRadius;
    wedges = wedges | wedge;
end
wedges = ~wedges;
figure
subplot(2,1,1)
imagesc(x,y,wedges)
axis equal
axis xy

subplot(2,1,2)
imagesc(x,y,background)
axis equal
axis xy

% write to file
directionString = sprintf('%d_', cfg.direction);
directionString = directionString(1:end-1);

filename = sprintf('wedge_%s_o%d_m%d_r%g-%g.png', ...
    directionString, ...
    cfg.openingAngle, ...    
    cfg.maskGrayValue, ...
    cfg.minRadius, ...
    cfg.maxRadius);

imwrite(background, filename, 'Alpha', double(wedges))
% imwrite(background, filename, 'Alpha', alphaMatrix)


