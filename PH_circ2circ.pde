// v1.2
// status: finished

float g1(float theta) { // eq (28), ok
  float sin = sin(theta);
  float cos = cos(theta);
  float cos2 = cos*cos;
  return sin/(1+2*cos+cos2)*(321-58*cos-36*cos2);
}

float g2(float theta) { // eq (29), ok
  float sin = sin(theta);
  float cos = cos(theta);
  return 1/(1+cos)*(91+11*cos+18*cos*cos);
}

float g1d(float theta) { // pg 947, ok
  float sin = sin(theta);
  float cos = cos(theta);
  float cos2 = cos*cos;
  float cos3 = cos*cos2;
  return -(36*cos3+72*cos2+365*cos-700)/(cos2+2*cos+1);
}

float g2d(float theta) { // pg 947, ok
  float sin = sin(theta);
  float cos = cos(theta);
  float cos2 = cos*cos;
  return -((18*cos2+36*cos-80)*sin)/(cos2+2*cos+1);
}

float g1dd(float theta) { // maxima
  float sin = sin(theta);
  float cos = cos(theta);
  float cos2 = cos*cos;
  float cos3 = cos*cos2;
  return ((36*cos3+108*cos2-221*cos+1765)*sin)/(cos3+3*cos2+3*cos+1);
}

float g2dd(float theta) { // maxima
  float cos = cos(theta);
  float cos2 = cos*cos;
  float cos3 = cos*cos2;
  return -(18*cos3+36*cos2+116*cos-196)/(cos2+2*cos+1);
}

float f(float theta, float D, float A, float B) { // eq (32), ok
  float fg1 = g1(theta);
  float fg2 = g2(theta);
  return D-A*fg1*fg1-B*fg2*fg2;
}

float fd(float theta, float A, float B) { // maxima
  float fg1 = g1(theta);
  float fg2 = g2(theta);
  float fg1d = g1d(theta);
  float fg2d = g2d(theta);
  return -2*(A*fg1*fg1d+B*fg2*fg2d);
}

float fdd(float theta, float A, float B) { // maxima
  float fg1 = g1(theta);
  float fg2 = g2(theta);
  float fg1d = g1d(theta);
  float fg2d = g2d(theta);
  float fg1dd = g1dd(theta);
  float fg2dd = g2dd(theta);
  return -2*(A*(fg1*fg1dd+fg1d)+B*(fg2*fg2dd+fg2d));
}

float newtonsolve(int iter, float D, float A, float B) {
  float theta = PI/4;
  float fv = f(theta, D, A, B);
  while (iter-->0 && abs(fv)>0.0001) {
    theta -= fv/fd(theta, A, B);
    fv = f(theta, D, A, B);
  }
  return theta;
}

float halleysolve(int iter, float D, float A, float B) {
  float theta = PI/4;
  float fv = f(theta, D, A, B);
  float fdv, fddv;
  while (iter-->0 && abs(fv)>0.0001) {
    fdv = fd(theta, A, B);
    fddv = fdd(theta, A, B);
    theta -= 2*fv*fdv/(2*fdv*fdv-fv*fddv);
    fv = f(theta, D, A, B);
  }
  return theta;
}

boolean isPossible(float r1, float r2, float c1x, float c1y, float c2x, float c2y) {
  return sq(r1+r2)<sq(c1x-c2x)+sq(c1y-c2y) && sq(c1x-c2x)+sq(c1y-c2y)<sq(3.075*(r1+r2));
}

PVector calcT(float c2c1x, float c2c1y, float r1, float r2, float theta) { // eqs (26)-(27), maxima
  float div = 1/(sq(c2c1x)+sq(c2c1y));
  float a = (r1+r2)/120*g1(theta);
  float b = (r1+r2)/60*g2(theta); // !!! +
  PVector T = new PVector((b*c2c1y+a*c2c1x)*div,(a*c2c1y-b*c2c1x)*div);
  
  return T;
}
/*
PVector calcP0(float Tx, float Ty, float theta, float Cx, float Cy, float r) {
  float cos = cos(theta);
  float sin = sin(theta);

  float Gx = Tx*cos-Ty*sin;
  float Gy = Tx*sin+Ty*cos;
  
  float GNx = -Gy;
  float GNy =  Gx;
  
  float Nx = -Ty;
  float Ny =  Tx;
  
  float P5x = Cx - r*GNx;
  float P5y = Cy - r*GNy;
  
  PVector P0 = new PVector(P5x, P5y);
  float t_eff = 7*r*sin/(120*sq(1+cos))*(63+26*cos+12*cos*cos);
  float n_eff = 7*r*(1-cos)/(60*(1+cos))*(13+6*cos);
  
  P0.x -= t_eff*Tx+n_eff*Nx;
  P0.y -= t_eff*Ty+n_eff*Ny;
  
  return P0;
}*/

