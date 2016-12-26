class EnemyCom {
  ArrayList<Enemy> enemies = new ArrayList<Enemy>();
  int wave = 0;
  int waveStart = 0;
  int rEnemies = 0;
  final int enemyCap = 20;

  final int maxHp = 5;
  Hp[] hp = new Hp[maxHp];
  int hpAvailable = 0;

  EnemyCom(ArrayList<Enemy> e) { 
    enemies = e;
    for (int i = 0; i < maxHp; i++) {
      hp[i] = new Hp();
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Enemy> e, Ship ship, Ship ship2) {
    for (int i = 0; i < maxHp; i++) {
      hp[i].update (ship);
      hp[i].update (ship2);
    }
    enemies = e;
    for (int i = 0; i < enemies.size(); i++) {
      enemies.get (i).update (ship, ship2);
      if (enemies.get (i).dead) {
        enemies.remove (i);
        for (int n = 0; n < enemies.size(); n++)
          enemies.get (n).update (ship, ship2);
        break;
      }
    }

    if (enemies.size() <= 0) {
      wave++;
      waveStart = millis() + 500;
      if (!twoPlayer) {
        rEnemies = (int) pow ((wave * wave * wave), 0.5) + 5;
        if (ship.fireRate > 10)
          ship.fireRate = 75 - wave + 1;
        ship.shipSpeed = 12 + wave / 3;
      } else {
        rEnemies = 2 * ((int) pow ((wave * wave * wave), 0.5) + 5);
        if (ship.fireRate > 10) {
          ship.fireRate = 75 - wave + 1;
          ship2.fireRate = 75 - wave + 1;
        }
        ship.shipSpeed = 12 + wave / 3;
        ship2.shipSpeed = 12 + wave / 3;
      }
      ship.score += (wave - 1) * 100;
    }

    if (enemies.size() < enemyCap && rEnemies > 0) {
      rEnemies--;
      addEnemies (1);
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (ArrayList<Enemy> e, Ship ship) {
    for (int i = 0; i < maxHp; i++) {
      hp[i].update (ship);
    }
    enemies = e;
    for (int i = 0; i < enemies.size(); i++) {
      enemies.get (i).update (ship);
      if (enemies.get (i).dead) {
        enemies.remove (i);
        for (int n = 0; n < enemies.size(); n++)
          enemies.get (n).update (ship);
        break;
      }
    }

    if (enemies.size() <= 0) {
      wave++;
      waveStart = millis() + 500;
      if (!twoPlayer) {
        rEnemies = (int) pow ((wave * wave * wave), 0.5) + 5;
        if (ship.fireRate > 10)
          ship.fireRate = 75 - wave + 1;
        ship.shipSpeed = 12 + wave / 3;
      } else {
        rEnemies = 2 * ((int) pow ((wave * wave * wave), 0.5) + 5);
        if (ship.fireRate > 10) {
          ship.fireRate = 75 - wave + 1;
        }
        ship.shipSpeed = 12 + wave / 3;
      }
      ship.score += (wave - 1) * 100;
    }

    if (enemies.size() < enemyCap && rEnemies > 0) {
      rEnemies--;
      addEnemies (1);
    }
  }

  void addEnemies (int numToAdd) {
    int speed = 1 + wave / 4;
    if (speed > 5)
      speed = 5;
    for (int i = 0; i < numToAdd; i++) {
      enemies.add (new Enemy (1 + wave / 4));
    }
  }

  void  hpDrop (int x, int y, float rate) {
    if (wave % ((int) rate + 1) == 0) {
      if ((int) random (0, 20) == 0) {
        hp[hpAvailable].active = true;
        hp[hpAvailable].setCoords (x, y);
        hpAvailable++;
        if (hpAvailable >= 5)
          hpAvailable = 0;
      }
    }
  }
}