clc; clear all;

%==> Path to folder containing all grid files
input_folder = '/media/user/data1/Anuj_Data/Data_Paper_5km/Data_Process/BC_data_CHIRPS_05KM_Hemple_1981_2024/';

%==> Load grid lat-lon list
lonlat = dlmread('/media/user/data1/Anuj_Data/Data_Paper_5km/Code_and_files/INDmet5km_respective_lalo.txt');  % [N x 2] = [lon lat]
n_grids = size(lonlat,1);

%==> Initialize output matrix
%==> Columns: [lon lat NaN_ref NaN_raw NaN_bc Inf_ref Inf_raw Inf_bc Neg_ref Neg_raw Neg_bc Invalid_ref Invalid_raw Invalid_bc Min_ref Min_raw Min_bc Max_ref Max_raw Max_bc]
qc_results = zeros(n_grids, 20);

for i = 1:size(lonlat,1)  % <-- change to n_grids when ready for full run
    try
        disp (i)
        lon = lonlat(i,1);
        lat = lonlat(i,2);

        %==>  Construct filename
        fname = [input_folder, 'data_', num2str(lon), '_', num2str(lat)];

        if ~isfile(fname)
            fprintf('File missing: %s\n', fname);
            continue;
        end

        %==>  Load file: [year, month, day, ref, raw, bc]
        data = dlmread(fname);

        ref = data(:,4);
        raw = data(:,5);
        bc  = data(:,6);

        %==>  Save lat-lon
        qc_results(i,1:2) = [lon, lat];

        %==>  NaN check
        qc_results(i,3:5) = [sum(isnan(ref)), sum(isnan(raw)), sum(isnan(bc))];

        %==>  Inf check
        qc_results(i,6:8) = [sum(isinf(ref)), sum(isinf(raw)), sum(isinf(bc))];

        %==>  Negative values
        qc_results(i,9:11) = [sum(ref < 0), sum(raw < 0), sum(bc < 0)];

        %==>  Invalid values = NaN + Inf
        qc_results(i,12:14) = qc_results(i,3:5) + qc_results(i,6:8);

        %==>  Min values (ignore NaN/Inf)
        qc_results(i,15:17) = [min(ref(~isnan(ref) & ~isinf(ref))), ...
            min(raw(~isnan(raw) & ~isinf(raw))), ...
            min(bc(~isnan(bc) & ~isinf(bc)))];

        %==>  Max values (ignore NaN/Inf)
        qc_results(i,18:20) = [max(ref(~isnan(ref) & ~isinf(ref))), ...
            max(raw(~isnan(raw) & ~isinf(raw))), ...
            max(bc(~isnan(bc) & ~isinf(bc)))];
    end
end

%==> Save the summary
save('/media/user/data1/Anuj_Data/Data_Paper_5km/Data_for_Plot/QC_summary_5km.mat', 'qc_results');
writematrix(qc_results, '/media/user/data1/Anuj_Data/Data_Paper_5km/Data_for_Plot/QC_summary_5km.csv');



