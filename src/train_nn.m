function netz = train_netz(varargin)


p = inputParser;
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
log_path = fullfile(src_path,'..','models','training_log.txt');

% Logging starten
fid = fopen(log_path, 'w');
log_msg = @(msg) fprintf_both(fid, msg);

log_msg(sprintf('=== TicTacToe KNN Training Log ===\n'));
log_msg(sprintf('Datum: %s\n\n', datestr(now)));
log_msg(sprintf('Parameter:\n'));
log_msg(sprintf('  Hidden Layers: [%s]\n', num2str(opts.hidden)));
log_msg(sprintf('  Learning Rate: %.4f\n', opts.learn_rate));
log_msg(sprintf('  Epochs: %d\n', opts.epochs));
log_msg(sprintf('  Validation Split: %.1f%%\n', opts.validation_split * 100));
log_msg(sprintf('\n'));

tic;  % Zeitmessung starten

if opts.generate_data_boolean || ~exist(data_path, 'file')
    log_msg('Daten: Generiere neue Daten...\n');
    [input, output] = generate_data(true);  % true = save to file
    log_msg(sprintf('Daten: %d Samples generiert\n', size(input,1)));
else 
    log_msg(sprintf('Daten: Lade von %s\n', data_path));
    data = load(data_path);
    
    % Nur nicht-terminale Stellungen behalten (move_idx > 0)
    valid_moves = data.move_idx > 0;
    input = data.boards(valid_moves, :);
    
    % One Hot Encoding für move_idx erstellen
    num_valid = sum(valid_moves);
    output = zeros(num_valid, 9);
    linear_idx = sub2ind(size(output), (1:num_valid)', data.move_idx(valid_moves));
    output(linear_idx) = 1;
    
    log_msg(sprintf('Daten: %d Samples geladen (gefiltert von %d)\n', num_valid, size(data.boards,1)));
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
% ich glaube fur tictactoe ist trainscg optimal wegen kleinem Sample size 
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


log_msg(sprintf('\nTraining gestartet...\n'));
[netz_model, training_record] = train(netz, X, Y);
training_time = toc;

log_msg(sprintf('Training abgeschlossen!\n'));
log_msg(sprintf('  Dauer: %.1f Sekunden\n', training_time));
log_msg(sprintf('  Epochen: %d\n', training_record.num_epochs));
log_msg(sprintf('  Beste Validation Performance: %.6f\n', training_record.best_vperf));

save(model_path, 'netz_model', 'training_record');
log_msg(sprintf('  Modell gespeichert: %s\n', model_path));

% Testing
test_index = training_record.testInd;
Y_vorhersage = netz_model(X(:, test_index));
[~, vorhersagen_class] = max(Y_vorhersage);
[~, true_class] = max(Y(:, test_index));
accuracy = mean(vorhersagen_class == true_class) * 100;

log_msg(sprintf('\nErgebnisse:\n'));
log_msg(sprintf('  Test Samples: %d\n', length(test_index)));
log_msg(sprintf('  Test Accuracy: %.2f%%\n', accuracy));
log_msg(sprintf('\n=== Training Log Ende ===\n'));

fclose(fid);
fprintf('Log gespeichert: %s\n', log_path);

end

%% Hilfsfunktion für Logging
function fprintf_both(fid, msg)
% Schreibt in Konsole und Logdatei
fprintf('%s', msg);
fprintf(fid, '%s', msg);
end