boolean up, down, left, right, w, a, s, d, space, m; //move booleans

class Ship {
  PImage shipI;
  Polygon hitBox;
  int[] hitBoxX = new int[4];
  int[] hitBoxY = new int[4];
  int screenMoveX = 0;
  int screenMoveY = 0;
  int mapMoveX = 0;
  int mapMoveY = 0;
  int screenX;
  int screenY;
  int id;

  int hpDelay = 0;
  int hp = 100;
  int ammo = 10;
  int score = 0;
  int xp = 8999;
  int level = 9;

  int fireRate = 100;
  int baseFireRate = 200;
  int fireRateS = 200;
  int lastShot = -fireRate;
  int rechargeRate = fireRate * 3;
  int lastRecharge = -rechargeRate;
  int shipSpeed = 8;
  int multiplier = shipSpeed;
  int bonus = 0;
  int explosionId = 0;
  boolean dead = false;
  boolean[] collidePlanet = new boolean[planetMax];
  boolean rocket = false;
  boolean mGun = false;
  boolean laserActive = true;
  boolean rocketActive = false;
  boolean mGunActive = false;
  boolean levelUp = false;

  int instakill = 0;
  int bombr = 0;
  int speedUp = 0;

  char shootKey = ' ';

  Ship (int x, int y, int idIn) { //constructor of the ship
    shipI = loadImage ("/res/Ship.png");
    screenX = x; //sets spawn to middle of screen
    screenY = y;
    id = idIn;
    hitBoxUpdate();

    if (id == 1) {
      shipI = loadImage ("/res/Ship2.png");
    } else if (id == 2) {
      shipI = loadImage ("/res/Ship3.png");
    }
  }

  Ship (int x, int y, int idIn, int image) { //constructor of the ship
    shipI = loadImage ("/res/Ship.png");
    screenX = x; //sets spawn to middle of screen
    screenY = y;
    id = idIn;
    hitBoxUpdate();

    if (image == 0) {
      shipI = loadImage ("/res/Ship.png");
    } else if (image == 1) {
      shipI = loadImage ("/res/Ship2.png");
    } else if (image == 2) {
      shipI = loadImage ("/res/Ship3.png");
    } else if (image == 3) {
      shipI = loadImage ("/res/Ship1.png");
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update(Gamespace map, int gameMode, ArrayList<Shot> shots, Audio audio) { //main update method of the class
    shoot (shots, gameMode, audio);
    deathCheck();
    hitBoxUpdate();
    hitCheckS (soloEnemies);

    multiplier = shipSpeed;

    if (gameMode == 1) { 
      shipSpeed = 12;

      move1();
      draw1();
    } else if (gameMode == 2) {
      shipSpeed = 20;

      shotCheck (shots);
      move2();
      draw2();
    } else {
      shipSpeed = 8 + bonus;

      move3(map);
      draw3();

      if (hp < 100 && millis() - hpDelay >= 1000) {
        hp += 1;
        if (hp > 100)
          hp = 100;
        hpDelay = millis();
      }
    }
    for (int i = 0; i < asteroids.size(); i++) {
      if (pow (pow (asteroids.get (i).screenX - screenX, 2) + pow (asteroids.get (i).screenY - screenY, 2), 0.5) <= asteroidImg[asteroids.get (i).imgNum].width / 2 + shipI.width / 2) {
        asteroids.remove (i);
        hp -= 30;
      }
    }
    for (int i = 0; i < powerups.size(); i++) {
      if (hitBox.contains (powerups.get (i).screenX - powerupImg[powerups.get (i).type].width / 2, powerups.get (i).screenY - powerupImg[powerups.get (i).type].height / 2) || hitBox.contains (powerups.get (i).screenX - powerupImg[powerups.get (i).type].width / 2, powerups.get (i).screenY + powerupImg[powerups.get (i).type].height / 2) || hitBox.contains (powerups.get (i).screenX + powerupImg[powerups.get (i).type].width / 2, powerups.get (i).screenY - powerupImg[powerups.get (i).type].height / 2) || hitBox.contains (powerups.get (i).screenX + powerupImg[powerups.get (i).type].width / 2, powerups.get (i).screenY + powerupImg[powerups.get (i).type].height / 2)) {
        if (powerups.get (i).type == 0) {
          instakill = millis() + 15000;
        } else if (powerups.get (i).type == 1) {
          bombr = millis() + 10000;
          explosions.add (new Animation ("/res/Explosion", 8));
          explosionId = explosions.size() - 1;
        } else if (powerups.get (i).type == 2) {
          speedUp = millis() + 20000;
          bonus = shipSpeed;
        } else if (powerups.get (i).type == 3) {
          xp = 0;
          levelUp = true;
        } else {
          hp = 100;
        }

        powerups.remove (i);
        break;
      }
    }

    if (xp >= level * 1000 || levelUp) {
      xp = xp % (level * 1000);
      level++;
      shipSpeed = (int) (shipSpeed * 1.25);
      baseFireRate = (int) (baseFireRate * 0.9);
      if (level >= 7) {
        rocket = true;
        if (level == 7)
          hud.rocketUp = millis() + 3500;
      }
      if (level >= 10) {
        mGun = true;
        if (level == 10)
          hud.mGunUp = millis() + 3500;
      }
      levelUp = false;
    }

    if (speedUp - millis() < 0)
      bonus = 0;

    if (explosions.size() > 0) {  
      if (bombr - millis() >= 0) {
        explosions.get (explosionId).display = true;
      }

      for (int i = 0; i < explosions.size(); i++) {
        explosions.get (i).update (screenX, screenY);
      }
    }

    if (laserActive) {
      fireRateS = baseFireRate;
    } else if (rocketActive) {
      fireRateS = baseFireRate * 2;
    } else if (mGunActive) {
      fireRateS = (int) (baseFireRate / 2.0);
    }

    //println ("X: " + worldX + " Y: " + worldY);
    //println ("X: " + (int) (width / 2 - map.x) + " Y: " + (int) (height / 2 - map.y));
  }  

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update(Gamespace map, int gameMode, ArrayList<Shot> shots, Audio audio, ArrayList<Enemy> enemies) { //main update method of the class
    shoot (shots, gameMode, audio);
    deathCheck();
    hitBoxUpdate();
    hitCheck (enemies);

    if (gameMode == 1) { 
      if (shipSpeed < 12)
        shipSpeed = 12;

      move1();
      draw1();
    } else if (gameMode == 2) {
      shipSpeed = 20;

      shotCheck (shots);
      move2();
      draw2();
    } else {
      shipSpeed = 8;

      move3(map);
      draw3();
    }
  }

  void shoot(ArrayList<Shot> shots, int gameMode, Audio audio) {
    if (gameMode == 1) {
      if (id == 0) {
        if (m && millis() - lastShot > fireRate) {
          audio.shoot();
          shots.add (new Shot (screenX, screenY, screenX, 0, shots.size(), id, 20));
          lastShot = millis();
        }
      } else {
        if (space && millis() - lastShot > fireRate) {
          audio.shoot();
          shots.add (new Shot (screenX, screenY, screenX, 0, shots.size(), id, 20));
          lastShot = millis();
        }
      }
    } else if (gameMode == 2) {
      if (ammo > 0) {
        if (id == 1) {
          if (m && millis() - lastShot > fireRate) {
            audio.shoot();
            shots.add (new Shot (screenX, screenY, screenX, 0, shots.size(), id));
            lastShot = millis();
            ammo--;
          }
        } else {
          if (space && millis() - lastShot > fireRate) {
            audio.shoot();
            shots.add (new Shot (screenX, screenY, screenX, height, shots.size(), id));
            lastShot = millis();
            ammo--;
          }
        }
      }
      if (ammo == 10)
        lastRecharge = millis();
      if (ammo < 10 && millis() - rechargeRate > lastRecharge) {
        ammo++;
        lastRecharge = millis();
      }
    } else {
      if (mousePressed && millis() - lastShot > fireRateS) { //if the mouse is pressed and the shot cooldown is good
        audio.shoot();
        shots.add (new Shot (screenX, screenY, mouseX, mouseY, shots.size(), id));
        lastShot = millis(); //reset the cooldown time
      }
    }
  }

  void shotCheck(ArrayList<Shot> shots) {
    for (int i = 0; i < shots.size(); i++) {
      if (id != shots.get(i).playerId && shots.get(i).screenX <= screenX + (shipI.width / 2) && shots.get(i).screenX >= screenX - (shipI.width / 2) && shots.get(i).screenY <= screenY + (shipI.height / 2) && shots.get(i).screenY >= screenY - (shipI.height / 2)) {
        shots.get(i).destroy(shots);
        hp -= 10;
      }
    }
  }

  void deathCheck() {
    if (hp < 0)
      hp = 0;
    if (hp <= 0) 
      dead = true;
    else
      dead = false;
  }

  void move1() {
    if (id == 0) {
      if (w)
        screenY -= shipSpeed;
      if (s)
        screenY += shipSpeed;
      if (a)
        screenX -= shipSpeed;
      if (d)
        screenX += shipSpeed;
    } else {
      if (up)
        screenY -= shipSpeed;
      if (down)
        screenY += shipSpeed;
      if (left)
        screenX -= shipSpeed;
      if (right)
        screenX += shipSpeed;
    }

    if (screenY > height - shipI.height / 2)
      screenY = height - shipI.height / 2;
    if (screenY < shipI.height / 2) 
      screenY = shipI.height / 2;
    if (screenX > width - shipI.width / 2)
      screenX = width - shipI.width / 2;
    if (screenX < shipI.width / 2)
      screenX = shipI.width / 2;
  }

  void move2() {
    if (id == 1) {
      if (w)
        screenY -= shipSpeed;
      if (s)
        screenY += shipSpeed;
      if (a)
        screenX -= shipSpeed;
      if (d)
        screenX += shipSpeed;
    } else {
      if (up)
        screenY -= shipSpeed;
      if (down)
        screenY += shipSpeed;
      if (left)
        screenX -= shipSpeed;
      if (right)
        screenX += shipSpeed;
    }

    if (screenY > height - shipI.height / 2)
      screenY = height - shipI.height / 2;
    if (screenY < shipI.height / 2) 
      screenY = shipI.height / 2;
    if (screenX > width - shipI.width / 2)
      screenX = width - shipI.width / 2;
    if (screenX < shipI.width / 2)
      screenX = shipI.width / 2;
    if (id == 1) {
      if (screenY < height / 2 + shipI.height / 2) 
        screenY = height / 2 + shipI.height / 2;
    } else {
      if (screenY > height / 2 - shipI.height / 2) 
        screenY = height / 2 - shipI.height / 2;
    }
  }

  void move3(Gamespace map) { //moves the ship based on its move booleans
    if (up && screenY > height / 5) {
      screenY -= shipSpeed;
    } 
    if (down && screenY < (height - (height / 5))) {
      screenY += shipSpeed;
    }
    if (left && screenX > width / 5) { 
      screenX -= shipSpeed;
    }
    if (right && screenX < (width - (width / 5))) {
      screenX += shipSpeed;
    }
    if (up && screenY <= height / 5 && map.y < 1500 && !planetsCheck (collidePlanet)) {
      map.y += 1;
      screenMoveY = multiplier;
      mapMoveY = 1;
    } else if (!down) {
      screenMoveY = 0;
      mapMoveY = 0;
    } 
    if (down && screenY >= (height - (height / 5)) && map.y > -500 && !planetsCheck (collidePlanet)) {
      map.y -= 1;
      screenMoveY = -multiplier;
      mapMoveY = -1;
    } else if (!up) {
      screenMoveY = 0;
      mapMoveY = 0;
    } 
    if (left && screenX <= width / 5 && map.x < 1500 && !planetsCheck (collidePlanet)) {
      map.x += 1;
      screenMoveX = multiplier;
      mapMoveX = 1;
    } else if (!right) {
      screenMoveX = 0;
      mapMoveX = 0;
    } 
    if (right && screenX >= (width - (width / 5)) && map.x > -500 && !planetsCheck (collidePlanet)) {
      map.x -= 1;
      screenMoveX = -multiplier;
      mapMoveX = -1;
    } else if (!left) {
      screenMoveX = 0;
      mapMoveX = 0;
    }
    if (screenY < height / 5)
      screenY = height / 5;
    if (screenY > (height - (height / 5)))
      screenY = (height - (height / 5));
    if (screenX < width / 5)
      screenX = width / 5;
    if (screenX > (width - (width / 5)))
      screenX = (width - (width / 5));
  }

  void draw1() {
    image (shipI, screenX, screenY);
  }

  void draw2() {
    if (id == 1) {
      pushMatrix(); //rotating the object and drawing it onscreen
      translate (screenX, screenY);
      image (shipI, 0, 0);
      popMatrix();
    } else {
      pushMatrix(); //rotating the object and drawing it onscreen
      translate (screenX, screenY);
      rotate (PI);
      image (shipI, 0, 0);
      popMatrix();
    }
  }

  void draw3() {
    float a = pow (pow (mouseX - screenX, 2) + pow (mouseY - screenY, 2), 0.5); //getting the distances of the triangle formed by the mouse, the ship and the x-axis
    float b = pow (pow (mouseX - screenX, 2), 0.5);
    float c = pow (pow (mouseY - screenY, 2), 0.5);

    float angle = 0;
    if (b != 0)
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (-2 * a * b)); //finding the angle from the x-axis
    else if (mouseY < screenY)
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (-2 * a));
    else if (mouseY > screenY) {
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (2 * a));
      angle -= PI;
    }
    angle = HALF_PI - angle; //modifying the angle so the ship rotates correctly

    if (mouseX > screenX && mouseY < screenY) { //Q1 //changing the angle to fit each quadrant so rotation works
    } else if (mouseX < screenX && mouseY < screenY) { //Q2
      angle = TWO_PI - angle;
    } else if (mouseX < screenX && mouseY > screenY) { //Q3
      angle = PI + angle;
    } else if (mouseX > screenX && mouseY > screenY) { //Q4
      angle = PI - angle;
    }

    pushMatrix(); //rotating the object and drawing it onscreen
    translate (screenX, screenY);
    rotate (angle);
    image (shipI, 0, 0);
    popMatrix();
  }

  void hitBoxUpdate() {
    if (bombr - millis() < 0) {
      hitBoxX[0] = screenX - shipI.width / 2;
      hitBoxX[1] = screenX + shipI.width / 2;
      hitBoxX[2] = screenX + shipI.width / 2;
      hitBoxX[3] = screenX - shipI.width / 2;
      hitBoxY[0] = screenY - shipI.height / 2;
      hitBoxY[1] = screenY - shipI.height / 2;
      hitBoxY[2] = screenY + shipI.height / 2;
      hitBoxY[3] = screenY + shipI.height / 2;
    } else {
      hitBoxX[0] = screenX - 50;
      hitBoxX[1] = screenX + 50;
      hitBoxX[2] = screenX + 50;
      hitBoxX[3] = screenX - 50;
      hitBoxY[0] = screenY - 50;
      hitBoxY[1] = screenY - 50;
      hitBoxY[2] = screenY + 50;
      hitBoxY[3] = screenY + 50;
    }
    hitBox = new Polygon (hitBoxX, hitBoxY, 4);
  }

  void hitCheck (ArrayList<Enemy> enemies) {
    for (int i = 0; i < enemies.size(); i++) {
      int hW = enemies.get (i).halfWide;
      int hH = enemies.get (i).halfHigh;
      int sX = enemies.get (i).screenX;
      int sY = enemies.get (i).screenY;
      if (hitBox.contains (sX - hW, sY - hH) || hitBox.contains (sX - hW, sY + hH) || hitBox.contains (sX + hW, sY - hH) || hitBox.contains (sX + hW, sY + hH)) {
        if (enemies.get (i).type == 4)
          hp -= 20;
        else if (enemies.get (i).type == 5)
          hp -= 25;
        else
          hp -= 10;
        enemies.remove (i);
        break;
      }
    }
  }

  void hitCheckS (ArrayList<Enemy> enemiesS) {
    for (int i = 0; i < enemiesS.size(); i++) {
      int hW = enemiesS.get (i).halfWide;
      int hH = enemiesS.get (i).halfHigh;
      int sX = enemiesS.get (i).screenX;
      int sY = enemiesS.get (i).screenY;
      if (bombr - millis() < 0) {
        if (hitBox.contains (sX - hW, sY - hH) || hitBox.contains (sX - hW, sY + hH) || hitBox.contains (sX + hW, sY - hH) || hitBox.contains (sX + hW, sY + hH) || hitBox.contains (sX, sY - hW) || hitBox.contains (sX, sY + hW)) {
          if (enemiesS.get (i).type == 4)
            hp -= 20;
          else if (enemiesS.get (i).type == 5)
            hp -= 25;
          else
            hp -= 10;
          hpDelay = millis() + 2000;
          enemiesS.remove (i);
          break;
        }
      } else {
        if (hitBox.contains (sX - hW, sY - hH) || hitBox.contains (sX - hW, sY + hH) || hitBox.contains (sX + hW, sY - hH) || hitBox.contains (sX + hW, sY + hH) || hitBox.contains (sX, sY - hW) || hitBox.contains (sX, sY + hW)) {
          enemiesS.remove (i);
          break;
        }
      }
    }
  }

  boolean planetsCheck (boolean[] collidePlanet) {
    boolean output = false;
    for (int i = 0; i < collidePlanet.length; i++) {
      if (collidePlanet[i])
        output = true;
    }
    return output;
  }
}

//Input handlers for spaceship
void keyPressed() { //sets move booleans to true if keys are pressed
  if (key == 'w')
    up = true;
  if (key == 's')
    down = true;
  if (key == 'a')
    left = true;
  if (key == 'd')
    right = true;
  if (keyCode == UP)
    w = true;
  if (keyCode == DOWN)
    s = true;
  if (keyCode == LEFT)
    a = true;
  if (keyCode == RIGHT)
    d = true;
  if (key == p2Shoot || keyCode == p2Shoot)
    m = true;
  if (key == p1Shoot || keyCode == p1Shoot)
    space = true;
  if (key == ESC) {    
    key = 0;
    if (millis() - hud.timeOut >= 200 && gameMode != 0) {
      hud.pauseBg = createImage (width, height, RGB);
      loadPixels();
      for (int i = 0; i < width * height; i++)
        hud.pauseBg.pixels[i] = pixels[i];

      hud.paused = !hud.paused;
      hud.timeOut = millis();
    }
  }
  if (key == '1') {
    ship.laserActive = true;
    ship.rocketActive = false;
    ship.mGunActive = false;
  } else if (key == '2') {
    if (ship.rocket) {
      ship.laserActive = false;
      ship.rocketActive = true;
      ship.mGunActive = false;
    }
  } else if (key == '3') {
    if (ship.mGun) {
      ship.laserActive = false;
      ship.rocketActive = false;
      ship.mGunActive = true;
    }
  }
}

void keyReleased() { //sets move booleans to false if keys are released
  if (key == 'w')
    up = false;
  if (key == 's')
    down = false;
  if (key == 'a')
    left = false;
  if (key == 'd')
    right = false;
  if (keyCode == UP)
    w = false;
  if (keyCode == DOWN)
    s = false;
  if (keyCode == LEFT)
    a = false;
  if (keyCode == RIGHT)
    d = false;
  if (key == p2Shoot || keyCode == p2Shoot)
    m = false;
  if (key == p1Shoot || keyCode == p1Shoot)
    space = false;
}