import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:ui_training_3/main_model.dart';

void main()=>runApp(new MyApp());

const kColorPurple = Color(0xFF8337EC);
const kColorPink = Color(0xFFFF006F);
const kColorIndicatorBegin = kColorPink;
const kColorIndicatorEnd = kColorPurple;
const kColorTitle = Color(0xFF616161);
const kColorText = Color(0xFF9E9E9E);
const kElevation = 4.0;


class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Mb Dig',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.white,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: kColorTitle),
        ),
        backgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: _Optimizer(),
    );
  }
}

class _Optimizer extends StatelessWidget{
  final List<Widget> page = [
    _BatteryOptimizer(),
    _ConnectionOptimizer(),
    _MemoryOptimizer(),
    _StrageOptimizer()
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_)=>MainModel(),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Builder(
              builder: (context){
                String pageTitle = context.select((MainModel value) => value.currentPageTitle);
                return Text(pageTitle);
              }
          ),
          centerTitle: false,
          leading: IconButton(
            color: kColorText,
            icon: Icon(Icons.chevron_left),
            onPressed: (){},
          ),
          elevation: 0,
        ),
        body:Column(
          children: <Widget>[
            _OptimizerIndex(),
            Expanded(
              child: Builder(
                  builder: (context){
                    int currentIndex = context.select((MainModel value) => value.currentIndex);
                    return page[currentIndex];
                  }
              )
            )
          ],
        )
      ),
    );
  }
}


/*BatteryOptimizer*/
class _BatteryOptimizer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Column(
        children: [
          _Indicator(),
          _AppIndex(),
          _OptimizeButton(),
        ],
      ),
    );
  }
}

/*ボタンインデックス*/

//↓Custom NavigationBar
//https://medium.com/@ankiimation/flutter-custom-bottom-navigation-bar-1c094d852b4
class _OptimizerIndex extends StatelessWidget{
  final List<IndexButton> children = [
    IndexButton(text: 'Battery Optimizer',index: 0,),
    IndexButton(text: 'Connection Optimizer',index: 1,),
    IndexButton(text: 'Memory Optimizer',index: 2,),
    IndexButton(text: 'Storage Optimizer',index: 3,),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: children.map((button) {
            return Row(
              children: [
                SizedBox(width: 16,),
                GestureDetector(
                  onTap: (){
                    int index = children.indexOf(button);
                    String text = button.text;
                    context.read<MainModel>().tabTap(index,text);
                  },
                  child: button,
                ),
              ],
            );
          }).toList()
        ),
      ),
    );
  }
}

//ボタンアイテム
class IndexButton extends StatelessWidget{
  final String text;
  final int index;
  IndexButton({@required this.text, @required this.index}):super();

  @override
  Widget build(BuildContext context) {
    int currentIndex = context.select((MainModel value) => value.currentIndex);
    // TODO: implement build
    return Container(
      height: 32,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: (index == currentIndex)?Colors.white:Colors.grey,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(2.0, 2.0), //(x,y)
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: kColorTitle, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/*ここまでボタンインデックス*/

/*ここからインディケーター*/
/*カスタムペイントで実装*/
class _Indicator extends HookWidget{
  final percentage = 0.7;
  final size = 164.0;

  @override
  Widget build(BuildContext context) {
    /*パーセンテージを整数化*/
    int percentageShow = (percentage*100).round();
    /*アニメーション用*/
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final tweenAnimation =
    Tween(begin: 0.0, end: 1.0).animate(animationController);
    /*アニメ*/
    animationController.forward();
    // TODO: implement build
    return CustomPaint(
      painter: _IndicatorPainter(
          percentage: percentage,
          textCircleRadius: size*0.5
      ),
      /*インジケーター部分*/
      child: Container(
        padding: EdgeInsets.all(64),
        /*数字部分*/
        child: Material(
          color: Colors.white,
          elevation: kElevation,
          borderRadius: BorderRadius.circular(size * 0.5),
          child: Container(
            width: size,
            height: size,
            child: Center(
              child: Text(
                '$percentageShow%',
                style: TextStyle(color: kColorPink, fontSize: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter{
  final double percentage; // バッテリーレベルの割合
  final double textCircleRadius; // 内側に表示される白丸の半径
  _IndicatorPainter({
    @required this.percentage,
    @required this.textCircleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    /*　i+=5⇨5°ずつ描画　*/
    for(int i=1; i<(360*percentage); i+=5){

      final per = i / 360.0;

      // 割合（0~1.0）からグラデーション色に変換
      final color = ColorTween(
        begin: kColorIndicatorBegin,
        end: kColorIndicatorEnd,
      ).lerp(per);

      //描画スタイルの指定
      final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

      final spaceLen = 16; // 円とゲージ間の長さ
      final lineLen = 24; // ゲージの長さ

      /*flutterは0°が３時の方向のため*/
      final angle = (2 * pi * per) - (pi / 2); // 0時方向から開始するため-90度ずらす

      // 円の中心座標
      final offset0 = Offset(size.width * 0.5, size.height * 0.5);
      // 線の内側部分の座標
      final offset1 = offset0.translate(
        (textCircleRadius + spaceLen) * cos(angle),
        (textCircleRadius + spaceLen) * sin(angle),
      );
      // 線の外側部分の座標
      //半径をlineLen倍している
      final offset2 = offset1.translate(
        lineLen * cos(angle),
        lineLen * sin(angle),
      );

      //描画
      canvas.drawLine(offset1, offset2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

/*ここまでインディケーター*/

/*アプリ一覧*/
class _AppIndex extends StatelessWidget{
  final List<_AppCard> appList = [
    _AppCard(icon: Icon(Icons.photo), appName: 'Photos', appPercentage: 10),
    _AppCard(icon: Icon(Icons.people), appName: 'Social Share', appPercentage: 25),
    _AppCard(icon: Icon(Icons.airplanemode_active), appName: 'To Travel', appPercentage: 8),
    _AppCard(icon: Icon(Icons.style), appName: '暗記カード', appPercentage: 12),
    _AppCard(icon: Icon(Icons.vpn_key), appName: 'Key Binder', appPercentage: 5),
    _AppCard(icon: Icon(Icons.email), appName: 'Email', appPercentage: 10)
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        /*ヘッダー要素*/
        ListTile(
          leading: ClipOval(
            child: Container(
                color: kColorPurple,
                padding: EdgeInsets.all(1),
                child: Icon(Icons.apps, color: Colors.white)
            ),
          ),
          title: Text(
            'Apps Drainage',
            style: TextStyle(color: kColorTitle),
          ),
          subtitle: Text(
            'Show the most draining energy application',
            style: TextStyle(color: kColorText),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2.0, 2.0), //(x,y)
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Column(
            children: appList.map((app){
              int index = appList.indexOf(app);
              return (index+1 < appList.length)
                  ?Column(children: [app,_HorizontalBorder()],)
                  :app;
            }).toList(),
          ),
        )
      ],
    );
  }
}

//アプリの格カード
class _AppCard extends StatelessWidget{
  final Icon icon;
  final String appName;
  final int appPercentage;

  _AppCard({
    @required this.icon,
    @required this.appName,
    @required this.appPercentage
  }):super();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: icon,
      title: Text(
        appName,
        style: TextStyle(color: kColorText),
      ),
      trailing: Text(
        '${appPercentage.toString()}%',
        style: TextStyle(color: kColorText),
      ),
    );
  }
}

//Appのボーダーライン
class _HorizontalBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[200],
    );
  }
}



/*ここまでアプリ一覧*/

class _OptimizeButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: TextButton(
        onPressed: (){},
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 10),
          backgroundColor: kColorPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)
          )
        ),
        child: Text(
          'Optimmize Now',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/*ここまで、ButteryOptimizer*/

/*その他ページ*/
class _ConnectionOptimizer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('ConnectionOptimizer'),
    );
  }
}

class _MemoryOptimizer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('MemoryOptimizer'),
    );
  }
}

class _StrageOptimizer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('StrageOptimizer'),
    );
  }
}