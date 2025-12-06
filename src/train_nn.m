function net = train_net(varargin) % x spater dann !!

p = inputParser
addParameter(p,'hidden', [36,18]);

addParameter(p,'learn_rate', 0.01);
addParameter(p,'epochs', 300);
addParameter(p,'num_games', 5890);
addParameter(p,'batch_size', 64);
addParameter(p,'generate_data_boolean', false);

parse(p, varargin{:});
opts = p.Results;

src_path = fileparts(mfilename('fullpath'));
data_path = fullfile(src_path,'..','data','data_tictactoe.mat');  
model_path = fullfile(src_path,'..','models','tictactoe_nn.mat');

if opts.generate_data_boolean || ~exist(data_path, 'file')
    fprintf('generating new data...\n');
    [input,output] = generate_data(opts.num_games, true); %% TODO rework gen to have function
else 
    fprintf('loading data from %s...\n', data_path);
    data = load(data_path);
    input = data.boards; % hier erwarte ich input wo jede Zeile ein board mit 9 feldern (zeile pro Spiel)
    output = data.move_idx; % hier sollte one hot encoding verwendet werden 
    fprintf('data loaded %d samples\n', size(input,1));
end

