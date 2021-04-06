import 'package:flutter/material.dart';

class BarChartContainer extends StatefulWidget {
  final double height;
  final Color color;
  final Widget child;
  final double width;
  BarChartContainer({@required this.height,@required this.width, @required this.color, @required this.child, Key key}) : super(key: key);
  @override
  _BarChartContainerState createState() => _BarChartContainerState(this.height, this.color, this.child, this.width);
}

class _BarChartContainerState extends State<BarChartContainer> {
  _BarChartContainerState(double _length, Color _col, Widget child, double width){
    this._height = _length;
    this._color = _col;
    this._child = child;
    this._width = width;
  }
  double _height;
  double _width;
  Color _color;
  Widget _child;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: _child,
      width: _width,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              color: Colors.white,
              width: 1
          ),
          top: BorderSide(
              color: Colors.black,
              width: 1
          ),
          right: BorderSide(
              color: Colors.black,
              width: 1
          ),
        ),
        color: _color,
      ),
    );
  }
}