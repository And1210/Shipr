class HUD {
  PFont menu;
  PImage shipI;
  PImage player1;
  PImage player2;
  PImage p1;
  PImage p2;
  PImage pause;
  PImage pauseBg;
  PImage arrow;
  int gMode = -1;
  boolean paused = false;
  int rocketUp = -10000;
  int mGunUp = -10000;
  int timeOut = 0;

  int wave = 0;

  HUD (PFont menuIn, PImage sI) {
    menu = menuIn;
    shipI = sI;
    pause = loadImage ("/res/Pause.png");
    p1 = loadImage ("/res/Ship.png");
    p2 = loadImage ("/res/Ship1.png");
    p1.resize (40, (int) (p1.height / (p1.width / 40.0)));
    p2.resize (40, (int) (p2.height / (p2.width / 40.0)));
    arrow = loadImage ("/res/Arrow.png");
  }

  HUD (PFont menuIn, PImage play1, PImage play2) {
    menu = menuIn;
    player1 = play1;
    player2 = play2;
    pause = loadImage ("/res/Pause.png");
    p1 = loadImage ("/res/Ship.png");
    p2 = loadImage ("/res/Ship1.png");
    p1.resize (40, (int) (p1.height / (p1.width / 40.0)));
    p2.resize (40, (int) (p2.height / (p2.width / 40.0)));
    arrow = loadImage ("/res/Arrow.png");
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update () {
    image (pause, width - 25, 25);

    if (mousePressed && mouseX >= width - 38 && mouseX <= width - 13 && mouseY >= 13 && mouseY <= 38 && millis() - timeOut > 500) {
      pauseBg = createImage (width, height, RGB);
      loadPixels();
      for (int i = 0; i < width * height; i++)
        pauseBg.pixels[i] = pixels[i];

      paused = !paused;
      timeOut = millis();
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (EComSolo eComSolo, Ship ship, Gamespace map) {
    wave = eComSolo.wave;
    if (millis() - eComSolo.waveStart <= 3500) {
      if (millis() - eComSolo.waveStart >= 2000)
        fill (100, 255 - map (millis() - eComSolo.waveStart, 2000, 3500, 0, 255));
      else
        fill (100);
      textAlign (CENTER, CENTER);
      text ("Wave " + wave, width / 2, height / 2);
    }

    if (eComSolo.enemiesS.size() > 0) {
      int close = closest (eComSolo.enemiesS);
      if (!(eComSolo.enemiesS.get (close).screenX >= 0 && eComSolo.enemiesS.get (close).screenX <= width && eComSolo.enemiesS.get (close).screenY >= 0 && eComSolo.enemiesS.get (close).screenY <= height))
        arrow (eComSolo.enemiesS.get (close).screenX, eComSolo.enemiesS.get (close).screenY);
    }

    textAlign (LEFT, TOP);
    fill (100);
    if (ship.instakill - millis() >= 0)
      text ("Instakill: " + (int) ((ship.instakill - millis()) / 1000), 25, 25);
    if (ship.bombr - millis() >= 0)
      text ("Bombr: " + (int) ((ship.bombr - millis()) / 1000), 25, 75);
    if (ship.speedUp - millis() >= 0)
      text ("SpeedUp: " + (int) ((ship.speedUp - millis()) / 1000), 25, 125);

    if (ship.laserActive) {
      image (laserImg, width - 50 - laserImg.width / 2, 25 + laserImg.height / 2);
      if (ship.rocket)
        tint (127);
      else
        tint (63);
      image (rocketImg, width - 50 - rocketImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height / 2);
      if (ship.mGun)
        tint (127);
      else
        tint (63);
      image (mGunImg, width - 50 - mGunImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height + 10 + mGunImg.height / 2);
      noTint();
    } else if (ship.rocketActive) {
      image (rocketImg, width - 50 - rocketImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height / 2);
      tint (127);
      image (laserImg, width - 50 - laserImg.width / 2, 25 + laserImg.height / 2);
      if (ship.mGun)
        tint (127);
      else
        tint (63);
      image (mGunImg, width - 50 - mGunImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height + 10 + mGunImg.height / 2);
      noTint();
    } else if (ship.mGunActive) {
      image (mGunImg, width - 50 - mGunImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height + 10 + mGunImg.height / 2);
      tint (127);
      image (rocketImg, width - 50 - rocketImg.width / 2, 25 + laserImg.height + 10 + rocketImg.height / 2);
      image (laserImg, width - 50 - laserImg.width / 2, 25 + laserImg.height / 2);
      noTint();
    }

    if (rocketUp - millis() >= 0) {
      textAlign (CENTER, CENTER);
      fill (100);
      if (rocketUp - millis() <= 1500)
        fill (100, 255 - map (rocketUp - millis(), 0, 1500, 0, 255));
      text ("Rocket Unlocked\nPress \'2\' To Use", width / 2, height / 2);
    }

    if (mGunUp - millis() >= 0) {
      textAlign (CENTER, CENTER);
      fill (100);
      if (mGunUp - millis() >= 1500)
        fill (100, 255 - map (mGunUp - millis(), 0, 1500, 0, 255));
      text ("Machine Gun Unlocked\nPress \'3\' To Use", width / 2, height / 2);
    }

    textAlign (RIGHT, BOTTOM);
    fill (100);
    text ("Level: " + ship.level, width - 25, height - 60);
    text ("XP: " + ship.xp + "/" + ship.level * 1000, width - 25, height - 95);

    drawOutline (width / 4, height - 55, color (110), 5, width / 2, 30);
    fill (100);
    rect (width / 4 + 5, height - 50, (int) ((ship.hp / 100.0) * (width / 2 - 10)), 21);

    textAlign (RIGHT, BOTTOM);
    fill (100);
    text ("Score: " + ship.score, width - 25, height - 25);

    textAlign (LEFT, BOTTOM);
    fill (100);
    text (wave, 25, height - 25);
  }

  void update (EnemyCom eCom, Ship ship) {
    if (millis() - eCom.waveStart <= 3500) {
      if (millis() - eCom.waveStart >= 2000)
        fill (100, 255 - map (millis() - eCom.waveStart, 2000, 3500, 0, 255));
      else
        fill (100);
      textAlign (CENTER, CENTER);
      text ("Wave " + wave, width / 2, height / 2);
    }

    drawOutline (20, height - 410, color (90), 5, 30, 260); 
    fill (80);
    rect (25, height - 154, 20, (int)((ship.hp / 100.0) * -251)); 
    image (p1, 35, height - 130);

    textAlign (RIGHT, BOTTOM);
    fill (100);
    text ("Score: " + ship.score, width - 25, height - 25);

    wave = eCom.wave;
    textAlign (LEFT, BOTTOM);
    fill (100);
    text (wave, 25, height - 25);
  }

  void update (EnemyCom eCom, Ship ship1, Ship ship2) {
    if (millis() - eCom.waveStart <= 3500) {
      if (millis() - eCom.waveStart >= 2000)
        fill (100, 255 - map (millis() - eCom.waveStart, 2000, 3500, 0, 255));
      else
        fill (100);
      textAlign (CENTER, CENTER);
      text ("Wave " + wave, width / 2, height / 2);
    }

    drawOutline (20, height - 410, color (90), 5, 30, 260); 
    fill (80);
    rect (25, height - 154, 20, (int)((ship1.hp / 100.0) * -251)); 
    image (p1, 35, height - 130);

    drawOutline (width - 50, height - 410, color (120), 5, 30, 260); 
    fill (110);
    rect (width - 45, height - 154, 20, (int)((ship2.hp / 100.0) * -251)); 
    image (p2, width - 35, height - 130);

    textAlign (RIGHT, BOTTOM);
    fill (100);
    text ("Score: " + ship1.score, width - 25, height - 25);

    wave = eCom.wave;
    textAlign (LEFT, BOTTOM);
    fill (100);
    text (wave, 25, height - 25);
  }

  void update (int gameMode, int p1Health, int p2Health, int p1Ammo, int p2Ammo) {
    if (gameMode == 1) {
    } else if (gameMode == 2) { 
      textFont (menu);
      textSize (32);
      textAlign (LEFT, TOP);
      fill (255, 0, 0);
      text ("Player 1", 25, height / 2 + 16);
      textAlign (RIGHT, BOTTOM);
      text (p1Ammo + "/10", width - 40, height - 25);
      drawOutline (20, height - 50, color (255, 0, 0), 5, 260, 25);
      fill (200, 0, 0);
      rect (25, height - 29, 250 * (p1Health / 100.0), -16);
      textAlign (LEFT, BOTTOM);
      fill (0, 64, 255);
      text ("Player 2", 25, height / 2 - 16, 32);
      textAlign (RIGHT, TOP);
      text (p2Ammo + "/10", width - 40, 25);
      drawOutline (20, 20, color (0, 64, 255), 5, 260, 25);
      fill (0, 32, 200);
      rect (25, 25, 250 * (p2Health / 100.0), 16);
      textAlign (CENTER, CENTER);
    } else if (gameMode == 3) {
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int gameMode, int winner) {
    if (gameMode == 5) {
      if (winner == 1)
        fill (255, 0, 0);
      else
        fill (0, 64, 255);
      textFont (menu);
      text ("Game Over", width / 2, height / 2.5);
      textSize (40);
      text ("Winner", width / 2, height - height / 2.25);
      if (winner == 1)
        image (player1, width / 2, height - height / 2.5);
      else if (winner == 2)
        image (player2, width / 2, height - height / 2.5);
      if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100 && mouseY > height - height / 5 - 20 && mouseY < height - height / 5 + 20) {
        if (winner == 1)
          fill (127, 0, 0);
        else
          fill (0, 32, 127);
        if (mousePressed) {
          gMode = 0;
        }
      }
      text ("Main Menu", width / 2, height - height / 5);
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int score, int wave, int hsS, int hsW) { 
    textAlign (CENTER, CENTER);
    fill (100);
    textSize (100);
    text ("Game Over", width / 2, height / 3);
    textSize (40);
    if (wave > 1)
      text ("You Survived " + wave + " Waves", width / 2, height / 2);
    else
      text ("You Survived " + wave + " Wave", width / 2, height / 2);
    text ("With A Score Of " + score, width / 2, height / 2 + 50);
    text ("Highscores:", width / 2, height / 2 + 125);
    text (hsS + " Points", width / 2, height / 2 + 170);
    text (hsW + " Waves", width / 2, height / 2 + 215);
    if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100 && mouseY > height - height / 5 - 20 && mouseY < height - height / 5 + 20) {
      fill (50);
      if (mousePressed) {
        gMode = 0;
      }
    }
    text ("Main Menu", width / 2, height - height / 5);
    textSize (35);
  }

  void loadSolo() {
    map.update (gameMode);

    textSize (100);
    textAlign (CENTER, BOTTOM);
    text ("Loading...", width / 2, height / 2 - 50);

    drawOutline (width / 4, height / 2, color (110), 5, width / 2, 50);
    fill (100);
    rect (width / 4 + 5, height / 2 + 5, map ((int) soloLoad, 0, 100, 0, width / 2 - 5), 41);

    textSize (35);
  }

  void pauseMenu(Audio audio) { //get bg image b4 paused
    image (pauseBg, width / 2, height / 2);
    fill (100);
    textAlign (CENTER, CENTER);
    textSize (100); 
    text ("Paused", width / 2, height / 4);
    textAlign (CENTER, BOTTOM);
    textSize (35);
    text ("Now Playing: " + audio.bgMetaData[audio.track].title() + " by " + audio.bgMetaData[audio.track].author(), width / 2, height - 50);
    hover ("<<", width / 2 - 50, height - 100, 1);
    hover ("| |", width / 2, height - 100, 2);
    hover (">>", width / 2 + 50, height - 100, 3);

    hover ("Unpause", width / 2, height / 2, 4);
    hover ("Main Menu", width / 2, height / 2 + 100, 5);
  }

  int gameModeSet() {
    return gMode;
  }

  boolean pauseSet() {
    return paused;
  }

  void hover (String text, int x, int y, int id) {
    if (mouseX >= x - (text.length() * 6) && mouseX <= x + (text.length() * 6) && mouseY >= y - 10 && mouseY <= y + 10) {
      fill (50);
      if (mousePressed && millis() - timeOut > 500) {
        if (id == 1)
          audio.changeTrack (false);
        if (id == 2)
          audio.play = !audio.play;
        if (id == 3)
          audio.changeTrack (true);
        if (id == 4)
          paused = false;
        if (id == 5) 
          reset();
        timeOut = millis();
      }
    }
    textAlign (CENTER, CENTER);
    textSize (35);
    text (text, x, y);
    fill (100);
  }

  void drawOutline (int x, int y, color c, int t, int l, int h) {
    noFill();
    stroke (c);
    for (int i = 0; i < t; i++) {
      rect (x + i, y + i, l - (i * 2) - 1, h - (i * 2));
    }
    fill (100);
    noStroke();
  }

  color colour (int type) {
    color c = color (255);
    if (type == 2)
      c = #ffffad;
    else if (type == 3)
      c = #ff5353;
    else if (type == 4)
      c = #38ff38;
    return c;
  }

  void arrow (int eX, int eY) {
    float angle = 0;
    float a = pow ((width / 2 - eX) * (width / 2 - eX) + (height / 2 - eY) * (height / 2 - eY), 0.5); //getting the distances of the triangle formed by the mouse, the ship and the x-axis
    float b = pow ((width / 2 - eX) * (width / 2 - eX), 0.5);
    float c = pow ((height / 2 - eY) * (height / 2 - eY), 0.5);
    int x = width / 2;
    int y = height / 2;

    angle = atan2 (eX - width / 2, eY - height / 2);
    angle = (HALF_PI - angle) + HALF_PI;

    pushMatrix();
    translate (x, y);
    rotate (angle);
    image (arrow, 0, 0);
    popMatrix();
  }

  int closest (ArrayList<Enemy> enemies) {
    int id = 0;
    float smallest = pow (pow (enemies.get (0).screenX - width / 2, 2) + pow (enemies.get (0).screenY - height / 2, 2), 0.5);
    for (int i = 1; i < enemies.size(); i++) {
      if (pow (pow (enemies.get (i).screenX - width / 2, 2) + pow (enemies.get (i).screenY - height / 2, 2), 0.5) < smallest) {
        smallest = pow (pow (enemies.get (i).screenX - width / 2, 2) + pow (enemies.get (i).screenY - height / 2, 2), 0.5);
        id = i;
      }
    }
    return id;
  }
}