//改行--------------------------------------------------------------
void addLine() {
  if (mode != prevMode) {
    texts.get(texts.size()-1).setBool(false); //今書いた文は描画中の文でなくなる
    currentLine+=1;
    currentLine = currentLine%lines.length;
    currentNewLine = 0;
    if (currentLine == 0) { //最後のテキストと最初のテキストの間に空白を入れる（３回改行する）
      newLineNum = 3;
    } else { 
      newLineNum = 1;
    }

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY-textSpace;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY-textSpace;
      rrect.get(i).setEasing(currentY, newY);
    }
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(50.00);
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(50.00);
  }

  //改行を終わらせる
  if (texts.get(0).eY == 1) {

    //新しい四角形を追加
    if (currentLine == lines.length-1) {
      rrect.add(new RoundRect(rrX, rrY+textSpace*3, rrWidth, rrHeight));
    }

    prevCurrentNewLine = currentNewLine;
    currentNewLine+=1;

    if (currentNewLine == newLineNum) {   
      //新しい行を追加
      texts.add(new Text(currentLine));

      //bDrawText = true;
      mode = 0;

      //画面外のテキストと四角形は削除
      if (currentLine==0 && rrect.size()>2) {
        float rrBottomY = rrect.get(0).y + rrect.get(0).rheight;
        if (rrBottomY < 0) {
          texts.subList(0, lines.length).clear(); //テキストを削除
          rrect.remove(0); //四角形を削除
          println(rrect.size());
        }
      }
    } else {

      //改行２回目、３回目のときに使う数値をセット
      if (prevCurrentNewLine != currentNewLine) {
        for (int i = 0; i < texts.size(); i++) {
          float currentY = texts.get(i).y;
          float newY = currentY-textSpace;
          //イージングで使う値
          texts.get(i).setEasing(currentY, newY);
        }

        //四角形
        for (int i = 0; i < rrect.size(); i++) {
          float currentY = rrect.get(i).y;
          float newY = currentY-textSpace;
          rrect.get(i).setEasing(currentY, newY);
        }
      }
    }
  } //end--if (texts.get(0).getEY()==1)
} //end--addIndent()

//改行（マイナス）----------------------------------------------------
void minusLine() {
  if (mode != prevMode) {

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY+textSpace;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY+textSpace;
      rrect.get(i).setEasing(currentY, newY);
    }
    //消しゴム用のPGraphics
    float currentY = eraser.y;
    float newY = currentY+textSpace;
    eraser.setEasing(currentY, newY);
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(25.0); //move(float speed) : speedの数値が小さいほど早い
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(25.0);
  }
  eraser.move(25.0); //消しゴム

  //改行を終わらせる
  if (texts.get(0).eY==1) {
    texts.remove(texts.size()-1); //最後のテキストを削除
    currentLine-=1;
    currentLine = currentLine%lines.length;

    eraser.set(currentLine);
    if (grp[currentLine].countChildren() != 0) {
      texts.get(texts.size()-1).setBool(true); //前の行をアクティブにする
    }
    time=1;

    mode = 4;
  } //end--if (texts.get(0).getEY()==1)
} //end--minusIndent()
