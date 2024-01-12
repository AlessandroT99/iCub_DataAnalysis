load data4ROM-AlignedB.mat;

fig5f = figure('Name','Range of Motion (ROM)');
fig5f.WindowState = 'maximized';
hold on

[sorted_NearHand_4_PosB, indicesB] = sort([nearHand(logical(newRightHandTests(3:end))),nearHand(logical(newLeftHandTests(3:end)))]);
sorted_PosB = [tmpMaxPeaksAverage(newRightHandTests),tmpMinPeaksAverage(newLeftHandTests)].*100;
sorted_PosB = sorted_PosB(indicesB);
% iCub max (posB)
scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
p = polyfit(sorted_NearHand_4_PosB, sorted_PosB, 1);
newYB = polyval(p, linspace(min(nearHand)-3,max(nearHand)+3));
plot(newYB, linspace(min(nearHand)-3,max(nearHand)+3), 'r-')

[sorted_NearHand_4_PosA, indicesA] = sort([nearHand(logical(newLeftHandTests(3:end))),nearHand(logical(newRightHandTests(3:end)))]);
sorted_PosA = [tmpMaxPeaksAverage(newLeftHandTests),tmpMinPeaksAverage(newRightHandTests)].*100;
sorted_PosA = sorted_PosA(indicesA);
% iCub min (posA)
scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')
p = polyfit(sorted_NearHand_4_PosA, sorted_PosA, 1);
newYA = polyval(p, linspace(min(nearHand)-3,max(nearHand)+3));
plot(newYA, linspace(min(nearHand)-3,max(nearHand)+3), 'b-')

% Plot union lines between points to describe ROM
plot([tmpMaxPeaksAverage(newLeftHandTests).*100;tmpMinPeaksAverage(newLeftHandTests).*100], ...
     [nearHand(logical(newLeftHandTests(3:end)));nearHand(logical(newLeftHandTests(3:end)))], ...
     LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color', [0,0,0])

plot([tmpMaxPeaksAverage(newRightHandTests).*100;tmpMinPeaksAverage(newRightHandTests).*100], ...
     [nearHand(logical(newRightHandTests(3:end)));nearHand(logical(newRightHandTests(3:end)))], ...
     LineTypeROM,'LineWidth',ConnectionLineWidthROM,'Color', [0,0,0])

% Replot for graphycal issues
scatter(sorted_PosB, sorted_NearHand_4_PosB, MarkerDimension, 'red','filled')
scatter(sorted_PosA, sorted_NearHand_4_PosA, MarkerDimension, 'blue','filled')

xLineA = ((abs(maxPeaksAverage(1))-abs(minPeaksAverage(1)))+(minPeaksAverage(BASELINE_NUMBER)-maxPeaksAverage(BASELINE_NUMBER)))/2*100; 
xline(xLineA,'k--','LineWidth',1)
xline(0,'k--','LineWidth',1)
text(xLineA+0.2,31,"A*",'FontSize',12)
text(0.2,31,"B*",'FontSize',12)

%title("Range Of Motion (ROM) of iCub hand and Near-Hand Effect")
legend('Point B', 'Trend of Point B', 'Point A', 'Trend of point A', "iCub's Hand ROM", 'Location','southwest')
xlabel("Range of Motion (ROM) Of iCub's Hand [cm]"), ylabel("Near-Hand Effect [ms]")
xlim([-19,1]), ylim([min(nearHand)-5,max(nearHand)+5])
set(gca, 'YDir','reverse')

hold off

if IMAGE_SAVING
    pause(PAUSE_TIME);
    exportgraphics(fig5f,"ROM-NearHand_NewAlignedPosB.png")
    close(fig5f);
end
