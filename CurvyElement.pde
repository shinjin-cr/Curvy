interface CurvyElement {
  void draw(int steps);
  void draw(int steps, boolean asDeg3);
  
  String asSVG();
  
  PVector getStartPoint();
  PVector getEndPoint();
}
