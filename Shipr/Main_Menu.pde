class MainMenu {
  PFont menu;
  String menuLevel = "Shipr";
  String[][] items = {{"Survive Alone", "Survive Together", "Duel", "Solo", "Options", "Help", "Quit"}, {"Controls", "Music", "Back"}, {"Survival", "Duel", "Solo", "Back"}, {"P1 Shoot Key: " + displayer (p1Shoot) + " (Click To Change)", "P2 Shoot Key: " + displayer (p2Shoot) + " (Click To Change)", "Back"}, {"Pause/Play", "Next Track", "Back", ""}, {"", "", "", "", "", "Back"}, {"", "", "", "", "", "Back"}, {"", "", "", "", "", "Back"}, {"Normal", "Atari", "Star Wars"}}; //add menu items
  int[] levelItems = new int[9];
  int curLevel = 0; //0 = main menu, 1 = options, 2 = help, 3 = controls, 4 = music, >=5 help, 8 = texture packs
  int bodySize = 50;
  int gameMode = 0;
  int timeOut = 0;
  boolean twoPlayer = false;
  int checking = 0;

  MainMenu (PFont menuIn) {
    menu = menuIn;

    for (int i = 0; i < levelItems.length; i++) {
      levelItems[i] = items[i].length;
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (Audio audio) {
    textFont (menu);
    textAlign (CENTER, CENTER);
    menuLevel = currentLevel (curLevel);
    fill (100);
    text (menuLevel, width / 2, height / (levelItems[curLevel] + 1));
    textSize (bodySize);
    for (int i = 0; i < items[curLevel].length; i++) 
      text (items[curLevel][i], width / 2, height / (levelItems[curLevel]) + ((i + 1) * 100));
    items[4][3] = "Now Playing: " + audio.bgMetaData[audio.track].title() + " by " + audio.bgMetaData[audio.track].author();
    input (audio);
    
    textSize (35);
    fill (100);
    if (curLevel == 5) {
      text ("Survival is a game mode where\n you must defeat oncoming waves\n of enemies and make sure none\n slip by you. If they manage\n to pass you, you will lose health.\n You will also lose health if\n an enemy hits you. Use wasd to\n move. (Arrow keys for P2) and space\n to shoot (Enter keys for P2). Shoot\n keys are adjustable in options. The\n game will end when a player's health\n goes below 0.", width / 2, 2 * height / 5);
    } else if (curLevel == 6) {
      text ("Duel is a two player game mode\n where two players face off in a shooting\n match. One of the players must destroy\n the other player by hitting them with bullets.\n Players will lose health each time a bullet hits them.\n Once a player is destroyed the game is over.\n Players have a limited amount of ammo but\n the ammo will regenerate over time.\n P1: Use arrow keys to move and enter to shoot.\n P2: Use wasd to move and the space key to shoot.", width / 2, 2 * height / 5);
    } else if (curLevel == 7) {
      text ("Solo is an open world game mode where\n the player explores a map while facing\n increasingly difficult waves of enemies.\n The player must survive and if their health\n goes below 0 they will die. The player\n will use wasd to move and mouse click to shoot\n and will change weapons with the number keys 1 - 3.\n Try to survive and see how far you\n can go!", width / 2, 2 * height / 5);
    }
  }

  String currentLevel (int curLevel) {
    String output = "";
    if (curLevel == 0)
      output = "Shipr";
    else if (curLevel == 1)
      output = "Options";
    else if (curLevel == 2)
      output = "Help";
    else if (curLevel == 3)
      output = "Controls";
    else if (curLevel == 4)
      output = "Music";
    else if (curLevel == 5)
      output = "Survival";
    else if (curLevel == 6)
      output = "Duel";
    else if (curLevel == 7)
      output = "Solo";
    else if (curLevel == 8)
      output = "Texture Packs";
    return output;
  }

  int gameModeSet() {
    return gameMode;
  }

  boolean playerNumSet() {
    return twoPlayer;
  }

  void input(Audio audio) {
    for (int i = 0; i < items[curLevel].length; i++) {
      if (mouseX > width / 2 - (items[curLevel][i].length() / 2) * 25 && mouseX < width / 2 + (items[curLevel][i].length() / 2) * 25 && mouseY > height / (levelItems[curLevel]) + ((i + 1) * 100) + ((100 - bodySize) / 4) - 25 && mouseY < height / (levelItems[curLevel]) + ((i + 1) * 100) + ((100 - bodySize) / 4) + 25) {
        fill (50);
        text (items[curLevel][i], width / 2, height / (levelItems[curLevel]) + ((i + 1) * 100));

        if (mousePressed && millis() - timeOut > 500) {
          if (curLevel == 0) {
            if (i == 0) {
              clickTime = millis();
              gameMode = 1;
              break;
            } 
            if (i == 1) {
              clickTime = millis();
              gameMode = 1;
              twoPlayer = true;
              break;
            } 
            if (i == 2) {
              gameMode = 2;
              break;
            } 
            if (i == 3) {
              loading = true;
              gameMode = 3;
              break;
            }   
            if (i == 4) {
              curLevel = 1;
              timeOut = millis();
              break;
            }
            if (i == 5) {
              curLevel = 2;
              timeOut = millis();
              break;
            }
            if (i == 6) {
              exit();
            }
          } else if (curLevel == 1) {
            if (i == 0) {
              curLevel = 3;
              break;
            } else if (i == 1) {
              curLevel = 4;
              timeOut = millis();
              break;
            } else if (i == 2) { //music
              curLevel = 0;
              timeOut = millis();
              break;
            } else if (i == 3) { //back
              curLevel = 0;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 2) {
            if (i == 0) {
              curLevel = 5;
              timeOut = millis();
              break;
            } else if (i == 1) {
              curLevel = 6;
              timeOut = millis();
              break;
            } else if (i == 2) {
              curLevel = 7;
              timeOut = millis();
              break;
            } else if (i == 3) { //back
              curLevel = 0;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 3) {
            if (i == 0) {
              timeOut = millis();
              items[3][0] = "P1 Shoot Key: Press Any Key...";
              checking = 1;
              break;
            } else if (i == 1) {
              timeOut = millis();
              items[3][1] = "P2 Shoot Key: Press Any Key...";
              checking = 2;
              break;
            } else if (i == 2) { //back
              curLevel = 1;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 4) {
            if (i == 0) { //pause/play
              audio.pausePlay();
              timeOut = millis();
              break;
            } else if (i == 1) { //change track
              audio.changeTrack (true);
              timeOut = millis();
              break;
            } else if (i == 2) { //back
              curLevel = 1;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 5) {
            if (i == 5) {
              curLevel = 2;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 6) {
            if (i == 5) {
              curLevel = 2;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 7) {
            if (i == 5) {
              curLevel = 2;
              timeOut = millis();
              break;
            }
          } else if (curLevel == 8) {
            if (i == 0 || i == 1 || i == 2) {
              curLevel = 1;
              timeOut = millis();
              break;
            }
          }
        }
      }
    }
  }

  String displayer (char c) {
    String output = "";
    if (c >= 'a' && c <= 'z')
      output = "" + c;
    else if (c >= 'A' && c <= 'Z')
      output = "" + c;
    else if (c == ENTER) 
      output = "Enter";
    else if (c == ' ')
      output = "Space";
    else if (c == TAB)
      output = "Tab";
    else if (c == ALT)
      output = "Alt";
    else if (c == CONTROL)
      output = "Ctrl";
    else if (c == SHIFT)
      output = "Shift";
    else if (c == ESC)
      output = "Esc";
    else
      output = "Undisplayable";

    return output;
  }

  void changeKey(int n) {
    if (n != 0) {
      if (keyPressed) {
        if (n == 1)
          p1Shoot = key;
        else if (n == 2)
          p2Shoot = key;
        checking = 0;
        items[3][0] = "P1 Shoot Key: " + displayer (p1Shoot) + " (Click To Change)";
        items[3][1] = "P2 Shoot Key: " + displayer (p2Shoot) + " (Click To Change)";
      }
    }
  }
}