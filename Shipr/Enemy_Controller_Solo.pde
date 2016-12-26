class EComSolo {
  ArrayList<Enemy> enemiesS = new ArrayList<Enemy>();
  ESpawn[] eSpawn = new ESpawn[6];
  int wave = 0;
  int waveStart = 0;
  int rEnemies = 0;
  final int enemyCap = 30; //maybe down to 45 - 40 (was 50)
  int lastSpawn = 0;
  final int delaySpawn = 750;
  int chance = 25;

  EComSolo (ArrayList<Enemy> e, ESpawn[] s) {
    enemiesS = e;
    eSpawn = s;
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Enemy> e, ESpawn[] s, Ship ship) {
    enemiesS = e;
    eSpawn = s;

    for (int i = 0; i < enemiesS.size(); i++) {
      enemiesS.get (i).update (ship.screenX, ship.screenY, ship.screenMoveX, ship.screenMoveY);
      if (enemiesS.get (i).type == 5)
        println ("X: " + enemiesS.get (i).screenX + " Y: " + enemiesS.get (i).screenY);
      if (enemiesS.get (i).dead) {
        if (enemiesS.get (i).type == 1)
          ship.score += 100;
        else if (enemiesS.get (i).type != 5)
          ship.score += 250;
        else
          ship.score += 500;
        if ((int) random (chance) == 0) {
          powerups.add (new Powerup (enemiesS.get (i).screenX, enemiesS.get (i).screenY, (int) random (5)));
          chance = 25;
        } else
          chance--;
        enemiesS.remove (i);
        for (int n = 0; n < enemies.size(); n++)
          enemiesS.get (n).update (ship.screenX, ship.screenY, ship.screenMoveX, ship.screenMoveY);
        break;
      }
    }

    if (enemiesS.size() <= 0) {
      ship.xp += 100 * wave;
      wave++;
      waveStart = millis() + 500;
      rEnemies = (int) (pow (2 * wave, 0.5) * 20);
    }

    if (enemiesS.size() < enemyCap && rEnemies > 0 && millis() - lastSpawn >= delaySpawn) {
      rEnemies--;
      addEnemies (1);
      lastSpawn = millis();
    }
  }

  void addEnemies (int n) {
    int speed = 1 + (int) (wave / 4.0);
    if (speed > 4)
      speed = 4;
    for (int i = 0; i < n; i++) {
      int spawner = (int) random (8);
      int type = 0;
      for (int a = 0; a < 3; a++) {
        if (type != 1)
          type = (int) random (1, 5);
      }
      enemiesS.add (new Enemy (eSpawn[spawner].screenX, eSpawn[spawner].screenY, type, speed));
    }
  }
}

class ESpawn {
  PImage spawner;
  int screenX;
  int screenY;

  ESpawn (int x, int y) {
    screenX = x;
    screenY = y;
    spawner = loadImage ("/res/Spawner.png");
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY) {
    image (spawner, screenX, screenY);
    screenX += smX;
    screenY += smY;
  }
}

class Powerup {
  int screenX;
  int screenY;
  int type; //0 = instakill, 1 = bombr, 2 = speedup, 3 = levelup, 4 = hp

  Powerup (int x, int y, int t) {
    screenX = x;
    screenY = y;
    type = t;
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY) {
    screenX += smX;
    screenY += smY;

    if (screenX >= - (powerupImg[type].width / 2) && screenX <= width + (powerupImg[type].width / 2) && screenY >= - (powerupImg[type].height / 2) && screenY <= height + (powerupImg[type].height / 2)) {
      image (powerupImg[type], screenX, screenY);
    }
  }
}