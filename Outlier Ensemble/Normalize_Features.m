function Normalize_Features (data,  outputDir)
    for i=1:size(data,2)
        if min(data(:,i)) ~= max(data(:,i))
            data(:,i) = (data(:,i)- min(data(:,i)))/(max(data(:,i))-min(data(:,i)));
        end
    end

    dlmwrite(outputDir,data, 'delimiter',' ')
end