# KNN für Tic Tac Toe

Uni-Projekt für Simulationsbildung und Modellierung (FHWN, WS 2025/26)

## Schnellstart

```matlab
% 1. In MATLAB den src-Ordner öffnen
cd src

% 2. Spiel starten (gegen KNN spielen)
tictactoe
```

## Befehle

| Befehl          | Beschreibung                    |
| --------------- | ------------------------------- |
| `tictactoe`     | Startet das Spiel gegen das KNN |
| `generate_data` | Generiert Trainingsdaten        |
| `train_netz`    | Trainiert das neuronale Netz    |

## Projektstruktur

KNN-for-ticktacktoe/
├── src/ # MATLAB Scripts
│ ├── tictactoe.m # Hauptspiel (hier starten!)
│ ├── generate_data.m # Trainingsdaten generieren
│ ├── train_nn.m # KNN trainieren

├── data/ # Generierte Trainingsdaten
├── models/ # Trainierte Modelle
└── docs/ # Dokumentation & Paper

## Aufgabenstellung

```
Aufgabe 16: Künstliche Neuronale Netze
Erstellen Sie ein KNN zum Tic Tac Toe spielen. Trainieren Sie das Modell mit einem
Zuggenerator von Cleve Moler.

Referenz: [Cleve Moler - TicTacToe Magic](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/moler/exm/chapters/tictactoe.pdf)

```
