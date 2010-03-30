class PHSpiral {
  float P0x, P0y;
  float Tx, Ty;
  float Nx, Ny;
  float theta;
  float Gx, Gy;
  float GNx, GNy;
  float r;
  
  float beta, rho, alpha, gamma;

  // control points
  PVector [] P = new PVector[6];
  
  // misc
  float cos;
  float sin;
  
  void setR(float _r) {
    r = _r;
  }
  
  void setTheta(float _theta) {
    theta = _theta;
    cos = cos(theta);
    sin = sin(theta);
  }
  
  void setT(float _Tx, float _Ty) {
    Tx = _Tx;
    Ty = _Ty;
    Gx = Tx*cos-Ty*sin;
    Gy = Tx*sin+Ty*cos;
    Nx = -Ty;
    Ny =  Tx;
    GNx = -Gy;
    GNy =  Gx;
  }
  
  void calcP0(float Cx, float Cy) {
    float P5x = Cx - r*GNx;
    float P5y = Cy - r*GNy;
    
//    ellipse(P5x,P5y,5,5);
    
    float t_eff = 7*r*sin/(120*sq(1+cos))*(63+26*cos+12*cos*cos);
    float n_eff = 7*r*(1-cos)/(60*(1+cos))*(13+6*cos);
    
    P0x = P5x - t_eff*Tx - n_eff*Nx;
    P0y = P5y - t_eff*Ty - n_eff*Ny;
    
    beta = 0.5*sqrt(7*r*sin);
    rho = 7*beta/(4*(1+cos));
    alpha = rho;
    // mu = zeta = 0
    gamma = beta*sqrt((1-cos)/(1+cos));
    
    calcControlPoints();
  }
  
  void mirror(float c1x, float c1y, float c2x, float c2y) {
    PVector c = new PVector(c2x-c1x, c2y-c1y);
    PVector foo = new PVector();
    PVector bar = new PVector();

    c.normalize();
    
    bar.set(Tx, Ty, 0);
    foo.set(c); foo.mult(2*c.dot(bar)); foo.sub(bar);
    Tx = foo.x; Ty = foo.y;

    bar.set(Gx, Gy, 0);
    foo.set(c); foo.mult(2*c.dot(bar)); foo.sub(bar);
    Gx = foo.x; Gy = foo.y;

    bar.set(Nx, Ny, 0);
    foo.set(c); foo.mult(2*c.dot(bar)); foo.sub(bar);
    Nx = foo.x; Ny = foo.y;

    bar.set(GNx, GNy, 0);
    foo.set(c); foo.mult(2*c.dot(bar)); foo.sub(bar);
    GNx = foo.x; GNy = foo.y;

    beta = 0.5*sqrt(7*r*sin);
    rho = 7*beta/(4*(1+cos));
    alpha = rho;
    // mu = zeta = 0
    gamma = beta*sqrt((1-cos)/(1+cos));
    
    calcControlPoints();
  }
  
  void calcControlPoints() {
    float mu = 0, zeta = 0;
    P[0] = new PVector(P0x, P0y);
    P[1] = new PVector(P[0].x+(alpha*alpha-mu*mu)*Tx/5+2*alpha*mu*Nx/5,
                       P[0].y+(alpha*alpha-mu*mu)*Ty/5+2*alpha*mu*Ny/5);
    P[2] = new PVector(P[1].x+(alpha*rho-mu*zeta)*Tx/5+(alpha*zeta+rho*mu)*Nx/5,
                       P[1].y+(alpha*rho-mu*zeta)*Ty/5+(alpha*zeta+rho*mu)*Ny/5);
    
   
    P[3] = new PVector(P[2].x+(2*rho*rho-2*zeta*zeta+alpha*beta-mu*gamma)*Tx/15+(4*rho*zeta+alpha*gamma+beta*mu)*Nx/15,
                       P[2].y+(2*rho*rho-2*zeta*zeta+alpha*beta-mu*gamma)*Ty/15+(4*rho*zeta+alpha*gamma+beta*mu)*Ny/15);
    
    P[4] = new PVector(P[3].x+(rho*beta-zeta*gamma)*Tx/5+(rho*gamma+beta*zeta)*Nx/5,
                       P[3].y+(rho*beta-zeta*gamma)*Ty/5+(rho*gamma+beta*zeta)*Ny/5);
    
    P[5] = new PVector(P[4].x+(beta*beta-gamma*gamma)*Tx/5+2*beta*gamma*Nx/5,
                       P[4].y+(beta*beta-gamma*gamma)*Ty/5+2*beta*gamma*Ny/5);
  }

  void draw(int steps, boolean asDeg3) {
    if (asDeg3)
      BezierCubic(steps, P[0].x, P[0].y, P[1].x, P[1].y, P[2].x, P[2].y, P[3].x, P[3].y, P[4].x, P[4].y, P[5].x, P[5].y);
//      PHCurveAsB3(steps, P0x,P0y, Tx,Ty, Nx,Ny, alpha,rho,beta,0,0,gamma);
    else
      BezierQuintic(steps, P[0].x, P[0].y, P[1].x, P[1].y, P[2].x, P[2].y, P[3].x, P[3].y, P[4].x, P[4].y, P[5].x, P[5].y);
//      PHCurve(steps, P0x,P0y, Tx,Ty, Nx,Ny, alpha,rho,beta,0,0,gamma);
  }
}
