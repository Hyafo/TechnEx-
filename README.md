 ============================================================
HOW TO PLAY ?
  -Download the "TechnEX" folder from https://github.com/Hyafo/TechnEx-
  -All assets and the executive file "carcrash.m" should be directly present in the folder
  -Launch "carcrash.m" and run the script in the "Editor" section
  -Have fun !
 
 GOAL :
  -Try to survive the road trip without touching any obstacle until the score reaches
  the target of the chosen difficulty.

 RULES :
  - Touching any obstacle (car, deer or rock) = CRASH, game over.
  - Reaching the winning score = WIN.
  - Winning score: Easy 10 | Medium 12 | Hard 15 | Impossible 18.
  - Difficulty sets the obstacle speed (vy), the delay between spawns (spawn_min..spawn_max) and the max number of obstacles per spawn (n_max).
  - Fairness rules for spawning: obstacles never overlap (4 units of spacing), and a free corridor wider than the car (+3 units)
   must always remain, so every situation is passable.

 WAYS TO MOVE / CONTROLS :
  - LEFT / RIGHT arrow keys : move the car horizontally (80 units/s).
  - P : Pause / Resume
  - Q : Quit game
  - Mouse click : choosing the difficulty and quit in the menu

 GAME COMPONENTS :
  - Menu : Rules + 4 difficulties + quit button
  - Scene : figure, axes (game area [-50 50 0 100]), static background, player car, score text
  - Obstacles : 3 types (1 = car, 2 = deer, 3 = rock), random width 8-14
  - Overlays : pause screen and end screen (win / crash / stop)
  - Sub-functions : playGame, loadTexture, overlapsAny, corridorExists, checkCollision, showOverlay,
   showMenu, showPause, showEnd, onKeyDown, onKeyUp, onMouseDown

 VARIABLES :
   best_score        best score of the session (kept between games)
   score             time survived in the current game (s)
   game_result       'win' | 'crash' | 'quit' | 'exit'
   land_dimensions   game area [xmin xmax ymin ymax]
   tex               textures (img, alpha, ratio) of each element
   car.size / .pos / .v   car size, position [x; y], speed
   obstacles         matrix, one row per obstacle:
                     [x, y, width, height, type, graphics handle]
   spawn_timer, next_spawn   time since last spawn / random delay
   vy, spawn_min, spawn_max, n_max, winning_score   difficulty
   corridor_extra    extra free room required around the car
   keys              struct of key states (left, right, pause, quit)
   click             last mouse click position in the axes
   crashed, won, paused, quit_game   state flags
   dt                real elapsed time per frame (capped at 0.05 s)

 MAIN LOOP (inside playGame, repeated while the window exists)
   1. Measure real elapsed time dt (so speed doesn't depend on
      the computer's performance).
   2. Read the keys; Q -> stop the game.
   3. P -> toggle pause (the loop idles while paused).
   4. Move the car with the arrows, clamped to the road.
   5. Update the spawn timer; when it exceeds next_spawn, create
      1 to n_max obstacles above the screen (valid positions only).
   6. Move all obstacles down by vy*dt, delete those below the
      screen, update their graphics.
   7. Check collision (rectangle overlap) -> 'crash'.
   8. Add dt to the score; if score >= winning_score -> 'win'.
   9. Update the car and score text, then drawnow.
   After the loop: show the end screen for 2 seconds.

 ACROSS TRIALS (several games in a row)
   The function carcrash repeats: menu -> game -> result -> menu.
   - best_score is kept between games and passed to playGame to
     be shown on screen. It is only updated after a win or a
     crash (a stopped game does not count).
   - Each game creates a fresh window, textures, obstacles and
     score, so nothing carries over except best_score.
   - Each result is printed in the command window, with a
     "New best score!" message when it is beaten.
   - Clicking "Quit" (or closing the window) ends the program
     and prints the final best score. The best score is not
     saved to a file, so it is lost when the program ends.

 Octave version :
  - Octave-11.3.0

 Souces :
  - adobestock and shutterstock images, Claude AI

 Contributions :
  - All members of the group participated equally in the developpment of the script and creation of the game

                        Thanks for playing !

 Author : Eloise Guillard, Alexandre Milou, Jade PRATOUSSY      Date : From the 01/10/2026 to the 08/10/2026
 ============================================================
