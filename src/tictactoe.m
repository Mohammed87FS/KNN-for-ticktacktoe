function tictactoe()

src_path = fileparts(mfilename('fullpath'));
model_path = fullfile(src_path,'..','models','tictactoe_nn.mat');

% Modell laden
if ~exist(model_path, 'file')
    error('Kein trainiertes Modell gefunden! Erst train_nn ausführen.');
end
data = load(model_path);
netz = data.netz_model;

% Spielfeld initialisieren
X = zeros(3,3);

% Numpad-Layout anzeigen
fprintf('\n=== TIC TAC TOE vs KNN ===\n');
fprintf('Züge eingeben als 1-9:\n');
fprintf('  7 | 8 | 9\n');
fprintf(' ---+---+---\n');
fprintf('  4 | 5 | 6\n');
fprintf(' ---+---+---\n');
fprintf('  1 | 2 | 3\n\n');

show_board(X);

% Spielschleife
while true
    % Spieler (Grün) am Zug
    move = input('Dein Zug (1-9): ');
    [i, j] = numpad_to_ij(move);
    
    if X(i,j) ~= 0
        fprintf('Feld besetzt! Nochmal.\n');
        continue;
    end
    X(i,j) = 1;
    show_board(X);
    
    % Check Gewinner
    p = check_winner(X);
    if p == 1
        fprintf('Du hast gewonnen!\n');
        break;
    elseif p == 2
        fprintf('Unentschieden!\n');
        break;
    end
    
    % KNN am Zug
    fprintf('KNN denkt...\n');
    [i, j] = nn_move(X, netz);
    X(i,j) = -1;
    show_board(X);
    
    % Check Gewinner
    p = check_winner(X);
    if p == -1
        fprintf('KNN hat gewonnen!\n');
        break;
    elseif p == 2
        fprintf('Unentschieden!\n');
        break;
    end
end

fprintf('Spiel beendet.\n');
end

%% Hilfsfunktionen

function [i, j] = nn_move(X, netz)
% KNN wählt einen Zug
input_vec = reshape(X', 9, 1);
probs = netz(input_vec);

% Nur legale Züge
legal = (input_vec == 0);
probs(~legal) = -inf;

[~, move] = max(probs);

% Row-major Index zu (i,j) konvertieren (nicht ind2sub, das ist column-major!)
i = ceil(move / 3);
j = mod(move - 1, 3) + 1;
end

function [i, j] = numpad_to_ij(num)

map = [3,1; 3,2; 3,3; 2,1; 2,2; 2,3; 1,1; 1,2; 1,3];
i = map(num, 1);
j = map(num, 2);
end

function show_board(X)
% Spielfeld anzeigen
symbols = {'O', ' ', 'X'};  % -1=O(blau), 0=leer, +1=X(grün)
fprintf('\n');
for row = 1:3
    for col = 1:3
        idx = X(row,col) + 2;  % -1->1, 0->2, 1->3
        fprintf(' %s ', symbols{idx});
        if col < 3, fprintf('|'); end
    end
    fprintf('\n');
    if row < 3, fprintf('---+---+---\n'); end
end
fprintf('\n');
end

function p = check_winner(X)
% 0=keiner, 1=grün, -1=blau, 2=unentschieden
for pp = [1, -1]
    s = 3*pp;
    if any(sum(X) == s) || any(sum(X,2) == s) || ...
       sum(diag(X)) == s || sum(diag(fliplr(X))) == s
        p = pp;
        return;
    end
end
if all(X(:) ~= 0)
    p = 2;
else
    p = 0;
end
end

