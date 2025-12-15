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

% Titel anzeigen
fprintf('\n=== TIC TAC TOE vs KNN ===\n');

% Wer beginnt?
fprintf('Wer soll beginnen?\n');
fprintf('  1 = Du (X)\n');
fprintf('  2 = KNN (O)\n');
starter = input('Auswahl: ');

show_board_with_numpad(X);

% Falls KNN beginnt, ersten Zug machen
if starter == 2
    fprintf('KNN beginnt...\n');
    [i, j] = nn_move(X, netz);
    X(i,j) = -1;
    show_board_with_numpad(X);
end

% Spielschleife
while true
    % Spieler (X) am Zug
    move = input('Dein Zug (1-9): ');
    [i, j] = numpad_to_ij(move);
    
    if X(i,j) ~= 0
        fprintf('Feld besetzt! Nochmal.\n');
        continue;
    end
    X(i,j) = 1;
    show_board_with_numpad(X);
    
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
    show_board_with_numpad(X);
    
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
% KNN wählt einen Zug - REINES neuronales Netz
%
% Das KNN wurde mit deterministischen Trainingsdaten trainiert
% und entscheidet selbstständig über alle Züge:
% - Gewinnzüge erkennen und ausführen
% - Gegnerische Gewinnzüge blockieren  
% - Strategische Züge (Mitte, Ecken) bevorzugen
%
% Keine regelbasierte Unterstützung - das Netz muss alles lernen!

% Brett invertieren: KNN sieht sich selbst als +1
% (Trainingsdaten sind aus Sicht des Spielers am Zug)
X_flipped = -X;

input_vec = reshape(X_flipped', 9, 1);
probs = netz(input_vec);

% Nur legale Züge erlauben
legal = (reshape(X', 9, 1) == 0);
probs(~legal) = -inf;

[~, move] = max(probs);

% Row-major Index zu (i,j) konvertieren
i = ceil(move / 3);
j = mod(move - 1, 3) + 1;
end

function [i, j] = numpad_to_ij(num)

map = [3,1; 3,2; 3,3; 2,1; 2,2; 2,3; 1,1; 1,2; 1,3];
i = map(num, 1);
j = map(num, 2);
end

function show_board_with_numpad(X)
% Spielfeld mit Numpad-Referenz nebeneinander anzeigen
symbols = {'O', ' ', 'X'};  % -1=O(KNN), 0=leer, +1=X(Spieler)
numpad = {'7', '8', '9'; '4', '5', '6'; '1', '2', '3'};

fprintf('\n');
fprintf('   Spielfeld          Eingabe\n');
fprintf('                      (Numpad)\n');
for row = 1:3
    % Spielfeld
    for col = 1:3
        idx = X(row,col) + 2;
        fprintf(' %s ', symbols{idx});
        if col < 3, fprintf('|'); end
    end
    fprintf('       ');
    % Numpad-Referenz
    for col = 1:3
        fprintf(' %s ', numpad{row,col});
        if col < 3, fprintf('|'); end
    end
    fprintf('\n');
    if row < 3
        fprintf('---+---+---       ---+---+---\n');
    end
end
fprintf('\n');
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

