class TextWindow {
  PVector pos;
  float rX, rY, rW, rH, sideMargin, margin; 
  float rX2, rY2, rW2, rH2;
  float rX3, rY3, rW3, rH3;
  float xSize, xSpace, textPosY;
  PVector xLeftTop, xRightBottom, xLeftBottom, xRightTop;
  float gravity = .6;
  float ground, jumpSpeed, up, velocity;
  int tTime;

  TextWindow(float _x, float _y) {
    pos = new PVector(_x, _y);
    velocity = 0;
    ground = _y;
    tTime = 0;
    
    rX = 0;
    rY = 0;
    rW = 250; //ウィンドウの幅
    rH = 80; //ウィンドウの高さ
    sideMargin = 8; //横の空白
    margin = 8; //縦方向のコンテンツとコンテンツ間の空白

    rX2 = rX+sideMargin;
    rY2 = rY+margin;
    rW2 = rW-sideMargin*2;
    rH2 = rH/3;

    //×マーク
    xSize = rH2-13; //xマークの大きさ
    xSpace = (rH2-xSize)/2;
    xLeftTop = new PVector(rX2+rW2-sideMargin-xSize, rY2+xSpace);
    xRightBottom = new PVector(xLeftTop.x+xSize, rY2+rH2-xSpace);
    xLeftBottom = new PVector(xLeftTop.x, xRightBottom.y);
    xRightTop = new PVector(xRightBottom.x, xLeftTop.y);

    //ウィンドウ内の白い部分
    rX3 = rX2;
    rY3 = rY2 + rH2 + margin;
    rW3 = rW2;
    rH3 = rH-rH2-margin*3;

    //文字のy位置
    textPosY = rY2+rH2+(rH-8-rH2-textHeight)/2;

    //ジャンプ
    jumpSpeed = 6;
  }

  void display() {
    if (tTime%100 < 45) {
      up = -1;
    } else {
      up = 0;
    }

    if (pos.y < ground) {
      velocity += gravity;
    } else {
      velocity = 0;
    }

    if (pos.y >= ground && up != 0) {
      velocity = -jumpSpeed;
    }

    float nextPosition = pos.y;
    nextPosition+=velocity;

    float offset = 0;
    if (nextPosition > offset && nextPosition < (height - offset)) {
      pos.y = nextPosition;
    }

    pushMatrix();
    translate(pos.x, pos.y);
    drawWindow();
    popMatrix();
    
    tTime++;
  }

  void drawWindow() {
    fill(255);
    rect(0, 0, rW, rH, 10);
    //ウィンドウ内のピンクの部分
    fill(#f1aab9);
    rect(rX2, rY2, rW2, rH2, 10);
    //罰マーク
    stroke(#c61808);
    strokeWeight(5);
    line(xLeftTop.x, xLeftTop.y, xRightBottom.x, xRightBottom.y);
    line(xLeftBottom.x, xLeftBottom.y, xRightTop.x, xRightTop.y);
    //文字
    fill(0, 150);
    text("▼Click", rX+rW/2, textPosY);
  }

  void resetTime() {
    tTime = 0;
  }
  
}
