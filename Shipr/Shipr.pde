import ddf.minim.*;
import java.awt.*;

PFont menu;
BufferedReader highscoreRead;
BufferedReader highscoreSoloRead;
PrintWriter highscoreOut;
PrintWriter highscoreSoloOut;

ArrayList<Animation> explosions;
Ship ship, player1, player2, p1, p2;
ArrayList<Enemy> enemies;
ArrayList<Enemy> soloEnemies;
ESpawn[] eSpawn = new ESpawn[8];
Gamespace map;
ArrayList<Star> stars;
ArrayList<Planet> planets;
ArrayList<Asteroid> asteroids;
ArrayList<Shot> shots;
ArrayList<Powerup> powerups;
ArrayList<SpaceShip> spaceShips;
HUD hud;
MainMenu menus;
EnemyCom eCom;
EComSolo eComSolo;
Audio audio;
Minim minim;
CircleExplode circEx;

PImage[] asteroidImg;
PImage[] powerupImg;
PImage star;
PImage spaceShip;
PImage laserImg;
PImage rocketImg;
PImage mGunImg;
float soloLoad;
boolean loading = false;
final int planetMax = 81; //must be perfect square
int winnerId;
int gameMode = 0;
int clickTime = 0;
boolean twoPlayer = false;
boolean paused = false;
boolean[] quadrant;

String[] prev = new String[5];
String[] prevS = new String[2];
char p1Shoot = ' ';
char p2Shoot = ENTER;

int loadNum = 0;

void setup() {
  size (950, 950);
  imageMode (CENTER);
  noStroke();
  textAlign (CENTER);

  highscoreRead = createReader ("/res/Highscore.txt");
  highscoreSoloRead = createReader ("/res/HighscoreSolo.txt");
  menu = createFont ("/res/SF Atarian System.ttf", 100);
  explosions = new ArrayList<Animation>();
  ship = new Ship (width / 2, height / 2, 0);
  player1 = new Ship (width / 2, height - 50, 1);
  player2 = new Ship (width / 2, 50, 2);
  p1 = new Ship (width / 2, height - 100, 3, 0);
  p2 = new Ship (width / 2, height - 300, 0, 3);
  enemies = new ArrayList<Enemy>();
  soloEnemies = new ArrayList<Enemy>();
  eSpawn[0] = new ESpawn (-925, -925);
  eSpawn[1] = new ESpawn (-925, 475);
  eSpawn[2] = new ESpawn (-925, 1825);
  eSpawn[3] = new ESpawn (1825, -925);
  eSpawn[4] = new ESpawn (1825, 475);
  eSpawn[5] = new ESpawn (1825, 1825);
  eSpawn[6] = new ESpawn (475, -925);
  eSpawn[7] = new ESpawn (475, 1825);
  powerupImg = new PImage[5];
  powerupImg[0] = loadImage ("/res/Instakill.png");
  powerupImg[1] = loadImage ("/res/Bombr.png");
  powerupImg[2] = loadImage ("/res/SpeedUp.png");
  powerupImg[3] = loadImage ("/res/LevelUp.png");
  powerupImg[4] = loadImage ("/res/Hp.png");
  laserImg = loadImage ("/res/Weapon1.png");
  rocketImg = loadImage ("/res/Weapon2.png");
  mGunImg = loadImage ("/res/Weapon3.png");
  map = new Gamespace();
  quadrant = new boolean[planetMax];
  planets = new ArrayList<Planet>();
  asteroids = new ArrayList<Asteroid>();
  stars = new ArrayList<Star>();
  powerups = new ArrayList<Powerup>();
  spaceShips = new ArrayList<SpaceShip>();
  spaceShip = loadImage ("/res/Ship1.png");
  asteroidImg = new PImage[20];
  shots = new ArrayList<Shot>();
  hud = new HUD (menu, player1.shipI, player2.shipI);
  menus = new MainMenu (menu);
  eCom = new EnemyCom (enemies);
  eComSolo = new EComSolo (soloEnemies, eSpawn);
  soloLoad = 0;
  circEx = new CircleExplode();
  if (minim == null) {
    minim = new Minim (this);
    audio = new Audio (minim);
  }
}

void draw() {
  audio.bgUpdate();
  paused = hud.pauseSet();

  if (!paused) {

    if (loading) {
      if (loadNum < planetMax) {
        planets.add (new Planet ((int) random (6) + 1, map, loadNum));
        if (loadNum < 20) {
          asteroidImg[loadNum] = loadImage ("/res/Asteroid" + loadNum + ".png");
        }
        if (loadNum < 1) {
          for (int i = 0; i < planetMax; i++) {
            int xT = 0;
            int yT = 0;
            xT = (int) random (-1025 * ship.shipSpeed, 975 * ship.shipSpeed);
            yT = (int) random (-1025 * ship.shipSpeed, 975 * ship.shipSpeed);
            spaceShips.add (new SpaceShip (xT, yT));
          }
          star = loadImage ("/res/Star.png");
          stars.add (new Star ((int) random (-1025, 975), (int) random (-1025, 975)));
        } else if (loadNum < 5)
          stars.add (new Star ((int) random (-1025 * ship.shipSpeed, 975 * (ship.shipSpeed - 1)), (int) random (-1025 * (ship.shipSpeed - 1), 975 * ship.shipSpeed)));
        loadNum++;
      } else {
        loading = false;
        loadNum = 0;
      }
      hud.loadSolo();
    } else {
      shipShootKey();

      if (gameMode == 0) { //Main Menu
        map.update (gameMode);
        menus.update (audio);
        twoPlayer = menus.playerNumSet();
        gameMode = menus.gameModeSet();
        menus.changeKey (menus.checking);
      } else if (gameMode == 1) { //Defense Survival
        if (millis() - clickTime <= 500)
          eCom.waveStart = clickTime;
        map.update (gameMode);
        for (int i = 0; i < shots.size(); i++)
          shots.get(i).update (shots, enemies, eCom, p1);
        if (twoPlayer) {
          p1.update (map, gameMode, shots, audio, enemies);
          p2.update (map, gameMode, shots, audio, enemies);
          hud.update (eCom, p1, p2);
          eCom.update (enemies, p1, p2);
        } else {
          p1.update (map, gameMode, shots, audio, enemies);
          hud.update (eCom, p1);
          eCom.update (enemies, p1);
        }

        if (p1.dead || p2.dead) {
          String[] highscores = new String[5]; 
          for (int i = 0; i < 5; i++) {
            try {
              prev[i] = highscoreRead.readLine();
            } 
            catch (IOException e) {
              e.printStackTrace();
            }
          }
          highscores[2] = "";
          if (!twoPlayer) {
            if (p1.score > Integer.parseInt (prev[0]))
              highscores[0] = "" + p1.score;
            else
              highscores[0] = prev[0];
            if (eCom.wave > Integer.parseInt (prev[1]))
              highscores[1] = "" + eCom.wave;
            else
              highscores[1] = prev[1];
            highscores[3] = prev[3];
            highscores[4] = prev[4];
          } else {
            highscores[0] = prev[0];
            highscores[1] = prev[1];
            if (p1.score > Integer.parseInt (prev[3]))
              highscores[3] = "" + p1.score;
            else
              highscores[3] = prev[3];
            if (eCom.wave > Integer.parseInt (prev[4]))
              highscores[4] = "" + eCom.wave;
            else
              highscores[4] = prev[4];
          }
          saveStrings ("/res/Highscore.txt", highscores);

          gameMode = 6;
        }

        hud.update();
      } else if (gameMode == 2) { //Duel
        map.update (gameMode);
        for (int i = 0; i < shots.size(); i++)
          shots.get(i).update (shots);
        player1.update (map, gameMode, shots, audio);
        player2.update (map, gameMode, shots, audio);

        if (player1.dead) {
          gameMode = 5;
          winnerId = 2;
        }
        if (player2.dead) {
          gameMode = 5;
          winnerId = 1;
        }

        hud.update (gameMode, player1.hp, player2.hp, player1.ammo, player2.ammo);
        hud.update();
      } else if (gameMode == 3) { //Solo
        map.update(gameMode);
        for (int i = 0; i < 8; i++) {
          eSpawn[i].update (ship.mapMoveX, ship.mapMoveY);
        }

        for (int i = 0; i < spaceShips.size(); i++) 
          spaceShips.get (i).update (ship.screenMoveX, ship.screenMoveY);

        for (int i = 0; i < planets.size(); i++) {
          planets.get (i).update (ship, soloEnemies);
          if (planets.get (i).dead) {
            ship.collidePlanet[i] = false;
            soloEnemies.add (new Enemy (planets.get (i).screenX, planets.get (i).screenY, 5, 1 + (int) (eComSolo.wave / 4.0)));
            eComSolo.rEnemies++;
            eComSolo.update (soloEnemies, eSpawn, ship);
            for (int n = 0; n < (int) (planets.get (i).initHp / 100.0); n++)
              asteroids.add (new Asteroid (planets.get (i).screenX, planets.get (i).screenY));
            planets.remove (i);
            for (int n = 0; n < planets.size(); n++) {
              planets.get (n).update (ship, soloEnemies);
            }
            break;
          }
        }

        for (int i = 0; i < stars.size(); i++)
          stars.get (i).update (ship.screenMoveX, ship.screenMoveY);

        for (int i = 0; i < shots.size(); i++)
          shots.get(i).update (shots, soloEnemies, ship);
        ship.update (map, gameMode, shots, audio);

        for (int i = 0; i < asteroids.size(); i++) {
          asteroids.get (i).update (ship.screenMoveX, ship.screenMoveY, soloEnemies);
          if (!(asteroids.get (i).screenX >= -20000 && asteroids.get (i).screenX <= 20000 && asteroids.get (i).screenY >= -20000 && asteroids.get (i).screenY <= 20000) || (asteroids.get (i).dirX == 0 && asteroids.get (i).dirY == 0))
            asteroids.remove(i);
        }

        eComSolo.update (soloEnemies, eSpawn, ship);

        for (int i = 0; i < powerups.size(); i++) //not working
          powerups.get (i).update (ship.screenMoveX, ship.screenMoveY);

        circEx.update (ship.screenMoveX, ship.screenMoveY);

        if (ship.dead) {
          String[] hS = new String[2];
          for (int i = 0; i < 2; i++) {
            try {
              prevS[i] = highscoreSoloRead.readLine();
            } 
            catch (IOException e) {
              e.printStackTrace();
            }
          }
          if (ship.score > Integer.parseInt (prevS[0]))
            hS[0] = "" + ship.score;
          else
            hS[0] = prevS[0];
          if (eComSolo.wave > Integer.parseInt (prevS[1]))
            hS[1] = "" + eComSolo.wave;
          else
            hS[1] = prevS[1];
          saveStrings ("/res/HighscoreSolo.txt", hS);

          gameMode = 7;
        }

        hud.update (eComSolo, ship, map);
        hud.update();
      } else if (gameMode == 5) { //Gameover Duel screen
        hud.update (gameMode, winnerId);
        if (hud.gameModeSet() != -1) {
          gameMode = hud.gameModeSet();
          reset();
        }
      } else if (gameMode == 6) {
        if (!twoPlayer)
          hud.update (p1.score, eCom.wave, Integer.parseInt (prev[0]), Integer.parseInt (prev[1]));
        else
          hud.update (p1.score, eCom.wave, Integer.parseInt (prev[3]), Integer.parseInt (prev[4]));
        if (hud.gameModeSet() != -1) {
          gameMode = hud.gameModeSet();
          reset();
        }
      } else if (gameMode == 7) {
        hud.update (ship.score, eComSolo.wave, Integer.parseInt (prevS[0]), Integer.parseInt (prevS[1]));
        if (hud.gameModeSet() != -1) {
          gameMode = hud.gameModeSet();
          reset();
        }
      }
    }
  } else {
    hud.pauseMenu (audio);
    hud.update();
  }
  //println (frameRate);
}

/*****************************************************
 * Name: reset                                        *
 * Purpose: To reset the gamemodes                    *
 *****************************************************/
void reset() {
  setup();
  gameMode = 0;
}

/*****************************************************
 * Name: shipShootKey                                 *
 * Purpose: To update the shoot keys for ships        *
 *****************************************************/
void shipShootKey() {
  ship.shootKey = p1Shoot;
  p1.shootKey = p1Shoot;
  player1.shootKey = p1Shoot;
  p2.shootKey = p2Shoot;
  player2.shootKey = p2Shoot;
}

/*****************************************************
 * Name: Animation                                    *
 * Purpose: To do explosion animation                 *
 *****************************************************/
class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  boolean display = true;
  int lastFrame = 0;

  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      String filename = imagePrefix + nf (i, 4) + ".png";
      images[i] = loadImage(filename);
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (float xpos, float ypos) {
    if (display) {
      if (millis () - lastFrame >= 25) {
        frame = (frame+1) % imageCount;
        lastFrame = millis();
      }
      image(images[frame], xpos, ypos);
    }

    if (frame == 0)
      display = false;
  }

  /*****************************************************
   * Name: getWidth                                     *
   * Purpose: To return the width of an image           *
   *****************************************************/
  int getWidth() {
    return images[0].width;
  }
}

class CircleExplode {
  boolean display = false;
  int screenX;
  int screenY;
  int r = 1;
  boolean damageShip = false;

  CircleExplode() {
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void update (int smX, int smY) {
    screenX += smX;
    screenY += smY;

    if (display) {
      r += (int) (width / 20.0);
      noFill();
      stroke (255);
      ellipse (screenX, screenY, r, r);
      noStroke();
      fill (100);

      if (r > (int) ((width * 3) / 2.0)) {
        display = false;
        r = 1;
      }
    }

    for (int i = 0; i < soloEnemies.size(); i++) {
      if ((int) pow (pow (screenX - soloEnemies.get (i).screenX, 2) + pow (screenY - soloEnemies.get (i).screenY, 2), 0.5) <= (int) (r / 2) && soloEnemies.get (i).type != 5) {
        soloEnemies.get (i).dead = true;
      }
    }
    println();

    if (!damageShip) {
      if ((int) pow (pow (screenX - ship.screenX, 2) + pow (screenY - ship.screenY, 2), 0.5) <= r) {
        ship.hp -= 50;
        damageShip = true;
      }
    }
  }
}