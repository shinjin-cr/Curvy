class CtCSpiral implements CurvyElement {
  PHSpiral segA, segB;
  PVector c0, c1;
  float r0, r1;
  
  CtCSpiral(float C0x, float C0y, float _r0,
            float C1x, float C1y, float _r1, boolean mirror)
  {
    c0 = new PVector(C0x, C0y);
    c1 = new PVector(C1x, C1y);
    r0 = _r0;
    r1 = _r1;
    
    // eq (32), ok
    float D = sq(C0x-C1x)+sq(C0y-C1y);
    float A = sq((r0+r1)/120);
    float B = sq((r0+r1)/60);  // +, ok!
    
    segA = new PHSpiral();
    segB = new PHSpiral();
    
  //  float theta = newtonsolve(30, D, A, B);
    float theta = halleysolve(10, D, A, B);
    segA.setTheta(theta);
    segB.setTheta(theta);
    
    PVector T = calcT(C1x-C0x, C1y-C0y, r0, r1, theta);
    segA.setT(T.x, T.y);
    segB.setT(-T.x, -T.y);
    
    segA.setR(r1);
    segA.calcP0(C1x, C1y);
    segB.setR(r0);
    segB.calcP0(C0x, C0y);
    if (mirror) {
      segA.mirror(C0x, C0y, C1x, C1y);
      segB.mirror(C0x, C0y, C1x, C1y);
    }
  }
  void draw(int steps) { draw(steps, false); }
  void draw(int steps, boolean asDeg3) {
    segA.draw(steps, asDeg3);
    segB.draw(steps, asDeg3);
  }
  
  PVector getStartPoint() {
    return segA.P[5];
  }
  
  PVector getEndPoint() {
    return segB.P[5];
  }

  String asSVG()
  {
    PVector[] r = getCubicPolyBezier(segA.P);

    String svg = "<path d=\"";
    svg += "M " + r[6].x + ", " +r[6].y;
    svg += " C "+ r[5].x + ", " +r[5].y;
    svg += " "  + r[4].x + ", " +r[4].y;
    svg += " "  + r[3].x + ", " +r[3].y;
    svg += " C "+ r[2].x + ", " +r[2].y;
    svg += " "  + r[1].x + ", " +r[1].y;
    svg += " "  + r[0].x + ", " +r[0].y;
    r = getCubicPolyBezier(segB.P);
    svg += " C "+ r[1].x + ", " +r[1].y;
    svg += " "  + r[2].x + ", " +r[2].y;
    svg += " "  + r[3].x + ", " +r[3].y;
    svg += " C "+ r[4].x + ", " +r[4].y;
    svg += " "  + r[5].x + ", " +r[5].y;
    svg += " "  + r[6].x + ", " +r[6].y;
    svg += "\" style=\"fill:none;fill-rule:evenodd;stroke:#FF0000;stroke-width:10px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1\" />\n";
    
    return svg;
  } 
}
