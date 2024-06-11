clear all, close all, clc

% Importing this type of data raise a warning for the variable names
% settings, which I overwrite, so I just shut it off in the following
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');
% Suppress the warning about creating folder that already exist
warning('OFF','MATLAB:MKDIR:DirectoryExists');

global FOLDER;
FOLDER = "..\iCub_ProcessedData\Clustering";
mkdir(FOLDER);

clusteringVel = [1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,2,2];
preferences = [2,2,1,2,2,1,1,2,2,2,1,2,2,2,2,1,1,2,2,2,2,2,1,1,1,1,1,1];

data = readtable("..\iCub_ProcessedData\CompleteAnalysis.xlsx");
data_clean = [data(3:27,:);data(29:end,:)];
data_clean = removevars(data_clean, "AngleHumanSide_deg_");
data_clean = removevars(data_clean, "ImageRobotAngle");
data_clean = removevars(data_clean, "minPeaksNumber");
data_clean = removevars(data_clean, "RemovedSurface_mm_2_");
data_clean = removevars(data_clean, "std_posA__cm_");
data_clean = removevars(data_clean, "std_posB__cm_");
data_clean = removevars(data_clean, "ImageHumanAngle");
efficiency = data_clean.PercentageOfRemovedMaterial___;
ID = data_clean.ID;
data_clean = removevars(data_clean, "PercentageOfRemovedMaterial___"); 
data_clean = removevars(data_clean, "ID");

% data2analyze = [data.ID(2:end),data.Robot_PhaseRelativeVelocity_cm_s_(2:end),data.Human_PhaseRelativeVelocity_cm_s_(2:end)];
% data2analyze_clean = data2analyze(~isnan(data2analyze(:,2)),:);

direct_equality = zeros(1,size(data_clean,2));
inverse_equality = zeros(1,size(data_clean,2));
for i = 1:size(data_clean,2)
    newClusters = exeClustering(ID, [table2array(data_clean(:,i)),efficiency], data_clean.Properties.VariableNames{i});
    direct_equality(i) = sum(preferences==newClusters')/length(newClusters)*100;
    inverse_equality(i) = sum((-preferences+3)==newClusters')/length(newClusters)*100;
    pause(2);
    close all, clc
end

function [cluster_labels] = exeClustering(ID, data, x_name)
    max_k = 2; % Maximum value of k to explore
    
    % Find optimal k using elbow method
    find_optimal_k_elbow(data, max_k);
    
    % Find and choose the optimal value of k based on the results of the analyses
    k_optimal = find_optimal_k_silhouette(data, max_k); 
    
    % Run K-means clustering with the optimal k value
    [cluster_labels, centroids] = k_means_clustering(data, k_optimal, x_name);
    
    clusters = [ID,cluster_labels];
    % save("..\iCub_ProcessedData\ClusterLabels","clusters");
end

function [cluster_labels, centroids] = k_means_clustering(data, k, xName)
    global FOLDER;

    % Convert the input matrix A to a data matrix
    num_samples = size(data, 1);
    num_features = size(data, 2);
    
    % Run K-means clustering
    [cluster_labels, centroids] = kmeans(data, k);
    
    % Plot the results
    fig = figure;
    hold on
    gscatter(data(:, 1), data(:, 2), cluster_labels)
    plot(centroids(:, 1), centroids(:, 2), 'ko', 'MarkerSize', 5, 'LineWidth', 2)
    names = [];
    for i = 1:length(centroids)
        names = [names, strjoin(["Cluster ",num2str(i)],"")];
    end
    legend([names, 'Centroids'])
    title('K-means Clustering on population',xName)
    xlabel(xName)
    ylabel('Removed Material [%]')
    hold off

    exportgraphics(fig, strjoin([FOLDER,"\",xName,".png"],""));
end

function find_optimal_k_elbow(data, max_k)
    distortions = zeros(max_k, 1);
    for k = 1:max_k
        [~, ~, sumd] = kmeans(data, k);
        distortions(k) = sum(sumd);
    end
    
    % Plot the elbow curve
    figure
    plot(1:max_k, distortions, 'bx-')
    xlabel('Number of clusters (k)')
    ylabel('Distortion')
    title('Elbow Method for Optimal k')
end

function [best_k] = find_optimal_k_silhouette(data, max_k)
    silhouette_scores = zeros(max_k, 1);
    max_value = 0;
    for k = 2:max_k
        idx = kmeans(data, k);
        silhouette_scores(k) = mean(silhouette(data, idx));
        if silhouette_scores(k) > max_value
            best_k = k;
            max_value = silhouette_scores(k);
        end
    end
    
    % Plot the silhouette scores
    figure, hold on
    plot(2:max_k, silhouette_scores(2:end), 'bx-')
    plot(best_k, max_value, 'ro', 'MarkerSize', 10)
    legend("k values","optimal k")
    xlabel('Number of clusters (k)')
    ylabel('Average Silhouette Score')
    title('Silhouette Analysis for Optimal k')
    hold off
end