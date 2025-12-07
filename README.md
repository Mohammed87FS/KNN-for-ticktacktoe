# KNN-for-ticktacktoe

Uni project in matlab for simulationsbildnug und Modelierung

Aufgabe 16: Künstliche Neuronale Netze
Erstellen Sie ein KNN zum Tic Tac Toe spielen. Trainieren sie das Modell mit einem
Zuggenerator von Cleve Moler, https://www.mathworks.com/content/dam/mathworks/mathworksdot-com/moler/exm/chapters/tictactoe.pdf

# MVP Project Structure

KNN-for-ticktacktoe/
├── src/                    # MATLAB Implementation Scripts
│ ├── generate_data.m       # Datensammlung aus simulierten Tic Tac Toe Spielen
│ ├── train_nn.m            # Training des neuronalen Netzes mit gesammelten Daten
│ └── tictactoe.m           # Hauptspiel Script für die Spiel Simulation

├── data/  
                            # Generierte Daten
├── models/                 # Trainierte NN Modelle
│ 
├── docs/                   # Dokumentation
│ ├── Cleve_Moler_ZugGen.md # Original Zuggenerator von Cleve Moler
│ └── project_notes.md      # Projekt Notizen und Erklärunge

└── README.md               # Projekt Übersicht
