class Eraser {
  int drawLine, ellipseSize;
  float x, y, eY, startY, goalY, firstX, lastX, lineHeight, sLineHeight, splitPos;
  PVector location; //消しゴムの中心位置を格納する変数
  PVector velocity; //消しゴムの速度を格納する変数
  PGraphics pg;

  Eraser() {
    pg = createGraphics(width, height);
    lineHeight = grp[0].getHeight(); //文字の高さを取得
    sLineHeight = lineHeight*0.8; //高さを少し小さくする
    ellipseSize = 28; //消しゴムの大きさ
  }

  void set(int _drawLine) {
    drawLine = _drawLine;
    setFirstX();
    splitPos = texts.get(texts.size()-1).splitPos;
    
    x = 0;
    y = 0;

    location = new PVector(firstX, textY-sLineHeight);
    velocity = new PVector(-2, 8); //２番目の数値を大きくすると消すスピードが早くなる

    pg.beginDraw();
    pg.clear();
    pg.endDraw();
  }

  void setFirstX() {
    firstX = textX+texts.get(texts.size()-1).currentX;
    if (firstX+ellipseSize/2 > rrX+rrWidth) { //消しゴムの最初の位置がウィンドウよりはみ出るとき
      firstX = rrX+rrWidth-ellipseSize/2-1; //はみ出ない位置に設定する
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    location.add(velocity);
    pushMatrix();
    translate(textX, textY);
    if (bGuide) {
      fill(231, 35, 133); //文字の色をピンクにする
    } else {
      fill(#040304);
    }
    RShape[] splitShapes = grp[drawLine].split(splitPos);
    RG.shape(splitShapes[0]);
    popMatrix();
    pg.beginDraw();
    if (bGuide) {
      pg.fill(248, 171, 30); //消しゴムの色をオレンジにする
    } else {
      pg.fill(255, 255, 255);
    }
    pg.noStroke();
    pg.ellipse(location.x, location.y, ellipseSize, ellipseSize);
    pg.endDraw();
    image(pg, 0, 0);
    popMatrix();
    if (location.y < textY-sLineHeight || location.y > textY) { //上・下にあたったら逆方向に動く
      velocity.y = velocity.y * -1;
    }
    if (location.y < textY-sLineHeight) { //上にあたったとき
      velocity.x = -velocity.x * 2.5;
    }
    if (location.y > textY) { //下にあたったとき
      velocity.x = 2;
    }
    if (location.x < textX) {
      velocity.x = 0;
      velocity.y = 0;
    }
  }

  void setVelocity(float vx, float vy) {
    velocity.x = vx;
    velocity.y = vy;
  }

  //マイナス改行-----------------------------------
  void setEasing(float _startY, float _goalY) {
    eY = 0;
    startY = _startY;
    goalY = _goalY;
  }

  void move(float speed) { 
    y = map(easeInOutBack(eY), 0, 1, startY, goalY);
    eY += 1 / speed; //イージングのスピード（数値が小さいほど早い）
    if (eY > 1) {
      eY = 1;
    }
  }
}
