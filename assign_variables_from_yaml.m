%% Get variables from YAML
function [loop,data_folder,penfile_type, hp_file]=assign_variables_from_yaml(yaml_file)
    % Load the YAML content from the file
    try
        yaml_struct = yaml.ReadYaml(yaml_file); % Using the yamlmatlab library
    catch ME
        error('Failed to read YAML file: %s', ME.message);
    end
    
    % Loop through each field in the structure and assign it as a variable
    fields = fieldnames(yaml_struct);
    
    for i = 1:length(fields)
        % Get field name and value
        field_name = fields{i};
        field_value = yaml_struct.(field_name);
        
        % Dynamically assign the variable to the workspace
        eval([field_name ' = yaml_struct.' field_name ';']);
    end
    disp('Variables have been loaded and assigned.');
end