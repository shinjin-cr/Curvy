class CircleNode {
  CircleNode parent = null;
  CircleNode [] children = new CircleNode[0];
  
  private boolean mirrored;
  private PVector center;
  private float r;
  private float theta = 0;
  
  public boolean highlight = false;
  private boolean drawcircles = true;
  
  CurvyElement curvy = null;
  
  CircleNode(float cx, float cy, float radius, boolean mirror, CircleNode _parent) {
    center = new PVector(cx, cy);
    r = radius;
    parent = _parent;
    mirrored = mirror;
    recalcCurvy();
  }
  
  CircleNode addCircle(float cx, float cy, float radius, boolean mirror) {
    CircleNode subCirc = new CircleNode(cx, cy, radius, mirror, this);
    children = (CircleNode[])append(children, subCirc);
    return subCirc;
  }
  
  CircleNode getChild(int index) {
    return children[index];
  }
  
  void drawCircles(boolean draw) {
    drawcircles = draw;
    for ( int k = 0; k < children.length; ++k) {
      children[k].drawCircles(draw);
    }    
  }
  
  float getR() { return r; }
  void setR(float _r) {
    r = _r;
    recalcCurvy();
    for ( int k = 0; k < children.length; ++k) {
      children[k].recalcCurvy();
    }
  }
  
  void move(PVector delta) {
    center.add(delta);
    recalcCurvy();
    for ( int k = 0; k < children.length; ++k) {
      children[k].move(delta);
    }
  }
  
  void changeTheta(float delta) {
    theta += delta;
    for ( int k = 0; k < children.length; ++k) {
      children[k].recalcCurvyR();
    }
  }
  
  void flip() {
    mirrored = !mirrored;
    recalcCurvy();
  }
  
  void recalcCurvyR() {
    recalcCurvy();
    for ( int k = 0; k < children.length; ++k) {
      children[k].recalcCurvyR();
    }
  }
  
  void recalcCurvy() {
    if (parent != null) {
      if (isContainer(parent)) {
        // drawing circle inside circle
        CiCSpiral spiral = new CiCSpiral(parent.r, r);
        float m = spiral.getMinRange();
        float dC = m+0.0001;//parent.center.dist(center);
        spiral.calcParams(dC);
//        spiral.calcParams(max(dC, (parent.r-r)*0.9));
        spiral.setTransform(1, parent.center, parent.theta, false);
        theta = parent.theta+spiral.theta*2;
        center = spiral.getC1();
        
        curvy = spiral;
      } else if (isPossible(parent.r, r, parent.center.x, parent.center.y, center.x, center.y)) {
        // drawing circle to circle S segment
        curvy = new CtCSpiral(parent.center.x, parent.center.y, parent.r,
                              center.x, center.y, r,
                              mirrored);
      } else
        curvy = null;
    }
    
  }
  
  void draw(boolean asDeg3) {
    if (drawcircles) {
      noFill();
      if (highlight) {
        stroke(#ff1111);
        strokeWeight(3);
      } else {
        stroke(#ff0000,128);
        strokeWeight(1);
      }
      ellipse(center.x, center.y, r*2, r*2);
    }
    
    strokeWeight(1);
    stroke(#0000aa);
    if (curvy != null) {
      curvy.draw(128, asDeg3);
    }
    for ( int k = 0; k < children.length; ++k) {
      CircleNode child = children[k];
      child.draw(asDeg3);
    }
  }
  
  String asSVG() {
    String svg = "";
    if (curvy != null) {
      svg = curvy.asSVG();
    }
    for ( int k = 0; k < children.length; ++k) {
      svg += children[k].asSVG();
    }
    return svg;
  }
  
  CircleNode findByPoint(PVector p) {
    CircleNode found = null;
    for ( int k = 0; k < children.length && found == null; ++k)
      found = children[k].findByPoint(p);

    if (found == null && center.dist(p)<=r)
      found = this;

    return found;
  }
  
  boolean isContainer(CircleNode outter) {
    return outter.center.dist(center)<outter.r - r;
  }
  
  CircleNode getParent() {
    return parent;
  }
  
  CircleNode getFirstChild() {
    if (children.length == 0)
      return null;
    return children[0];
  }
  
  CircleNode getNextChild(CircleNode ch) {
    int k = 0;
    while (k<children.length && children[k++] != ch) ;
    if (k == children.length)
      return null;
    return children[k];
  }

  CircleNode getPrevChild(CircleNode ch) {
    int k = 0;
    while (k<children.length && children[k++] != ch) ;
    if (--k == 0)
      return null;
    return children[k-1];
  }  
}
