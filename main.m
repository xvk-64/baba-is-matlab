% IMPORTANT
% Please add all folders and subfolders in this project to the matlab path

% An implementation of the popular puzzle game Baba Is You in MATLAB

% Entry point to the game
function main()
% Initialise the game
Game.Init();

% Reset the frame stopwatch
lastFrameTime = tic;
while Game.isPlaying
    % Get the time since the last frame
    deltaTime = toc(lastFrameTime);
    lastFrameTime = tic;

    % Trigger a game update
    Game.Update(deltaTime);
end
end