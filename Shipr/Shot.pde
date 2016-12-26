class Shot {
  float screenX;
  float screenY;
  int targetX;
  int targetY;
  int id;
  int playerId;
  int multiplier = 1;
  float xChange;
  float yChange;
  float slope;
  float speed = 20;

  Shot (int sX, int sY, int mX, int mY, int idTag, int type) {
    screenX = sX;
    screenY = sY;
    targetX = mX;
    targetY = mY;
    id = idTag;
    playerId = type;

    xChange = targetX - screenX;
    yChange = targetY - screenY;
    //print ("X1: " + xChange + " Y1: " + yChange);
    slope = (float) yChange / (float) xChange;
    if (abs (xChange) > abs (yChange)) { //making the bullets the same speed no matter what the direction is
      yChange /= abs (xChange);
      xChange /= abs (xChange);
    } else {
      xChange /= abs (yChange);
      yChange /= abs (yChange);
    }
    xChange *= speed; //making the bullets faster
    yChange *= speed;
    //println (" X2: " + xChange + " Y2: " + yChange);
  }

  Shot (int sX, int sY, int mX, int mY, int idTag, int type, int s) {
    speed = s;
    screenX = sX;
    screenY = sY;
    targetX = mX;
    targetY = mY;
    id = idTag;
    playerId = type;

    xChange = targetX - screenX;
    yChange = targetY - screenY;
    //print ("X1: " + xChange + " Y1: " + yChange);
    slope = (float) yChange / (float) xChange;
    if (abs (xChange) > abs (yChange)) { //making the bullets the same speed no matter what the direction is
      yChange /= abs (xChange);
      xChange /= abs (xChange);
    } else {
      xChange /= abs (yChange);
      yChange /= abs (yChange);
    }
    xChange *= speed; //making the bullets faster
    yChange *= speed;
    //println (" X2: " + xChange + " Y2: " + yChange);
  }
  
  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Shot> shots) {
    move(shots);
    draw();
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Shot> shots, ArrayList<Enemy> enemies, EnemyCom eCom, Ship ship) {
    hitCheck (enemies, eCom, ship);
    move(shots);
    draw();
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Shot> shots, ArrayList<Enemy> enemies, Ship ship) {
    hitCheck (enemies, planets, ship);
    move(shots);
    draw();
  }

  void draw() {
    fill (255);
    if (playerId == 1)
      fill (255, 0, 0);
    else if (playerId == 2)
      fill (0, 64, 255);
      if (ship.rocketActive)
    ellipse (screenX, screenY, 25, 25);
      else
    ellipse (screenX, screenY, 10, 10);
  }

  void move (ArrayList<Shot> shots) {
    screenX += xChange;
    screenY += yChange;
    //println ("X: " + screenX + " Y: " + screenY);
    if ((screenX < 0 || screenX > width) || (screenY < 0 || screenY > height)) { //destroying the bullet upon reaching the screen boundary
      destroy (shots);
    }
  }

  void hitCheck (ArrayList<Enemy> enemies, EnemyCom eCom, Ship ship) {
    for (int i = 0; i < enemies.size(); i++) {
      if (screenX >= enemies.get(i).screenX - enemies.get(i).halfWide && screenX <= enemies.get(i).screenX + enemies.get(i).halfWide && screenY >= enemies.get(i).screenY - enemies.get(i).halfHigh && screenY <= enemies.get(i).screenY + enemies.get(i).halfHigh) {
        eCom.hpDrop (enemies.get (i).screenX, enemies.get (i).screenY, (float) (ship.fireRate) / ship.shipSpeed);
        enemies.remove(i);
        ship.score += 100;
        destroy (shots);
        break;
      }
    }
  }

  void hitCheck (ArrayList<Enemy> enemiesS, ArrayList<Planet> planets, Ship ship) {
    for (int i = 0; i < enemiesS.size(); i++) {
      if ((int) (pow (pow (enemiesS.get (i).screenX - screenX, 2) + pow (enemiesS.get (i).screenY - screenY, 2), 0.5)) <= enemiesS.get (i).halfHigh + 5) {
        //if (screenX >= enemiesS.get(i).screenX - enemiesS.get(i).halfWide && screenX <= enemiesS.get(i).screenX + enemiesS.get(i).halfWide && screenY >= enemiesS.get(i).screenY - enemiesS.get(i).halfHigh && screenY <= enemiesS.get(i).screenY + enemiesS.get(i).halfHigh) {
        if (enemiesS.get (i).type == 1) {
          ship.score += 10;
          ship.xp += 10;
        } else if (enemiesS.get (i).type != 5) {
          ship.score += 25;
          ship.xp += 25;
        } else {
          ship.score += 50;
          ship.xp += 100;
        }
        if (ship.instakill - millis() >= 0)
          enemiesS.get (i).hp -= enemiesS.get (i).hp;
        else {
          if (ship.laserActive) 
            enemiesS.get (i).hp -= 10;
          else if (ship.rocketActive)
            enemiesS.get (i).hp -= 40;
          else if (ship.mGunActive)
            enemiesS.get (i).hp -= 20;
        }
        enemiesS.get (i).deathCheck();
        destroy (shots);
        break;
      }
    }

    for (int i = 0; i < planets.size(); i++) {
      if (pow ( pow (screenX - planets.get (i).screenX, 2) + pow (screenY - planets.get (i).screenY, 2), 0.5) <= planets.get (i).pImage.width / 2) {
        planets.get (i).hp -= 10;
        ship.score += 10;
        destroy (shots);
      }
    }

    for (int i = 0; i < spaceShips.size(); i++) {
      if ((int) pow (pow (screenX - spaceShips.get (i).screenX, 2) + pow (screenY - spaceShips.get (i).screenY, 2), 0.5) <= spaceShip.width / 2) {
        circEx.display = true;
        circEx.screenX = spaceShips.get (i).screenX;
        circEx.screenY = spaceShips.get (i).screenY;
        circEx.damageShip = false;
        spaceShips.remove (i);
      }
    }
  }

  void destroy (ArrayList<Shot> shots) {
    if (shots.size() > 0) {
      for (int i = id + 1; i < shots.size(); i++) { //updating other shots id's
        shots.get(i).id--;
      }
      shots.remove (id);
    }
  }
}