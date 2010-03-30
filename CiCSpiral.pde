// v0.8
// status: to be verified
// todo: verify
// todo: improve secantsolve_theta

class CiCSpiral implements CurvyElement {
  PVector c0 = new PVector(0,0);
  PVector c1 = new PVector(0,0);
  float r0, r1;
  float lambda;
  float l2,l3,l4,l5,l6,l7,l8;
  float p; // using p0
  public float theta;
  
  boolean valid;
  
  // curve params
  float u0,u1,u2, v0,v1,v2;
  PVector [] P = new PVector[6];
  
  // transformation params
  float scale = 1;
  PVector origin = new PVector(0, 0);
  float rotation = 0;
  
  // ctors  
  CiCSpiral() {for(int i=0;i<6;++i)P[i]=new PVector(0,0);}
  CiCSpiral(float _r0, float _r1) {
    this.setRadii(_r0, _r1);
    for(int i=0;i<6;++i)P[i]=new PVector(0,0);
  }
  
  void setRadii(float _r0, float _r1) {
    r0 = _r0;
    r1 = _r1;
    c0.set(0, r0, 0);
    c1.set(c0);

    lambda = pow(r0/r1, 1.0/3.0);
    l2 = sq(lambda); l3 = l2*lambda; l4 = l3*lambda; l5 = l4*lambda;
    l6 = l5*lambda; l7 = l6*lambda; l8 = l7*lambda;
  }
  
  float getMinRange() { // returns m_min
    float w = newtonsolve_c4p0(40);
    float theta0 = thetaFromw(w);
    float p_temp = p0(theta0);
    float m_min = m(p_temp, theta0);
// Debug
//    println("m_min == " + m_min);    
    return m_min*(r0-r1);
  }
  
  private void calcTheta(float dC) {
//    theta = secantsolve_theta(80, dC);
    theta = bisectsolve_theta(80, dC);
    p = p0(theta);
// Debug
//    println("in calcTheta(" + dC + ") >>> theta == " + theta);
//    println("m(λ)(r0-r1) == " +  m(p, theta)*(r0-r1));
  }
  
  
  // Calculates all te requred parameter for drawing, and resets any transformation
  void calcParams(float dC) {
    calcTheta(dC);
    if (!valid) {
      return;
    }
    float spr1 = sqrt(p*r1);
    
    u0 = spr1;
    u1 = spr1*p/(tan(theta/2)*4*l3);
    u2 = spr1*cos(theta)/lambda;
    
    v0 = 0;
    v1 = spr1*p/(4*l3);
    v2 = spr1*sin(theta)/lambda;
    
    PVector rhs = new PVector(0,0);
    
    P[0].set(rhs);
        
    P[1].set(P[0]);
    rhs.set(0.2*(sq(u0)-sq(v0)), 0.4*u0*v0, 0);
    P[1].add(rhs);
    
    P[2].set(P[1]);
    rhs.set(0.2*(u0*u1-v0*v1), 0.2*(u0*v1+u1*v0), 0);
    P[2].add(rhs);

    P[3].set(P[2]);
    rhs.set(1.0/15*(2*sq(u1)-2*sq(v1)+u0*u2-v0*v2), 1.0/15*(4*u1*v1+u0*v2+u2*v0), 0);
    P[3].add(rhs);

    P[4].set(P[3]);
    rhs.set(0.2*(u1*u2-v1*v2), 0.2*(u1*v2+u2*v1), 0);
    P[4].add(rhs);

    P[5].set(P[4]);
    rhs.set(0.2*(sq(u2)-sq(v2)), 0.4*u2*v2, 0);
    P[5].add(rhs);

    c1.set(P[5].x-r1*sin(2*theta), P[5].y+r1*cos(2*theta), 0);

// Debug
//    println("P[0] == " + P[0]); println("P[1] == " + P[1]); println("P[2] == " + P[2]);
//    println("P[3] == " + P[3]); println("P[4] == " + P[4]); println("P[5] == " + P[5]);
//  println("||C0-C1|| == " + c0.dist(c1));
  }
  
  PVector getC1() {
    return new PVector(c1.x, c1.y);
  }
  
  // Transforms the curve according to the parameters, considering the centre of the larger circle as the origin 
  void setTransform(float _scale, PVector _origin, float _phi, boolean mirror) {
//    for (int i=0; i<6; ++i) {
//      P[i].set( P[i].x*cos(-rotoation)-P[i].y*sin(-rotation), P[i].x*sin(-rotoation)+P[i].y*cos(-rotation) );
//      P[i].sub(origin);
//      P[i].div(scale);
//    }
    float m = mirror? -1 : 1;
    PVector origC0 = new PVector(0, r0);
    scale = _scale;
    origin = new PVector(_origin.x, _origin.y);
    rotation = _phi;
    for (int i=0; i<6; ++i) {
      P[i].sub(origC0);
      P[i].mult(scale);
      P[i].set( m*P[i].x*cos(rotation)-P[i].y*sin(rotation), P[i].x*sin(rotation)+P[i].y*cos(rotation), 0 );
      P[i].add(origin);
    }
    c0.sub(origC0);
    c0.mult(scale);
    c0.set( m*c0.x*cos(rotation)-c0.y*sin(rotation), c0.x*sin(rotation)+c0.y*cos(rotation), 0 );
    c0.add(origin);

    c1.sub(origC0);
    c1.mult(scale);
    c1.set( m*c1.x*cos(rotation)-c1.y*sin(rotation), c1.x*sin(rotation)+c1.y*cos(rotation), 0 );
    c1.add(origin);
  }

  void draw(int steps) { draw(steps, false); }
  
  void draw(int steps, boolean asDeg3) {
    if (!valid) return;
    if (asDeg3)
      BezierCubic(steps, P[0].x, P[0].y, P[1].x, P[1].y, P[2].x, P[2].y, P[3].x, P[3].y, P[4].x, P[4].y, P[5].x, P[5].y);
    else
      BezierQuintic(steps, P[0].x, P[0].y, P[1].x, P[1].y, P[2].x, P[2].y, P[3].x, P[3].y, P[4].x, P[4].y, P[5].x, P[5].y);
  }
  
  PVector getStartPoint() {
    return P[0];
  }
  
  PVector getEndPoint() {
    return P[5];
  }
  
  String asSVG()
  {
    PVector[] r = getCubicPolyBezier(P);

    String svg = "<path d=\"";
    svg += "M " + r[0].x + ", " +r[0].y;
    svg += " C "+ r[1].x + ", " +r[1].y;
    svg += " "  + r[2].x + ", " +r[2].y;
    svg += " "  + r[3].x + ", " +r[3].y;
    svg += " C "+ r[4].x + ", " +r[4].y;
    svg += " "  + r[5].x + ", " +r[5].y;
    svg += " "  + r[6].x + ", " +r[6].y;
    svg += "\" style=\"fill:none;fill-rule:evenodd;stroke:#FF0000;stroke-width:10px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1\" />\n";
    
    return svg;
  }  
  //-------------------------------------------------------------------------------------------
  float p0(float theta) {
    return 3.0/2.0*l2*(1+sqrt(1+16*lambda*sq(cos(theta/2))/9))*tan(theta/2);
  }
  
  float thetaFromw(float w) {
    return 2*acos(sqrt(w));
  }

  float c4p0w(float w) {
  	float w2 = sq(w);
  	float w3 = w2*w;
  	return (-(sqrt(w-w2)*(sqrt(w)*((144*w2-144*w)*l8+(36*w-36)*l7)+sqrt(w)*(12*w-12)*l7*sqrt(16*w*lambda+9))+sqrt(1-w)*
  sqrt(16*w*lambda+9)*(((-24)*w3+30*w2+(-6)*w)*l7+(9-9*w)*l6)+sqrt(1-w)*(((-72)*w3+66*w2+6*w)*l7+(27-27*w)*l6)))/(2*sqrt(w3));
  }
  
  float c4p0wd(float w) {
  	float w2 = sq(w);
  	float w3 = w2*w;
  	float w4 = w3*w;
  	float w5 = w4*w;
  	return (sqrt(w-w2)*(sqrt(1-w)*((1920*w4-1056*w3)*l8+(864*w3-180*w2+234*w)*l7+243*l6)+sqrt(1-w)*sqrt(16*w*lambda+9)*
  ((288*w3-60*w2+6*w)*l7+81*l6))+sqrt(w)*((576*w4-576*w3)*l8+(216*w3-108*w2-108*w)*l7)+sqrt(w)*sqrt(16*w*lambda+9)*
  ((576*w4-720*w3+144*w2)*l8+(72*w3-36*w2-36*w)*l7))/(4*sqrt(w5)*sqrt(w-w2)*sqrt(16*w*lambda+9));
  }
  
  float newtonsolve_c4p0(int iter) {
    float w = 1.0/2.0;
    float fv = c4p0w(w);
    while (iter-->0 && abs(fv)>0.0001) {
      w -= fv/c4p0wd(w);
      fv = c4p0w(w);
    }
    if (w<0.5) w = 0.5;
    return w;
  }
  
  float g1(float p, float theta) {
    if (theta == 0) return 0;
    float p2 = sq(p);
    return (l2*(2*p*l3*(6*lambda-1)+3*(p2*(lambda-1)
      +10*l4)*sin(theta)+3*(p2-20*l4)*sin(2*theta)
      +2*p*(6-lambda)*l2*cos(2*theta)
      +30*l4*sin(3*theta)-6*p*l2*cos(3*theta))
      +p*(p2-2*l4*(3-2*lambda+6*l2))*cos(theta))
      /(120*l6*sq(sin(theta/2)));
  }
  
  float g2(float p, float theta) {
    if (theta == 0) return 0;
    float p2 = sq(p);
    return (3*l2*(p2*(1+lambda)-20*l7+2*p2*cos(theta)
      +20*l4*cos(2*theta))*sin(theta/2)
      +p*((p2+2*l5)*cos(theta/2)
      +2*l4*(3-lambda)*cos(3*theta/2)-6*l4*cos(5*theta/2)))
      /(60*l6*sin(theta/2));
  }
  
  float m(float p, float theta) {
    return sqrt(sq(g1(p, theta))+sq(g2(p, theta)))/(l3-1);
  }
  
  float rootTheta(float theta, float r0r1, float dC) { // Habib eq 3.7
    return m(p0(theta), theta)*r0r1 - dC;
  }

  float secantsolve_theta(int iter, float dC) {
    float r0r1 = r0-r1;
    float theta_pp = PI/6;
    float theta_p = PI/3;
    float theta = theta_p;
    float fvpp = rootTheta(theta_pp, r0r1, dC);
    float fvp = rootTheta(theta_p, r0r1, dC);
    while (iter-->0 && abs(fvp)>0.000001) {
      theta = theta_p-(theta_p-theta_pp)/(fvp-fvpp)*fvp;
      theta_pp = theta_p;
      theta_p = theta;
      fvpp = fvp;
      fvp = rootTheta(theta_p, r0r1, dC);
      println(theta);
    }
// Debug
//    println("secantsolve >> iters left: " + iter + " fvp: " + fvp);
    return theta; 
  }
  
  float bisectsolve_theta(int iter, float dC) {
    float r0r1 = r0-r1;
    float left = 0.001;
    float right = PI/2;
    float midpoint = (left+right)/2;
    float fvl, fvr, fvm = rootTheta(midpoint, r0r1, dC);;
    while (iter-->0 && abs(right - left)>0.000001) {
      fvl = rootTheta(left, r0r1, dC);
      fvr = rootTheta(right, r0r1, dC);
// Debug
//      println("left: " + left + ", mid: " + midpoint + ", right: " + right);
//      println("left value: " + fvl + ", mid value: " + fvm + ", right value: " + fvr);
//      println();
      if ((fvl>0 && fvm<0) || (fvl<0 && fvm>0)) {
        right = midpoint;
      } else if ((fvr>0 && fvm<0) || (fvr<0 && fvm>0)) {
        left = midpoint;
      } else
        break;
      midpoint = (left+right)/2;
      fvm = rootTheta(midpoint, r0r1, dC);
    }
// Debug
//    println("bisectsolve >> iters left: " + iter + " fvm: " + fvm);
    valid = (midpoint>0 && midpoint<=PI/2 && abs(fvm)<0.0001);
    return midpoint;
  }
}

void spot(float x, float y) {
  ellipse(x,y,5,5);
}

