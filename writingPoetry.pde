import geomerative.*;
import java.util.Calendar;

boolean bGuide = false; //ガイドの表示

RShape[] grp;
RShape[] emo;
int textWidth = 60; //一文字の大きさ
int currentLine = 0;
int time = 0; //文字に使う値
int aniTime = 0; //ナツキのアニメーション用タイム
int interval = 470; //１文書く間隔（数値が大きいほど遅くなる）
int textSpace = 65; //行間
int bodyFrame = 0; //現在のナツキのフレーム
int eyeFrame = 0; //現在の目のフレーム
int currentFrame = 0;
int wink, newLineNum, currentNewLine, prevCurrentNewLine;
int mode = 0; //0:テキストを書く 1:改行 2:にらむ 3:ペンと消しゴムを入れ替える 4:文字を消す 5:消しゴムとペンを入れ替える 6:改行（マイナス）
int prevMode; //１フレーム前のmodeの値
int eraserCount; //消しゴムかけてる時間
int[] intervals;
float[] lineWidths;
float div, textX, textY, imageX, imageY, rrX, rrY, rrWidth, rrHeight, textHeight;
String[] lines;
String[] emojis;
String imageName = "images[0]";
PFont windowMessage;
PImage[] images = new PImage[16];
PImage[] eyes = new PImage[10];
PImage mouseCursor, handCursor;
boolean bEye = false;
boolean prevbEye; //１フレーム前のbEyeの値
boolean bEraser = false; //消しゴムモードを起動させるまではEraserの表示をしない
ArrayList<Text> texts = new ArrayList<Text>();
ArrayList<RoundRect> rrect = new ArrayList<RoundRect>();
FloatList textCurrentY = new FloatList();
TextWindow tw;
Eraser eraser;

//背景のドット
PGraphics dotPattern;

void setup() {
  size(1080, 608);
  frameRate(60);
  smooth();
  
  //文章をロード
  RG.init(this);
  lines = loadStrings("text-0.txt");
  grp = new RShape[lines.length];
  
  for (int i = 0; i < lines.length; i++) {
    grp[i] = RG.getText(lines[i], "KTEGAKI.ttf", textWidth, LEFT);
  }

  //ウィンドウメッセージ
  windowMessage = createFont("Kodchasan-Medium.ttf", 28);
  textFont(windowMessage);
  textAlign(CENTER, TOP);
  float ascent = textAscent();
  float descent = textDescent();
  textHeight = ascent + descent;
  tw = new TextWindow(width-280, 50);

  //１文書く間隔（どの文の長さでも描画スピードを一定にする）
  intervals = new int[lines.length];
  lineWidths = new float[lines.length]; //各文の幅を格納
  for (int i = 0; i < intervals.length; i++) {
    //文の幅を取得
    float lineWidth = grp[i].getBottomRight().x - grp[i].getBottomLeft().x;
    lineWidths[i] = lineWidth;
    if (i == 0) {
      div = interval/lineWidth;
      intervals[i] = interval;
    } else {
      intervals[i] = int(div*lineWidth);
    }
  }
  
  //画像をロード
  //ナツキ
  for (int i = 0; i < images.length; i++) {
    String imageName = "ani-" + nf(i, 1) + ".png";
    images[i] = loadImage(imageName);
  }
  //目
  for (int i = 0; i < eyes.length; i++) {
    String imageName = "eye-" + nf(i, 1) + ".png";
    eyes[i] = loadImage(imageName);
  }

  //画像の位置
  imageX = width-images[0].width-20;
  imageY = height-images[0].height-10;
  //テキストのy位置
  textX = 80;
  textY = height-90;
  //最初のテキストを追加
  texts.add(new Text(0));
  
  //四角形を追加
  float padding = 50;
  rrX = textX-padding;
  rrY = textY-textSpace-padding;
  rrWidth = 718;
  rrHeight = textSpace*(lines.length)+padding*2;
  rrect.add(new RoundRect(rrX, rrY, rrWidth, rrHeight));
  
  //背景のドット
  boolean offset = false;
  dotPattern = createGraphics(width, height);
  int dotSize = 30;
  int dotAlpha = 150;
  dotPattern.beginDraw();
  dotPattern.background(#e5e5e5);
  dotPattern.noStroke();
  for (int y=20; y<=height; y+=40) {
    for (int x=0; x<=width; x+=80) {
      dotPattern.fill(255, dotAlpha);
      if (offset) {
        dotPattern.ellipse(x, y, dotSize, dotSize);
      } else {
        dotPattern.ellipse(40+x, y, dotSize, dotSize);
      }
    }
    offset = !offset;
    dotAlpha -= 10;
  }
  dotPattern.endDraw();

  //消しゴム
  eraser = new Eraser();
}

void draw() {
  //背景------------------------------------------------------------
  //image(dotPattern, 0, 0); //ドット背景
  background(#f7c7d7); //ピンク背景

  //ナツキ----------------------------------------------------------
  image(images[bodyFrame], imageX, imageY);
  if (prevMode != mode) aniTime = 0;

  //画像が切り替わるスピードを調整
  int frame;
  if (mode != 4) { //消しゴム以外
    frame = aniTime % 8;
  } else { //消しゴムのとき（早くする）
    frame = aniTime % 6;
  }

  if (mode == 0) { //テキストの描画をしてるときだけ動く
    if (frame == 1) {
      bodyFrame = int(random(3));
    }
  } else if (mode == 3) { //ペンから消しゴムに持ち替え
    if (bodyFrame < 13 && frame == 1) {
      bodyFrame+=1;
    }
    if (bodyFrame == 13) {
      mode = 4; //ペンから消しゴムに持ち替える動作が終わったらモード変更
      bodyFrame = 14; //ナツキの画像を変更
      eyeFrame = 4; //目の画像を変更
    }
  } else if (mode == 4) { //消しゴム
    if (frame == 1) {
      bodyFrame = int(random(13, 16));
    }

    if (eraserCount > 4*60) { //少しの間消しゴムをかける(60はframeRate)
      changeMode5();
    }
  } else if (mode == 5) { //消しゴムとペンを入れ替える
    if (bodyFrame > 3 && frame == 1) {
      bodyFrame-=1;
    }
    if (bodyFrame == 3) {
      mode = 0; //最初に戻る
      bodyFrame = 2;
      eyeFrame = 0;
    }
  }

  //目--------------------------------------------------------------
  image(eyes[eyeFrame], imageX, imageY);
  if (mode == 0 || mode == 1) { //テキストを書く、改行
    wink(0, 2); //0~2番目の目の画像を使用してウィンク
    
  } else if (mode == 2) { //にらむ
    eyeFrame = 3; //3番目の目の画像を使用
    
    if (frameCount > currentFrame+1.5*60) { //少しの間にらむ(60はframeRate)
      mode=3; //モード変更
      eyeFrame = 7; //目の画像を変更
      bodyFrame = 3; //ナツキの画像を変更
    }
    
  } else if (mode == 3) { //ペンから消しゴムに持ち替え
    wink(7, 9); //7~9番目の目の画像を使用してウィンク
    
  } else if (mode == 4) { //消しゴム
    wink(4, 6); //4~6番目の目の画像を使用してウィンク
    
  } else if (mode == 5) { //消しゴムからペンに持ち替え
    wink(7, 9);
  }

  //四角形の描画----------------------------------------------------
  for (int i = 0; i < rrect.size(); i++) {
    rrect.get(i).display();
  }

  //テキスト-------------------------------------------------------
  if (mode == 0) {
    if (grp[currentLine].countChildren() == 0) mode = 1; //文字が空白のときは改行
  } else if (mode == 4) {
    if (grp[currentLine].countChildren() == 0) mode = 6; //（消しゴム時）文字が空白のときは-改行
  }

  if (mode==0 && prevMode==5) {
    //消しゴムかけた後のテキスト
    //float currentX = eraser.getLocationX()-textX-textWidth*1.3;
    float currentX = eraser.location.x-textX-textWidth*1.3;
    if (currentX < 0) currentX = 0;
    float spPos = currentX / lineWidths[currentLine];
    time = int(map(spPos, 0, 1, 0, intervals[currentLine]-1));
  }

  //消しゴム-------------------------------------------------------
  if (mode==4 && prevMode==3) {
    bEraser=true; //消しゴム用のbool
    eraserCount = 0;
    eraser.set(currentLine);
  } else if (mode==4) {
    float eraserX = eraser.location.x;
    if (currentLine==0 && eraserX<textX) { //消しゴムが最初の行の頭まで来たら
      changeMode5();
    } else if (currentLine!=0 && eraserX<textX) {
      mode = 6;
    }
  }

  if (mode==1) {
    bEraser = false;
  }

  //消しゴムとテキストの表示-----------------------------------------

  if (mode!=4 && mode!=5 && mode!=6) { //通常時、[消しゴム　テキスト]の順
    if (bEraser) eraser.display();
  }

  //テキスト
  pushMatrix();
  translate(textX, textY);
  for (int i = 0; i < texts.size(); i++) {
    texts.get(i).display(); //テキスト表示
  }
  popMatrix();

  if (mode==4 || mode==5 || mode==6) { //消しゴム時、[テキスト　消しゴム]の順
    if (bEraser) eraser.display();
  }

  //ウィンドウメッセージ------------------------------------------
  if (mode == 0) {
    if (imageX < mouseX && mouseX < (imageX+images[0].width) &&
      imageY < mouseY && mouseY < (imageY+images[0].height)) {
      tw.display();
      cursor(HAND);
    } else {
      tw.resetTime();
      cursor(ARROW);
    }
  } else {
    cursor(ARROW);
  }

  //time---------------------------------------------------------
  if (mode == 0) { //文章を書いてるとき
    time++;
  } else if (mode == 4) { //消しゴム
    eraserCount++;
  }

  if (mode==0 && time%intervals[currentLine]==0) { //１文書き終わったとき
    mode = 1;
    time = 0;
  }

  if (mode==1) {
    addLine(); //改行
  }

  if (mode==6) {
    minusLine(); //改行（マイナス）
  }

  prevMode = mode;
  prevbEye = bEye;
  aniTime++;

  //ガイド----------------------------------------------------------

  if (bGuide) {
    fill(0);
    text("mode:"+mode, width-300, 300); //現在のモード番号を画面に表示

    text("currentLine:"+currentLine, 100, 30);
  }
}

//目のまばたき-------------------------------------------------------
void wink(int first, int end) { 
  int space = int(random(93, 150)); //まばたきするタイミング（ランダム）
  int frame2 = frameCount % space;
  if (frame2 == space-1) {
    bEye = true; //まばたきを有効にする
  }
  if (bEye) {
    if (bEye != prevbEye) {
      wink = 0; //まばたきに使う数値
    }
    //まばたきのスピード
    if (wink%4 == 3) {
      eyeFrame += 1;
    }
  }
  //まばたき終了
  if (eyeFrame == end+1) {
    bEye = false;
    eyeFrame = first;
  }
  wink++;
}

//モード５に変更------------------------------------------------------
void changeMode5() {
  //消しゴムを止める
  eraser.setVelocity(0, 0);

  mode = 5; //モード変更
  bodyFrame = 13;
  eyeFrame = 7;
}

//マウス押した時のイベント---------------------------------------------
void mousePressed() {
  if (mode == 0) {
    mode = 2;
    currentFrame = frameCount;
  }
}

//キーを押した時のイベント---------------------------------------------
void keyPressed() {
  if (key == 's' || key == 'S')saveFrame(timestamp()+"_####.png");
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
