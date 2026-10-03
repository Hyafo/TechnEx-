function CarCrash
    % Main function of the game
    clc; close all;

    % Display the game title
    disp('%%%%%%%%%%%%%%%%%%%%%');
    disp('%     CAR CRASH     %');
    disp('%%%%%%%%%%%%%%%%%%%%%');
    fprintf('\n');

    % Best score of the user
    best_score = 0;

    % if he want to play again, default true
    % The user choose at each end of game
    play_again = true;

    while play_again
        % Choose the difficulty
        fprintf('Select difficulty. Options are:\n');
        fprintf(' (1) Easy\n');
        fprintf(' (2) Medium\n');
        fprintf(' (3) Hard\n');
        fprintf(' (4) Impossible\n');

        % Get the user input (1, 2, 3 or 4)
        fprintf('\n');
        difficulty_selection = input('Your choice: ');
        fprintf('\n');

        % Start a new game
        [score, window_closed] = playGame(difficulty_selection, best_score);

        if window_closed
            break;   % Stop if the window was closed
        end

        % Update the best score if the actual score is higher than the actual best score
        if score > best_score
            best_score = score;
            fprintf('Game over - score : %.1f  (New best score !)\n', score);
        else
            fprintf('Game over - score : %.1f  (Best : %.1f)\n', score, best_score);
        end
        fprintf('\n');

        % Ask whether the player wants to replay
        answer = input('Replay ? (o/n) : ', 's');
        fprintf('\n');
        play_again = ~isempty(answer) && any(lower(answer(1)) == ['o' 'y']);
        close all;
    end

    fprintf('Thanks for playing ! Best score : %.1f\n', best_score);
end

% Runs one game
function [score, window_closed] = playGame(difficulty_selection, best_score)

    % dimensions of the game
    land_dimensions = [-50 50 0 100];

    % Initialize the car and game state
    car.pos  = [0; 5];          % Car position
    car.size = [6 10];          % Car width and height
    car.v    = 80;              % Car horizontal speed

    % Load the car texture
    [img, map, alpha] = imread('car.png');
    if ~isempty(map)                       % Indexed PNG -> RGB
       img = ind2rgb(img, map);
    end
    if isempty(alpha)                      % No transparency
        alpha = ones(size(img, 1), size(img, 2));
    else
        alpha = double(alpha) / double(intmax(class(alpha)));   % Values between 1 and 0
    end
    car.img   = flipud(img);               % Flipped upside-down
    car.alpha = flipud(alpha);
    car.size = [6, 6 * size(img,1)/size(img,2)];

    obstacles = zeros(0, 4);    % Obstacles: [x, y, width, height]
    spawn_timer = 0;
    score = 0;                  % Score of the user
    window_closed = false;

    % Set parameters for each difficulty
    switch difficulty_selection
        case 1
            vy = 60;                                   % Speed of obstacles
            spawn_min = 0.20;  spawn_max = 0.60;       % time range for obstacles falls
            n_max = 1;                                 % How many obstacles falls
        case 2
            vy = 90;
            spawn_min = 0.12;  spawn_max = 0.40;
            n_max = 2;
        case 3
            vy = 120;
            spawn_min = 0.08;  spawn_max = 0.20;
            n_max = 3;
        case 4
            vy = 140;
            spawn_min = 0.06;  spawn_max = 0.18;
            n_max = 3;
        otherwise
            vy = 60;
            spawn_min = 0.30;  spawn_max = 0.90;
            n_max = 4;
    end

    % Set the first obstacle spawn time
    next_spawn = spawn_min + (spawn_max - spawn_min)*rand;

    % Create the game window and initialize keyboard controls
    % We only play with left and right arrow on the keyboard
    fig = figure('KeyPressFcn', @onKeyDown, 'KeyReleaseFcn', @onKeyUp);
    setappdata(fig, 'keys', struct('left', false, 'right', false));

    dt = 0.03;         % Time between game updates
    crashed = false;   % Keep the informations if the user have crashed

    % Main game loop
    while ishandle(fig)
        keys = getappdata(fig, 'keys');

        % Move the car and keep it inside the game area
        dx = (keys.right - keys.left) * car.v * dt;
        car.pos(1) = min(max(car.pos(1) + dx, land_dimensions(1) + car.size(1)/2), land_dimensions(2) - car.size(1)/2);

        % Spawn new obstacles at random intervals
        spawn_timer = spawn_timer + dt;
        if spawn_timer > next_spawn
            spawn_timer = 0;
            next_spawn = spawn_min + (spawn_max - spawn_min)*rand;
            n = randi(n_max);

            for j = 1:n
                w = 4 + 6*rand;   % Random obstacle width
                h = 4 + 4*rand;   % Random obstacle height
                x = land_dimensions(1) + w/2 + rand*(100 - w);
                obstacles(end+1, :) = [x, 100 + h/2, w, h];
            end
        end

        % Move obstacles down and remove those off-screen
        obstacles(:, 2) = obstacles(:, 2) - vy * dt;
        obstacles(obstacles(:, 2) < -10, :) = [];

        % End the game if the car hits an obstacle
        % Called a function that return if the user hit or not an obstacle
        if checkCollision(car, obstacles)
            crashed = true;
            break;
        end

        % Increase the score based on survival time
        score = score + dt;

        % Draw the updated game scene
        plotscene(fig, land_dimensions, car, obstacles, score, best_score);
        pause(dt);
    end

    % Display the crash message or detect a closed window
    if crashed && ishandle(fig)
        % Display text with some styles
        text(0, 50, 'CRASH !', 'HorizontalAlignment', 'center', 'FontSize', 30, 'Color', 'r', 'FontWeight', 'bold');

        % Force game refresh
        drawnow;
    elseif ~ishandle(fig)
        window_closed = true;
    end
end


% Checks whether the car collides with an obstacle
function hit = checkCollision(car, obs)
    % Init hit variable at false because the user didn't hit any obstacle when the game start
    hit = false;

    % Get the center of the car
    cx = car.pos(1);
    cy = car.pos(2) + car.size(2)/2;

    % Check each obstacle for an overlap
    for i = 1:size(obs, 1)
        if abs(cx - obs(i,1)) < (car.size(1) + obs(i,3))/2 && abs(cy - obs(i,2)) < (car.size(2) + obs(i,4))/2
            hit = true;
            return;
        end
    end
end


% Draws the car, obstacles, and scores
function plotscene(fig, region, car, obs, score, best_score)
    set(0, 'CurrentFigure', fig);

    % Clear axes1
    cla;
    hold on;

    set(gca, 'Color', [.6 .6 .6]);
    axis(region); axis square;

    % Draw the car texture
    image('XData', [car.pos(1) - car.size(1)/2, car.pos(1) + car.size(1)/2], ...
      'YData', [car.pos(2), car.pos(2) + car.size(2)], ...
      'CData', car.img, 'AlphaData', car.alpha);

    % Draw all obstacles
    for i = 1:size(obs, 1)
        rectangle('Position', [obs(i,1) - obs(i,3)/2, obs(i,2) - obs(i,4)/2, obs(i,3), obs(i,4)], 'FaceColor', 'r');
    end

set(gca, 'YDir', 'normal');

    % Display the current score and best score
    % Sprintf format data into string
    title(sprintf('Score : %.1f   |   Best : %.1f', score, best_score));
    drawnow;
end

% Detects when a movement key is pressed
function onKeyDown(src, evt)
    k = getappdata(src, 'keys');

    % 'left'/'right' = noms Octave, 'leftarrow'/'rightarrow' = noms MATLAB
    if any(strcmp(evt.Key, {'left'})),   k.left  = true; end
    if any(strcmp(evt.Key, {'right'})), k.right = true; end

    setappdata(src, 'keys', k);
end


% Detects when a movement key is released
function onKeyUp(src, evt)
    k = getappdata(src, 'keys');

    if any(strcmp(evt.Key, {'left', 'leftarrow'})),   k.left  = false; end
    if any(strcmp(evt.Key, {'right', 'rightarrow'})), k.right = false; end

    setappdata(src, 'keys', k);
end
