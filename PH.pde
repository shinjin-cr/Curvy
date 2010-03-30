// v1.9
// status: finished
// change log: 
//      v1.1 -added DegreeDecrease and BezierCubic
//      v1.9 -complete restructure



void BezierQuintic( int steps,
  float x0, float y0,
  float x1, float y1,
  float x2, float y2,
  float x3, float y3,
  float x4, float y4,
  float x5, float y5)
{
  float t=0;
  float t_step = 1.0/steps;
  float bx, by;
  float bbx, bby;

  bx = x0;
  by = y0;
       
  for (t += t_step; t<=1.0; t += t_step)
  {
    bbx =   x0*pow(1-t,5)+
          5*x1*pow(1-t,4)*t+
         10*x2*pow(1-t,3)*pow(t,2)+  
         10*x3*pow(1-t,2)*pow(t,3)+  
          5*x4*(1-t)     *pow(t,4)+  
            x5           *pow(t,5);  
    bby =   y0*pow(1-t,5)+
          5*y1*pow(1-t,4)*t+
         10*y2*pow(1-t,3)*pow(t,2)+  
         10*y3*pow(1-t,2)*pow(t,3)+  
          5*y4*(1-t)     *pow(t,4)+  
            y5           *pow(t,5);
            
    line(bx,by,bbx,bby);
    bx = bbx;
    by = bby;
  }
 
}

PVector[] DegreeDecrease(PVector[] p)
{
 PVector[] r = new PVector[p.length-1];
 
 float n = p.length-1;
 
 r[0] = new PVector(p[0].x, p[0].y);
 
 for (int i=1; i<p.length-1; ++i)
 {
   r[i] = new PVector( (n*p[i].x - i*r[i-1].x)/(n-i), (n*p[i].y - i*r[i-1].y)/(n-i) );
 }

 r[r.length-1] = new PVector(p[p.length-1].x, p[p.length-1].y);

 PVector t = new PVector(p[1].x-p[0].x, p[1].y-p[0].y);
 t.normalize();
 r[1] = ProjectToTangentLine(p[0], t, r[1]);
 
 t.x = p[p.length-2].x-p[p.length-1].x;
 t.y = p[p.length-2].y-p[p.length-1].y;
 t.normalize();
 r[r.length-2] = ProjectToTangentLine(p[p.length-1], t, r[r.length-2]);
 
 return r;
}

PVector ProjectToTangentLine(PVector p, PVector t, PVector q) // p: tangens egy pontja, t: tangens iranyvektora, egysegvektor, q: projektalando pt
{
  float d = (q.x-p.x)*t.x + (q.y-p.y)*t.y;
  return new PVector( p.x + d*t.x, p.y + d*t.y );
}

PVector[] Subdivide(PVector[] p, float a, float b)
{
  PVector[] r = new PVector[p.length];

  int degree = p.length-1;

  PVector[] tmp = new PVector[degree+1];

  for (int l = 0; l <= degree; ++l) // which control point do we compute
  {
    for (int f=0; f<=degree; ++f)
    {
      tmp[f] = new PVector(p[f].x, p[f].y, 1);
    }

    for (int i=1; i <= degree; ++i) // "i" counts the decast step
    {
      for (int j=0; j <= degree-i; ++j)
      {
        if ( i <= degree-l )
        {
          tmp[j].x = tmp[j].x *(1.0-a) +  tmp[j+1].x * a ;
          tmp[j].y = tmp[j].y *(1.0-a) +  tmp[j+1].y * a ;
        }
        else
        {
          tmp[j].x = tmp[j].x * (1.0-b) +  tmp[j+1].x * b ;
          tmp[j].y = tmp[j].y * (1.0-b) +  tmp[j+1].y * b ;
        }
      }
    }

    r[l] = new PVector(tmp[0].x, tmp[0].y);
  }

  return r;
}

void BezierCubic( int steps,
  float x0, float y0,
  float x1, float y1,
  float x2, float y2,
  float x3, float y3,
  float x4, float y4,
  float x5, float y5)
{
  // PH5 -> B3
  PVector[] bOrig = new PVector[6];

  bOrig[0] = new PVector(x0, y0);
  bOrig[1] = new PVector(x1, y1);
  bOrig[2] = new PVector(x2, y2);
  bOrig[3] = new PVector(x3, y3);
  bOrig[4] = new PVector(x4, y4);
  bOrig[5] = new PVector(x5, y5);

  PVector[] left = Subdivide(bOrig, 0, 0.5);
  PVector[] right = Subdivide(bOrig, 0.5, 1);

  PVector[] r = DegreeDecrease(DegreeDecrease(left));

  DrawDecreased(r, steps);

  r = DegreeDecrease(DegreeDecrease(right));

  DrawDecreased(r, steps);

}

PVector [] getCubicPolyBezier(PVector[] oldPH5) {
  PVector[] left = Subdivide(oldPH5, 0, 0.5);
  PVector[] right = Subdivide(oldPH5, 0.5, 1);

  left = DegreeDecrease(DegreeDecrease(left));
  right = DegreeDecrease(DegreeDecrease(right));

  PVector [] result = new PVector[7];
  for (int i = 0; i<4; ++i)
    result[i] = new PVector(left[i].x, left[i].y);
  for (int i = 1; i<4; ++i)
    result[i+3] = new PVector(right[i].x, right[i].y);
    
  return result;
}

void DrawDecreased(PVector[] r, int steps)
{
  float t=0;
  float t_step = 1.0/steps;
  float bx, by;
  float bbx, bby;

  float x0, y0, x1, y1, x2, y2, x3, y3;

  x0 = r[0].x; y0 = r[0].y;
  x1 = r[1].x; y1 = r[1].y;
  x2 = r[2].x; y2 = r[2].y;
  x3 = r[3].x; y3 = r[3].y;

  bx = x0;
  by = y0;

  for (t += t_step; t<=1.0; t += t_step)
  {
    bbx =   x0*pow(1-t,3)+
          3*x1*pow(1-t,2)*t+
          3*x2*pow(1-t,1)*pow(t,2)+
            x3           *pow(t,3);

    bby =   y0*pow(1-t,3)+
          3*y1*pow(1-t,2)*t+
          3*y2*pow(1-t,1)*pow(t,2)+
            y3           *pow(t,3);

    line(bx,by,bbx,bby);
    bx = bbx;
    by = bby;
  }
}

PVector[] CubicCircularArc(PVector a, PVector b, PVector o, float r) // o: origo, a,b: ket pont a koron, ilyen sorrendben megy a gorbe, r: sugar
{
  PVector t0 = new PVector( a.y - o.y, -(a.x - o.x) );
  PVector t1 = new PVector( b.y - o.y, -(b.x - o.x) );
  
  t0.normalize();
  t1.normalize();  
  
  PVector[] cp = new PVector[4];
  
  cp[0] = new PVector(a.x, a.y);
  cp[3] = new PVector(b.x, b.y);
  
  r /= 3;
  
  cp[1] = new PVector(cp[0].x + r*t0.x, cp[0].y + r*t0.y);
  cp[2] = new PVector(cp[3].x - r*t1.x, cp[3].y - r*t1.y);
  
  return cp;
}

