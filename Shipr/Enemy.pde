class Enemy {
  PImage enemyI;
  float targetX;
  float targetY;
  int screenX;
  int screenY;
  int screenMoveX;
  int screenMoveY;
  int speed = 3;
  int type; // 1 = basic, 2 = quick, 3 = tank, 4 = assassin, 5 = boss

  int halfHigh;
  int halfWide;
  int damage;
  int hp = (int) (30 * (1 + (eComSolo.wave / 5.0)));
  int[] checkMoved = new int[3];
  boolean move = false;
  boolean dead = false;

  Enemy (int s) {
    speed = s;

    enemyI = loadImage ("/res/Enemy.png");

    screenX = (int) random ((int)enemyI.width / 2, width - (int)(enemyI.width / 2) + 1);
    screenY = (int) random (enemyI.height, height + enemyI.height + 1) * -1;

    halfHigh = (int) (enemyI.height / 2.0);
    halfWide = (int) (enemyI.width / 2.0);
  }

  Enemy (int sX, int sY, int t, int s) {
    screenX = sX;
    screenY = sY;
    type = t;
    speed = s;

    if (type == 1) 
      enemyI = loadImage ("/res/Enemy1.png");
    else if (type == 2) {
      enemyI = loadImage ("/res/Enemy2.png");
      speed = (int) (2 * speed);
    } else if (type == 3) {
      enemyI = loadImage ("/res/Enemy3.png");
      speed = (int) ((0.67) * speed);
      hp = (int) (50 * (1 + (eComSolo.wave / 5.0)));
    } else if (type == 4) {
      enemyI = loadImage ("/res/Enemy4.png");
    } else if (type == 5) {
      enemyI = loadImage ("/res/Enemy5.png");
      speed = (int) ((0.5) * speed);
      hp = (int) (100 * (1 + (eComSolo.wave / 5.0)));
    }
    if (speed < 1)
      speed = 1;

    halfHigh = enemyI.height / 2;
    halfHigh = enemyI.width / 2;
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update(Ship p1) {
    draw1();
    move1 ();

    if (damage > 0) {
      p1.hp -= damage;
      damage = 0;
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update(Ship p1, Ship p2) {
    draw1();
    move1 ();

    if (damage > 0) {
      p1.hp -= damage;
      p2.hp -= damage;
      damage = 0;
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int playerX, int playerY, int smX, int smY) { // smX = screen move X, smY = screen move Y
    targetX = playerX;
    targetY = playerY;
    screenMoveX = smX;
    screenMoveY = smY;
    if (screenX >= - (enemyI.width / 2) && screenX <= width + (enemyI.width / 2) && screenY >= - (enemyI.height / 2) && screenY <= height + (enemyI.height / 2)) {
      draw3();
    }
    move3();

    if (millis() - checkMoved[0] > 1000) {
      if (moveCheck()) {
        move = true;
      }
    }
  }

  void draw1() {
    image (enemyI, screenX, screenY);
  }

  void draw3() {
    float a = pow (pow (targetX - screenX, 2) + pow (targetY - screenY, 2), 0.5); //getting the distances of the triangle formed by the mouse, the ship and the x-axis
    float b = pow (pow (targetX - screenX, 2), 0.5);
    float c = pow (pow (targetY - screenY, 2), 0.5);

    //print ("A: " + a + " B: " + b + " C: " + c + " ");
    float angle = 0;
    if (b != 0)
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (-2 * a * b)); //finding the angle from the x-axis
    else if (targetY < screenY)
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (-2 * a));
    else if (targetY > screenY)
      angle = acos ((pow (c, 2) - pow (b, 2) - pow (a, 2)) / (-2 * -a));
    angle = HALF_PI - angle; //modifying the angle so the ship rotates correctly

    if (targetX > screenX && targetY <= screenY) { //Q1 //changing the angle to fit each quadrant so rotation works
    } else if (targetX <= screenX && targetY < screenY) { //Q2
      angle = TWO_PI - angle;
    } else if (targetX < screenX && targetY >= screenY) { //Q3
      angle = PI + angle;
    } else if (targetX >= screenX && targetY > screenY) { //Q4
      angle = PI - angle;
    }

    pushMatrix();
    translate (screenX, screenY);
    rotate (angle);
    image (enemyI, 0, 0);
    popMatrix();
  }

  void move1 () {
    screenY += speed;
    if (screenY > height + halfHigh) {
      dead = true;
      damage = (int) random (3, 11);
    }
  }

  void move3() {
    float xChange;
    float yChange;
    xChange = targetX - screenX;
    yChange = targetY - screenY;
    if (abs (xChange) > abs (yChange)) { //making the enemies the same speed no matter what the direction is
      yChange /= abs (xChange);
      xChange /= abs (xChange);
    } else {
      xChange /= abs (yChange);
      yChange /= abs (yChange);
    }
    screenX += xChange * speed;
    screenY += yChange * speed;
    screenX += screenMoveX;
    screenY += screenMoveY;
  }

  void deathCheck() {
    if (hp <= 0)
      dead = true;
  }

  boolean moveCheck() {
    boolean x = false;
    boolean y = false;

    checkMoved[0] = millis();
    if (screenX <= checkMoved[1] + speed && screenX >= checkMoved[1] - speed)
      x = true;
    if (screenY <= checkMoved[2] + speed && screenY >= checkMoved[2] - speed)
      y = true;

    checkMoved[1] = screenX;
    checkMoved[2] = screenY;

    if (x && y)
      return true;
    else
      return false;
  }
}