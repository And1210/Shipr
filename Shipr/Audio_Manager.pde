class Audio {
  Minim minim;
  AudioPlayer shipShot;
  AudioPlayer[] bgMusic = new AudioPlayer[8];
  AudioMetaData[] bgMetaData = new AudioMetaData[8];

  final int tracks = 8;
  int track = (int) random (tracks);
  boolean play = true;

  Audio (Minim m) {
    minim = m;
    shipShot = minim.loadFile ("/res/shot.wav");

    for (int i = 0; i < tracks; i++) {
     bgMusic[i] = minim.loadFile ("/res/bg_music/bg_" + (i + 1) + ".mp3");
     bgMetaData[i] = bgMusic[i].getMetaData();
    }
  }

  /*****************************************************
   * Name: update                                       *
   * Purpose: To update the class                       *
   *****************************************************/
  void bgUpdate() {
   if (play) {
     if (!bgMusic[track].isPlaying()) {
       bgMusic[track].play();
     }
   } else {
     bgMusic[track].pause();
   }
   if (bgMusic[track].position() >= bgMusic[track].length() - 1000)
     changeTrack (true);
  }

  void shoot() {
    shipShot.rewind();
    shipShot.play();
  }

  void pausePlay() {
    play = !play;
  }

  void changeTrack (boolean forward) {
    bgMusic[track].pause();
    bgMusic[track].rewind();

    if (forward)
      track++;
    else
      track--;
    if (track > tracks - 1)
      track = 0;
    if (track < 0)
      track = tracks - 1;
    play = true;
  }
}