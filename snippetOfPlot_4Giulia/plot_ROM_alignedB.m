load data4ROM-AlignedB.mat;

fig5f = figure('Name','Range of Motion (ROM)');
fig5f.WindowState = 'maximized';
hold on

YLIM_max = max(nearHand)+5;
YLIM_min = min(nearHand)-5;

[sorted_NearHand_4_PosA, indicesA] = sort([nearHand(logical(newLeftHandTests(3:end))),nearHand(logical(newRightHandTests(3:end)))]);
sorted_PosA = [tmpMaxPeaksAverage(newLeftHandTests),tmpMinPeaksAverage(newRightHandTests)].*100;
sorted_PosA = sorted_PosA(indicesA);
% iCub min (posA)
scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')
p = polyfit(sorted_NearHand_4_PosA, sorted_PosA, 1);
newYA = polyval(p, linspace(YLIM_min,YLIM_max));
plot(newYA, linspace(YLIM_min,YLIM_max), 'b-')

[sorted_NearHand_4_PosB, indicesB] = sort([nearHand(logical(newRightHandTests(3:end))),nearHand(logical(newLeftHandTests(3:end)))]);
sorted_PosB = [tmpMaxPeaksAverage(newRightHandTests),tmpMinPeaksAverage(newLeftHandTests)].*100;
sorted_PosB = sorted_PosB(indicesB);
% iCub max (posB)
scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
p = polyfit(sorted_NearHand_4_PosB, sorted_PosB, 1);
newYB = polyval(p, linspace(YLIM_min,YLIM_max));
plot(newYB, linspace(YLIM_min,YLIM_max), 'r-')

% Vectors containing the ROM middle point coordinates
Mx = [(tmpMaxPeaksAverage(newRightHandTests)+tmpMinPeaksAverage(newRightHandTests))./2.*100,(tmpMaxPeaksAverage(newLeftHandTests)+tmpMinPeaksAverage(newLeftHandTests))./2.*100];
My = [nearHand(logical(newRightHandTests(3:end))),nearHand(logical(newLeftHandTests(3:end)))];

% Plot a single marker and a single line just for legend purposes
plot([tmpMaxPeaksAverage(3)*100;tmpMinPeaksAverage(3)*100], [nearHand(3);nearHand(3)], '-','LineWidth',1,'Color', [0,0,0])
plot(Mx(1),My(1), '^','LineWidth',1,'Color', [0,1,0])

% Trend Line for middle points
% [sorted_NearHand_4_PosM, indicesM] = sort(My);
% sorted_PosM = Mx(indicesM);
% p = polyfit(sorted_NearHand_4_PosM, sorted_PosM, 1);
% newYM = polyval(p, linspace(YLIM_min,YLIM_max));
% plot(newYM, linspace(YLIM_min,YLIM_max), 'g-')

% Plot union lines between points to describe ROM
plot([tmpMaxPeaksAverage(newLeftHandTests).*100;tmpMinPeaksAverage(newLeftHandTests).*100], ...
     [nearHand(logical(newLeftHandTests(3:end)));nearHand(logical(newLeftHandTests(3:end)))], ...
     '-','LineWidth',1,'Color', [0,0,0])
plot([tmpMaxPeaksAverage(newRightHandTests).*100;tmpMinPeaksAverage(newRightHandTests).*100], ...
     [nearHand(logical(newRightHandTests(3:end)));nearHand(logical(newRightHandTests(3:end)))], ...
     '-','LineWidth',1,'Color', [0,0,0])

% Replot for graphycal issues
scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')

% Plot triangles to indicate the mean of the ROM of each participant
plot(Mx, My, '^','LineWidth',1,'Color', [0,1,0])

xLineA = ((abs(maxPeaksAverage(1))-abs(minPeaksAverage(1)))+(minPeaksAverage(BASELINE_NUMBER)-maxPeaksAverage(BASELINE_NUMBER)))/2*100; 
xline(xLineA,'k--','LineWidth',1)
xline(0,'k--','LineWidth',1)
xline(xLineA/2,'g--','LineWidth',1)
text(xLineA+0.2,31,"A*",'FontSize',12)
text(0.2,31,"B*",'FontSize',12)
text(xLineA/2+0.2,31,"M*",'FontSize',12, 'Color',[0,1,0])

%title("Range Of Motion (ROM) of iCub hand and Near-Hand Effect")
legend('Point A', 'Trend of Point A', 'Point B', 'Trend of point B', "iCub's Hand ROM", "ROM Middle Point", 'Location','southwest')
% legend('Point A', 'Trend of Point A', 'Point B', 'Trend of point B', "iCub's Hand ROM", "ROM Middle Point", "Trend of ROM middle", 'Location','southwest')
xlabel("Range of Motion (ROM) Of iCub's Hand [cm]"), ylabel("Near-Hand Effect [ms]")
xlim([-19,1]), ylim([YLIM_min,YLIM_max])
set(gca, 'YDir','reverse')

hold off

if IMAGE_SAVING
    pause(PAUSE_TIME);
    exportgraphics(fig5f,"ROM-NearHand_NewAlignedPosB.png")
    close(fig5f);
end
