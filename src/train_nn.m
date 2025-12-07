function netz = train_netz(varargin) % x spater dann !!

p = inputParser
addParameter(p,'hidden', [36,18]);
addParameter(p,'learn_rate', 0.01);
addParameter(p,'epochs', 300);
addParameter(p,'num_games', 5890);
%addParameter(p,'batch_size', 64); % spater 
addParameter(p,'generate_data_boolean', false);
addParameter(p,'validation_split', 0.2);

parse(p, varargin{:});
opts = p.Results;

src_path = fileparts(mfilename('fullpath'));
data_path = fullfile(src_path,'..','data','data_tictactoe.mat');  
model_path = fullfile(src_path,'..','models','tictactoe_nn.mat');

if opts.generate_data_boolean || ~exist(data_path, 'file')
    fprintf('generating new data...\n');
    [input, output] = generate_data(true);  % true = save to file
else 
    fprintf('loading data from %s...\n', data_path);
    data = load(data_path);
    
    % Nur nicht-terminale Stellungen behalten (move_idx > 0)
    valid_moves = data.move_idx > 0;
    input = data.boards(valid_moves, :);
    
    % One Hot Encoding für move_idx erstellen
    num_valid = sum(valid_moves);
    output = zeros(num_valid, 9);
    linear_idx = sub2ind(size(output), (1:num_valid)', data.move_idx(valid_moves));
    output(linear_idx) = 1;
    
    fprintf('data loaded %d samples (filtered from %d total)\n', num_valid, size(data.boards,1));
end

% Transpose weil .. jede Spalte ist ein Datenpunkt und jede Zeile ist ein feature 
% features sind in dem Fall die 9 felder des boards
X = input';   % 9 x N
Y = output';  % 9 x N
netz = feedforwardnet(opts.hidden);

% ====================================================================
% ====================================================================
% ich teste mal verschiedene Trainingsfunktionen

% Option 1.. Levenberg Marquardt
%net.trainFcn = 'trainlm';
% Vorteile: Super schnell, konvergiert meist in wenigen Epochen
% Nachteile: braucht viel ram (O(n²)), bei großen Datensätzen problematisch
% für uns nicht ideal, weil wir relativ viele Samples haben

% Option 2.. Scaled Conjugate Gradient (aktuell)
netz.trainFcn = 'trainscg';
% Vorteile: Braucht wenig Speicher, schnell, gut für große Datensätze
% Nachteile: Etwas langsamer als trainlm, aber das ist ok
% Für uns: Passt gut, weil wir viele Trainingsdaten haben

% Option 3.. Bayesian Regularization
%net.trainFcn = 'trainbr';
% Vorteile: Beste Generalisierung, verhindert Overfitting automatisch
% Nachteile: Deutlich langsamer, braucht mehr Zeit
% Für uns: Gut wenn Generalisierung wichtiger ist als Geschwindigkeit

% Schlussfolgerung
% ich glaube fur tictactoe ist trainscg' optimal wegen kleinem Sample size 
% ====================================================================
% ====================================================================

netz.performFcn = 'crossentropy'; % cross entropy loss function .. gut fur klassifikation
netz.layers{end}.transferFcn = 'softmax'; % softmax in der ausgabeschicht fur ((mehrklassige)) klassifikation


netz.trainParam.lr = opts.learn_rate;
netz.trainParam.epochs = opts.epochs;
netz.trainParam.showWindow = true; % zeige gui
netz.trainParam.showCommandLine = true; % zeige im command window
netz.trainParam.show = 50;  % zeigt progress nach jedem 50 epochs

test_ratio = 0.1; % 10% test set
netz.divideParam.trainRatio = 1 - opts.validation_split - test_ratio ;  % also 80% training set

netz.divideParam.valRatio = opts.validation_split;      % 20% validation set
netz.divideParam.testRatio = test_ratio;                        % kein test set


[netz_model, training_record] = train(netz, X, Y);

fprintf('training erledigt\n');
save(model_path, 'netz_model', 'training_record');

% testing
test_index = training_record.testInd; % indices fur test set
Y_vorhersage = netz_model(X(:, test_index)); % vorhersagen fur test set
[~, vorhersagen_class] = max(Y_vorhersage);
[~, true_class] = max(Y(:, test_index));
accuracy = mean(vorhersagen_class == true_class) * 100;

fprintf('Test accuracy: %.2f%%\n', accuracy);

end