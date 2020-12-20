

const int $a = 97;
const int $z = 122;
const int $0 = 48;
const int $9 = 57;
const int $TAB = 9;
const int $SPACE = 32;
const int $EQ = 61;
const int $SEMICOLON = 59;
const int $OPEN_PAREN = 40;
const int $CLOSE_PAREN = 41;
const int $OPEN_CURLY_BRACKET = 123;
const int $CLOSE_CURLY_BRACKET = 125;
const String $VAR = 'var';
const String $FUNC = 'function';

enum TokenKind{
  $DEF,//初始化未知状态
  $ID, //identify
  $EQ, // =
  $FUNC, //func
  $VAR, //var
  $OPEN_PAREN, // (
  $CLOSE_PAREN,// )
  $LITERAL_NUM,// 字面量常量
  $SEMICOLON, //;
  $OPEN_CURLY_BRACKET, // {
  $CLOSE_CURLY_BRACKET //}
}

class Token{
  TokenKind kind;
  String value;
  int offset;

  Token(this.kind,this.value,this.offset);
}


class Scanner{
  String _string;
  int _offset = -1;
  var _tokenStr = "";

  var _tokens = <Token>[];



  Scanner(this._string);
  int advance()=> _string.codeUnitAt(++_offset);

  int peek(){
    if( _offset+1 >= _string.length){
      return $SPACE;
    }else{
      return _string.codeUnitAt(_offset + 1);
    }

  }

  int back() => _offset --;

  bool endOfString() => _offset >= _string.length -1;

  List<Token> getTokens() => _tokens;

  String getTokenStr() => _tokenStr;

  void appendToken(TokenKind kind){
    _tokens.add(Token(kind, _tokenStr,_offset));
    _tokenStr = '';
  }

  void appendChar(int ascii){
    _tokenStr += String.fromCharCode(ascii);
  }
}


bool isNum( int ascii ){
  return (ascii >= $0 && ascii <= $9 );
}

bool isAlpha (int ascii ){
 var  asciiLower = ascii | 0x20;
 return (asciiLower >= $a && asciiLower <= $z );
}


TokenKind proDfaState (int ascii ){
  if(isAlpha(ascii)){
    return TokenKind.$ID;
  }else if(isNum(ascii)){
    return TokenKind.$LITERAL_NUM;
  }else if(ascii == $EQ){
    return TokenKind.$EQ;
  }else if(ascii == $SEMICOLON){
    return TokenKind.$SEMICOLON;
  }else if(ascii == $OPEN_PAREN){
    return TokenKind.$OPEN_PAREN;
  }else if(ascii == $CLOSE_PAREN){
    return TokenKind.$CLOSE_PAREN;
  }else if(ascii == $OPEN_CURLY_BRACKET){
    return TokenKind.$OPEN_CURLY_BRACKET;
  }else if(ascii == $CLOSE_CURLY_BRACKET){
    return TokenKind.$CLOSE_CURLY_BRACKET;
  }else {
    return TokenKind.$DEF;
  }
}

List<Token> token_gen(){

  var classFile = '''
                      function 12tokenTest(){
                        var i;
                        i = 156;
                      }
                     ''';

  var scanner = Scanner(classFile);
  var next = scanner.peek();
  //初始化状态
  var dfaState = proDfaState(next);

  while(!scanner.endOfString()){

    var current = scanner.advance();
    var next = scanner.peek();
   switch (dfaState) {
     case TokenKind.$DEF:
       dfaState = proDfaState(next);
       break;
     case TokenKind.$ID:{
        //1.追加当前字符
        scanner.appendChar(current);
        //2.根据nex字符判断token结束
        if(!(isNum(next)||isAlpha(next))){

          //3.生成token
           if(scanner.getTokenStr() == $FUNC){
              scanner.appendToken(TokenKind.$FUNC);
           }else if(scanner.getTokenStr() == $VAR){
              scanner.appendToken(TokenKind.$VAR);
           }else {
             scanner.appendToken(TokenKind.$ID);
           }
           //4.状态机转变
           dfaState = proDfaState(next);
        }
     }
       break;

     case TokenKind.$LITERAL_NUM:{
       //1.追加当前字符
       scanner.appendChar(current);
       //2.根据nex字符判断token结束
       if(!isNum(next)&&!isAlpha(next)){
         //3.生成token
         scanner.appendToken(TokenKind.$LITERAL_NUM);
       }
       //4.状态机转变
       dfaState = proDfaState(next);
      }
       break;
     case TokenKind.$EQ:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$EQ);
       dfaState = proDfaState(next);
      }
       break;
     case TokenKind.$SEMICOLON:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$SEMICOLON);
       dfaState = proDfaState(next);
      }
       break;
     case TokenKind.$OPEN_PAREN:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$OPEN_PAREN);
       dfaState = proDfaState(next);
      }
       break;
     case TokenKind.$CLOSE_PAREN:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$CLOSE_PAREN);
       dfaState = proDfaState(next);
      }
       break;
     case TokenKind.$OPEN_CURLY_BRACKET:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$OPEN_CURLY_BRACKET);
       dfaState = proDfaState(next);
     }
     break;
     case TokenKind.$CLOSE_CURLY_BRACKET:{
       scanner.appendChar(current);
       scanner.appendToken(TokenKind.$CLOSE_PAREN);
       dfaState = proDfaState(next);
     }
     break;
   }

 }

  return scanner.getTokens();
}
