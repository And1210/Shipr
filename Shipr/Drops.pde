class Hp {
  int screenX;
  int screenY;
  boolean active = false;
  PImage hp;

  Hp() {
    hp = loadImage ("/res/Hp.png");
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (Ship ship) {
    if (active) {
      image (hp, screenX, screenY);
      if (ship.hitBox.contains (screenX - 13, screenY - 13) || ship.hitBox.contains (screenX + 13, screenY - 13) || ship.hitBox.contains (screenX - 13, screenY + 13) || ship.hitBox.contains (screenX + 13, screenY + 13)) {
        ship.hp += (int) random (50, 100);
        if (ship.hp > 100)
          ship.hp = 100;
        active = false;
      }
    }
  }

  void setCoords (int x, int y) {
    screenX = x;
    screenY = y;
  }
}