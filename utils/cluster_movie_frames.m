function [cluster1_idx, cluster2_idx, cluster3_idx] = cluster_movie_frames(movie)
% movie: 3D matrix (x, y, t)
% cluster1_idx, cluster2_idx: frame indices for each category

    % Get dimensions
    [nx, ny, nt] = size(movie);
    
    % Reshape each frame into a vector
    frame_vectors = reshape(movie, nx*ny, nt)';  % Each row is a frame

    % Optional: normalize the data
    frame_vectors = zscore(frame_vectors);  % Standardize across frames
    
    % Reduce dimensionality with PCA
    n_components = 10;  % Choose number of components to keep
    [coeff, score, ~] = pca(frame_vectors, 'NumComponents', n_components);
    
    % Cluster frames into 2 categories using k-means
    n_clusters = 3;
    rng(1);  % For reproducibility
    cluster_labels = kmeans(score, n_clusters, 'Replicates', 10);

    % Return frame indices for each cluster
    cluster1_idx = find(cluster_labels == 1);
    cluster2_idx = find(cluster_labels == 2);
    cluster3_idx = find(cluster_labels == 3);
end
