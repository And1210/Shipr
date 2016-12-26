class Gamespace {
  PImage background;
  float x;
  float y;
  float rotate;

  Gamespace () {
    background = loadImage ("/res/Background.png");
    x = width / 2;
    y = height / 2;
    rotate = 0;
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update(int gameMode) {
    if (gameMode == 3)
      image (background, x, y);
    else {
      pushMatrix();
      translate (x, y);
      rotate (rotate);
      image (background, 0, 0);
      popMatrix();
    }
  }
}

class Planet {
  PImage pImage;
  int screenX = 0;
  int screenY = 0;
  int image = 1;
  int area = 0;
  int hp = 1000;
  int initHp = 1000;
  boolean collidingShip = false;
  boolean dead = false;

  Planet (int img, Gamespace map, int q) {
    image = img;
    float rand = random (1);
    if (rand < 0.15) {
      pImage = loadImage ("/res/Planet" + image + ".png");
      hp = 2000;
      initHp = 2000;
    } else if (rand < 0.55) {
      pImage = loadImage ("/res/Planet" + image + "750.png");
      hp = 1500;
      initHp = 1500;
    } else
      pImage = loadImage ("/res/Planet" + image + "500.png");

    area = q;
    quadrant[area] = true;
    int n = (int) pow (planetMax, 0.5);
    int s = (int) (2000 / pow (planetMax, 0.5));
    screenX = (int) random (((area % n) * s + -1025) * ship.shipSpeed + pImage.width / 2, (975 - (abs ((area % n) - (n - 1)) * s)) * ship.shipSpeed - pImage.width / 2);
    screenY = (int) random ((((int) (area / n)) * s + -1025) * ship.shipSpeed + pImage.width / 2, (975 - (abs (((int) (area / n)) - (n - 1)) * s)) * ship.shipSpeed - pImage.width / 2);
    screenX += -1 * (width / 2 - map.x) * ship.shipSpeed;
    screenY += -1 * (height / 2 - map.y) * ship.shipSpeed;

    soloLoad += (100.0 / planetMax);
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (Ship ship, ArrayList<Enemy> enemiesS) {
    deathCheck();
    screenX += ship.screenMoveX;
    screenY += ship.screenMoveY;

    if (screenX >= -(pImage.width / 2) && screenX <= width + (pImage.width / 2) && screenY >= - (pImage.height / 2) && screenY <= height + (pImage.height / 2)) {
      image (pImage, screenX, screenY);

      if (pow (pow (screenX - ship.screenX, 2) + pow (screenY - ship.screenY, 2), 0.5) < pImage.width / 2 + ship.shipI.width / 2) {
        collidingShip = true;
      } else {
        collidingShip = false;
      }
      if (collidingShip) {
        if (ship.screenX < screenX)
          ship.screenX -= ship.shipSpeed;
        else if (ship.screenX > screenX)
          ship.screenX += ship.shipSpeed;
        if (ship.screenY < screenY)
          ship.screenY -= ship.shipSpeed;
        else if (ship.screenY > screenY)
          ship.screenY += ship.shipSpeed;
      }

      ship.collidePlanet[area] = collidingShip;

      for (int i = 0; i < enemiesS.size(); i++) {
        if (pow (pow (screenX - enemiesS.get (i).screenX, 2) + pow (screenY - enemiesS.get (i).screenY, 2), 0.5) < pImage.width / 2 + ship.shipI.width / 2) {
          if (enemiesS.get (i).screenX < screenX) 
            enemiesS.get (i).screenX -= enemiesS.get (i).speed;
          else if (enemiesS.get (i).screenX > screenX)
            enemiesS.get (i).screenX += enemiesS.get (i).speed;
          if (enemiesS.get (i).screenY < screenY)
            enemiesS.get (i).screenY -= enemiesS.get (i).speed;
          else if (enemiesS.get (i).screenY > screenY)
            enemiesS.get (i).screenY += enemiesS.get (i).speed;
          if (enemiesS.get (i).move) {
            if (enemiesS.get (i).screenX < screenX && enemiesS.get (i).screenY < screenY)
              enemiesS.get (i).screenX -= enemiesS.get (i).speed * 2;
            if (enemiesS.get (i).screenX < screenX && enemiesS.get (i).screenY >= screenY)
              enemiesS.get (i).screenY += enemiesS.get (i).speed * 2;
            if (enemiesS.get (i).screenX >= screenX && enemiesS.get (i).screenY > screenY)
              enemiesS.get (i).screenX += enemiesS.get (i).speed * 2;
            if (enemiesS.get (i).screenX >= screenX && enemiesS.get (i).screenY <= screenY)
              enemiesS.get (i).screenY -= enemiesS.get (i).speed * 2;
          }
        }
      }

      for (int i = 0; i < asteroids.size(); i++) {
        if (pow (pow (asteroids.get (i).screenX - screenX, 2) + pow (asteroids.get (i).screenY - screenY, 2), 0.5) <= asteroidImg[asteroids.get (i).imgNum].width / 2 + pImage.width) {
          asteroids.remove(i);
          hp -= 100;
        }
      }
    }
    //println ("X: " + screenX + " Y: " + screenY);
  }

  int shipIn (int sX, int sY) { //ship world values
    int output = 0;
    if (sY < -358) {
      if (sX < -358)
        output = 0;
      else if (sX < 308)
        output = 1;
      else
        output = 2;
    } else if (sY < 308) {
      if (sX < -358)
        output = 3;
      else if (sX < 308)
        output = 4;
      else
        output = 5;
    } else {
      if (sX < -358)
        output = 6;
      else if (sX < 308)
        output = 7;
      else
        output = 8;
    }

    return output;
  }

  void deathCheck() {
    if (hp <= 0)
      dead = true;
  }
} 

class Asteroid {
  int imgNum;
  int screenX;
  int screenY;
  int dirX;
  int dirY;

  Asteroid (int x, int y) {
    screenX = x;
    screenY = y;

    dirX = (int) random (-7, 8);
    dirY = (int) random (-7, 8);

    imgNum = (int) random (20);
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY, ArrayList<Enemy> enemiesS) {
    screenX += dirX;
    screenY += dirY;
    screenX += smX;
    screenY += smY;

    if (screenX >= - (asteroidImg[imgNum].width / 2) && screenX <= width + asteroidImg[imgNum].width / 2 && screenY >= - (asteroidImg[imgNum].height / 2) && screenY <= height + asteroidImg[imgNum].width / 2) {
      image (asteroidImg[imgNum], screenX, screenY);

      for (int i = 0; i < enemiesS.size(); i++) {
        if (pow (pow (enemiesS.get (i).screenX - screenX, 2) + pow (enemiesS.get (i).screenY - screenY, 2), 0.5) <= enemiesS.get (i).enemyI.width / 2 + asteroidImg[imgNum].width / 2 && enemiesS.get (i).type != 5) {
          enemiesS.remove (i);
          dirX = (int) (dirX / 2.0);
          dirY = (int) (dirY / 2.0);
        }
      }

      for (int i = 0; i < shots.size(); i++) {
        if (pow (pow (shots.get (i).screenX - screenX, 2) + pow (shots.get (i).screenY - screenY, 2), 0.5) <= asteroidImg[imgNum].width / 2) {
          shots.get (i).destroy (shots);
        }
      }
    }
  }
}

class Star {
  int screenX;
  int screenY;

  Star (int x, int y) {
    screenX = x;
    screenY = y;
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY) {
    screenX += smX;
    screenY += smY;

    if (screenX >= - (star.width / 2) && screenX <= width + (star.width / 2) && screenY >= - (star.height / 2) && screenY <= height + (star.height / 2)) {
      image (star, screenX, screenY);

      if (pow (pow (screenX - ship.screenX, 2) + pow (screenY - ship.screenY, 2), 0.5) <= star.width / 10 + ship.shipI.width / 2)
        ship.hp -= 100;
    }
  }
}

class SpaceShip {
  int screenX;
  int screenY;
  int hp = 1;
  float angle = 0;

  SpaceShip (int x, int y) {
    screenX = x;
    screenY = y;

    angle = random (TWO_PI);
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY) {
    screenX += smX;
    screenY += smY;

    if (screenX >= - (spaceShip.width / 2) && screenX <= width + (spaceShip.width / 2) && screenY >= - (spaceShip.height / 2) && screenY <= height + (spaceShip.height / 2)) {
      pushMatrix();
      translate (screenX, screenY);
      rotate (angle);
      image (spaceShip, 0, 0);
      popMatrix();
    }
  }
}